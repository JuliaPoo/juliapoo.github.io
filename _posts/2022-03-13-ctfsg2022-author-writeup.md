---
layout: post
author: JuliaPoo
category: CTF

display-title: "CTFSG 2022 Author Writeup and The Making Of"
tags:
    - ctf
    - crypto
    - re

nav: |
    * [Metadata](#metadata)
    * [CTF.SG CTF Trailer](#ctfsg-ctf-trailer)
        * [The Making](#the-making)
    * [Chopsticks](#chopsticks)
        * [Solution](#solution)
        * [The Making](#the-making-1)
    * [Chopsticks 2](#chopsticks-2)
        * [Solution](#solution-1)
        * [The Making](#the-making-2)
    * [White Cage](#white-cage)
        * [Solution A](#solution-a)
        * [Solution B](#solution-b)
        * [The Making](#the-making-3)
    * [Xor Can't Be That Hard](#xor-cant-be-that-hard)
        * [Solution](#solution-2)
    * [Roll Your Own AE](#roll-your-own-ae)
        * [Solution](#solution-3)
    * [Textbook RSA](#textbook-rsa)
        * [Solution](#solution-4)
    * [SHA-CBC](#sha-cbc)
        * [Solution](#solution-5)
    
excerpt: "Writeups for challenges I wrote for CTFSG 2022, and how it's made. Contains a lot of cool trinkets."
---

# Metadata

- Competition: CTFSG 2021
- Date: (Sat) 12 March 1000hrs -  (Sun) 13 March 1000hrs  (SGT, 24 Hours)
- Challenge Source: [github.com/JuliaPoo/CTFSG-2022-JuliaPoo](https://github.com/JuliaPoo/CTFSG-2022-JuliaPoo/)

So I was invited to write challenges for `CTFSG 2022` and had a lot of fun designing the challenges and spectating the competition. I hope yall had fun!

# CTF.SG CTF Trailer

- Category: **Sanity**
- Difficulty: **0/5** (Personal rating)
- Solved: `78`
- Points: `122`
- Flag: `CTFSG{CFG_4n1m4t10n}`

<style>
iframe[src*=youtube]
{
  max-width:100%;
  height:315;
}
</style>

<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/Qu7s7fr0ppY" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</center>

## The Making

So @_prokarius_ made the music, and I made the cursed IDA video player, so am gonna talk abt the _Cursed IDA Video Player_. The binary IDA runs is a _massive_ binary that contains a huge function which IDA plots the control flow of in a way that displays a frame of the video. The function is essentially a huge jump table padded with `nop`s to control the _brightness_ of each pixel.

So I actually did smth similar before where [I played bad apple on IDA](https://github.com/JuliaPoo/Bad-Apple-on-IDA) but decided to rewrite it to make it _not_ self modifying. This is so that I can play longer videos at higher resolution.

And you know how powerful C++ templates are? I decided to generate the video frames in C++ templates:

{% capture code %}
```cpp
#pragma once

#include "gen/image.data"

#pragma inline_recursion(on)
#pragma inline_depth(255)

template <size_t N> __forceinline void
nops()
{
    if constexpr (N != 0) {
        __asm  __emit 0x90;
        nops<N - 1>();
    }
}

static char _pixel_dummy_mem[0x64];
template <size_t N, bool wide = true> __forceinline void
pixel()
{
    if constexpr (wide) {
        __asm vfmaddsub132ps xmm0, xmm1, xmmword ptr cs : [edi + esi * 4 + _pixel_dummy_mem] ;
    }
    nops<N>();
}

template <class T, size_t N>
using Arr_t = const T[N];

template <size_t H, Arr_t<size_t, H>& PVALS, bool wide = true, size_t _PTR = 0> __forceinline void
pixel_column()
{
#define JMP_0 __asm __emit 0xe9 __asm __emit 0x00 __asm __emit 0x00  __asm __emit 0x00 __asm __emit 0x00
    if constexpr (_PTR < H) {
        pixel<PVALS[_PTR], wide>();
        JMP_0;
        pixel_column<H, PVALS, wide, _PTR + 1>();
    }
#undef JMP_0
}

template<int N>
struct _pixel_padding_arr {
    constexpr _pixel_padding_arr() : arr() {
        for (auto i = 0; i != N; ++i)
            const_cast<size_t*>(arr)[i] = 25;
    }
    Arr_t<size_t, N> arr;
};

template <size_t W, size_t H, Arr_t<Arr_t<size_t, H>, W>& PVALS> void
pixel_image()
{
    unsigned int select = 0;
    __asm xor edi, edi
    __asm xor esi, esi
    __asm int 3

    static constexpr size_t padding[H] = _pixel_padding_arr<H>().arr;

    switch (select) {
#define ITER_GADGET(N) case N: pixel_column<H, PVALS[N]>(); __asm jmp end;
#define ITER_END (IMAGE_WIDTH-1)
#include "iter.x"
    case W: pixel_column<H, padding, false>(); __asm jmp end; // TODO: Make padding not so wide
    default: __asm jmp end;
    }

end:
    return;
}

template <size_t NFRAMES, size_t W, size_t H, Arr_t<Arr_t<Arr_t<size_t, H>, W>, NFRAMES>& PVALS, size_t _PTR=0> void
movie()
{
    if constexpr (_PTR < NFRAMES) {
        pixel_image<W, H, PVALS[_PTR]>();
        movie<NFRAMES, W, H, PVALS, _PTR + 1>();
    }
}
```
{% endcapture %}

<details>
<summary>See the aforementioned <strong>Extremely Cursed</strong> templates</summary>
{{ code | markdownify }}
</details>

Here's a summary of what I encountered in the process of writing (and compiling) those cursed templates

1. Bugs in MSVC C++ compiler
    * Parsing differential between the linter and the compiler (linter raises an error but compiler compiles without complaint)
    * Lots of opaque `Internal Compiler Error` which just means the compiler crashed for some unhandled reason.
2. Never seen before error messages
    * `Fatal Error C1128: Number of sections exceeded object file format limit`
    * `Fatal Error C1202: recursive type or function dependency context too complex`
    * `Fatal Error C1055: compiler limit: out of keys`
        * Compiler literally ran out of hashes
3. Goodbye RAM
    * 8GB RAM used, and crashes after 1hr of 50% CPU usage.

Needless to say, those 70 lines of C++ took _forever_ to write (3hrs), and it wasn't even scalable. Turns out C++ templates are _super_ inefficient to compile. I then [rewrote everything in C99 macros](https://github.com/JuliaPoo/CTFSG-2022-JuliaPoo/tree/master/challenges/Sanity/CTFSG-CTF-Trailer/src).

# Chopsticks

- Category: **Misc**
- Difficulty: **1/5** (Personal rating)
- Solved: `47`
- Points: `500`
- Flag: `CTFSG{Th3_Perf3cT_Pl4YeR_0j2nlhe}`

```
Hey remember that hand game thing called chopsticks?
Pat's pretty good at a modified version of it.
Can you win?

connect to the service at:
chals.ctf.sg:20101
```

Players are tasked to play a simplified game of [Chopsticks](https://en.wikipedia.org/wiki/Chopsticks) with a player, `Pat`, with the perfect losing strategy (to be defined). The game is just like regular chopsticks but you can't revive dead hands, and the overflow happens at `7` instead of `5`. If the player wins they'll get the flag.

## Solution

Notice that according to the rules, the total count of feathers of both players will never decrease. Since you started first, the strategy is to stall (To split such that your feather count never increases) strategically such that the total feather count of both of you increases before you attack your opponent.

It also turns out that in this game, _you_ have the winning strategy since you started first, i.e. if both of you play perfectly (Pat does), you would win. One could programmatically figure out the winning strategy and play it against Pat.

## The Making

So I mentioned that `Pat` plays perfectly. However, `Pat`, having have to start 2nd, will lose against another perfect player. If you think abt it, it's not so clear how to define the "perfect losing strategy".

I'm going to define it as such:

> The _perfect losing strategy_ is a strategy that maximises the odds of winning a game against a _random player_, a player who will randomly pick any available move with equal probability.
> The _perfect losing strategy_ will hence 'guide' a player towards moves at which the player is most likely to fuck up.

Now I'm not going to sit and _manually_ figure out what this strategy is when I can write code to do that.

Let $s$ be the game state. This game state contains the number of feathers in both player's hands, whose turn it is and the visited states. This state fully describes the game and what states can come after it. Let $f(s)$ be the `forward` function. $f$ returns a set of all possible game states that can come after state $s$. Let $T(s)$ return whose turn it is at state $s$, $T(s) \in [0,1]$, where $0$ is the player who started first.

Finally, let $P(s)$ be the probability that player $1$ wins, following the _perfect losing strategy_ $S_{\text{lose}}(s)$ when the game is at state $s$, given that player $0$ is a _random player_. Let $q(s)$ be the probability that player $0$, a _random player_, takes a move that brings the game state to $s$. Needless today, $P(s)$ and $S_{\text{lose}}(s)$ only make sense when $T(s) = 1$, i.e. it's player $1$'s turn.

The $P(s)$ and $S_{\text{lose}}(s)$ can then be computed recursively through the game tree starting with $s_0$, if $T(s) = 1$, as:

$$
\begin{aligned}
S_{\text{lose}}(s), \; P(s) &= \operatorname*{argmax, \; max}_{x \in f(s)} \sum_{x' \in f(x)} q(x') P(x') \\
&= \operatorname*{argmax, \; max}_{x \in f(s)} \frac{1}{|f(x)|} \sum_{x' \in f(x)} P(x')
\end{aligned}
$$

This basically formalises the statement <span style="color:cyan">"$S_{\text{lose}}(s)$ is about picking the move that maximises player $1$'s chances of winning"</span>.

This can be computed (with some optimisations to not traverse the game tree again) as below. Turns out the expected win-rate is $1$ every $15120$ games with a _random player_.

{% capture code %}
```py
def get_best_losing_strategy(player, dbg=False, _state=None, _visited=None, _cache=None, _d=0):
    
    if _state == None:
        _state = init_state
    if _visited == None:
        _visited = set([_state])
    if _cache == None:
        _cache = {}

    turn = _state[-1]
    if dbg: print("  "*_d + str(turn) + ": " + str(_state))
        
    w,p = is_win(_state)
    if w:
        w = p==player
        if dbg: print("  "*_d + [">_<", "^-^"][w])
        if w: 
            return 1, _state, set([_state])
        return 0, None, None
    
    ns = [*(set(gen_possible(_state)) - _visited)]
    if len(ns) == 0:
        return turn != player, _state, set([_state])

    if _state in _cache:
        ret, v, d = _cache[_state]
        if _visited.isdisjoint(d) and \
            v.issubset(_visited):
            return 1, ret, d

    if turn == player: # Player can pick!
        
        scores = []
        strats = []
        for s in ns:
            nv = _visited.copy(); nv.add(s)
            w, strat, d = get_best_losing_strategy(player, dbg, s, nv, _cache, _d+1)
            scores.append(w); strats.append(strat)
            if w == 1:
                dep = d.copy(); dep.add(s)
                _cache[_state] = (s,strat), _visited, dep
                return 1, (s,strat), dep
        
        bs = max(scores)
        idx = scores.index(bs)
        return bs, (ns[idx], strats[idx]), None
    
    # It's not player's turn...
    strategy = {}
    score = 0
    nwin = 0
    dep = set()
    for s in ns:
        
        nv = _visited.copy(); nv.add(s)
        w, strat, d = get_best_losing_strategy(player, dbg, s, nv, _cache, _d+1)
        score += w
        strategy[s] = strat
        
        if w == 1:
            nwin += 1
            dep = dep | d
        
    if nwin==len(ns):
        _cache[_state] = strategy, _visited, dep
        return 1, strategy, dep
    
    return score/len(ns), strategy, dep
```
{% endcapture %}

<details>
<summary>See the aforementioned <strong>code</strong> to compute $P$ and $S_{\text{lose}}$</summary>
{{ code | markdownify }}
</details>

The full script to generate the losing (and winning strategy) can be found [here](https://github.com/JuliaPoo/CTFSG-2022-JuliaPoo/blob/master/challenges/Misc/Chopsticks/src/gen_strat.pyx).

# Chopsticks 2

- Category: **Misc**
- Difficulty: **3/5** (Personal rating)
- Solved: `25`
- Points: `912`
- Flag: `CTFSG{Ch0pst!ck5_m4STeR!11!_aim48djam3}`

```
Oh have you beat Pat in the previous game? Nice!
Well here's another that's closer to the classic chopsticks game:
You can now revive your hand!

connect to the service at:
chals.ctf.sg:20201
```

Players are tasked to play a harder version of a game of [Chopsticks](https://en.wikipedia.org/wiki/Chopsticks) with a player, `Pat`, with a decent enough strategy. If the player wins they'll get the flag. The game is just like regular chopsticks with reviving but now it overflows at `7` instead of `5`.

## Solution

The strategy is just like regular chopsticks: Force the other player to have only `1` feather. You could try to get your hand number count to be high, and one of `Pat`'s hand be `1`, so you can kill to other hand. The difficulty is that `Pat` is actively trying to do the same to you. Based on the games I've been automatically playing with `Pat`, it's humanely possible to win `Pat`.

Look at **The Making** if you wanna see how to automatically derive a strategy. The first player (which is you) is advantaged as they only have to look ahead `9` moves, while `Pat` has to look ahead `10` moves.

{% capture code %}
```
Pat: (1, 1, 1, 1, 0)
Jul: (1, 2, 1, 1, 1) ('1', ('A', 'B'))
Jule's Confidence:  0.07000000000000002
Pat: (1, 2, 1, 2, 0)
Jul: (2, 3, 1, 2, 1) ('1', ('B', 'A'))
Jule's Confidence:  0.08235942050080036
Pat: (2, 3, 2, 3, 0)
Jul: (2, 3, 2, 3, 1) ('2', ('2', '3'))
Jule's Confidence:  0.07000000000000002
Pat: (2, 3, 3, 5, 0)
Jul: (2, 3, 0, 3, 1) ('1', ('A', 'D'))
Jule's Confidence:  0.1114579285714286
Pat: (2, 3, 1, 2, 0)
Jul: (1, 4, 1, 2, 1) ('2', ('1', '4'))
Jule's Confidence:  0.07422300636093018
Pat: (1, 6, 1, 2, 0)
Jul: (3, 4, 1, 2, 1) ('2', ('3', '4'))
Jule's Confidence:  0.05571428571428572
Pat: (3, 4, 1, 2, 0)
Jul: (3, 4, 1, 6, 1) ('1', ('B', 'D'))
Jule's Confidence:  0.15000000000000002
Pat: (3, 4, 2, 5, 0)
Jul: (3, 4, 0, 2, 1) ('1', ('A', 'D'))
Jule's Confidence:  0.26881364534550006
Pat: (3, 4, 1, 1, 0)
Jul: (3, 4, 1, 1, 1) ('2', ('3', '4'))
Jule's Confidence:  0.7
Pat: (3, 5, 1, 1, 0)
Jul: (3, 5, 1, 4, 1) ('1', ('A', 'D'))
Jule's Confidence:  0.746709285714286
Pat: (0, 3, 1, 4, 0)
Jul: (0, 3, 0, 1, 1) ('1', ('A', 'D'))
Jule's Confidence:  1.0
Pat: (0, 4, 0, 1, 0)
Jul: (1, 3, 0, 1, 1) ('2', ('1', '3'))
Jule's Confidence:  1.0
Pat: (1, 4, 0, 1, 0)
Jul: (1, 4, 0, 1, 1) ('2', ('1', '4'))
Jule's Confidence:  1.0
Pat: (1, 5, 0, 1, 0)
Jul: (3, 3, 0, 1, 1) ('2', ('3', '3'))
Jule's Confidence:  1.0
Pat: (3, 4, 0, 1, 0)
Jul: (2, 5, 0, 1, 1) ('2', ('2', '5'))
Jule's Confidence:  1.0
Pat: (3, 5, 0, 1, 0)
Jul: (0, 5, 0, 1, 1) ('1', ('B', 'A'))
Jule's Confidence:  1.0
Pat: (0, 6, 0, 1, 0)
Jul: (0, 6, 0, 0, 1) ('1', ('B', 'C'))
Jule's Confidence:  1.0
We win!!!
...
+-------+-----------------------------------------+
| /\ /\ | You: ^-^                                |
|((-v-))|                                         |
|():::()|                            { You win! } |
+--VVV--+-----------------------------------------+
   +...............+     :     +...............+
   :               :     :     :    /    /    /:
   :               :     :     : ,=/\ ,=/\ ,=/\:
   :               : A:0 : B:6 :,=/\/,=/\/,=/\/:
   :               :     :     :(,\/ (,\/ (,\/ :
   :               :     :     :,=/\/,=/\/,=/\/:
   :               :     :     :(,\/ (,\/ (,\/ :
   +...............+     :     +...............+
 .................................................
   +...............+     :     +...............+
   :               :     :     :               :
   :               :     :     :               :
   :               :     :     :               :
   :               : C:0 : D:0 :               :
   :               :     :     :               :
   :               :     :     :               :
   +...............+     :     +...............+
+-------+-----------------------------------------+
| /\_/\ | Pat: Nice! CTFSG{Ch0pst!ck5_m4STeR!11!_ |
|( o.o )| aim48djam3}                             |
| > ^ < |                          { They lost! } |
+-------+-----------------------------------------+

End.
```
{% endcapture %}

<details>
<summary>See here for a sample game that beats `Pat`</summary>
<style>
#patpat * {
    line-height: 1.4em;
}
</style>
<div id="patpat">
{{ code | markdownify }}
</div>
</details>

Another solution is to simply split `1-1` as your first move, effectively making `Pat` the first player, and then play `Pat` against themselves on another instance.

## The Making

Since now players can revive through splitting, the game tree is significantly bigger. The "perfect losing strategy" can't be computed on this version of the game anymore. So it's time to write a _good enough_ strategy.

A common way to write such a strategy is via the [Minimax Algorithm](https://en.wikipedia.org/wiki/Minimax). You're trying to optimize smth, but the opponent will do whatever to minimise your gain. We start at the current game state, and evaluate each possible move at a certain depth, how much you can hope to gain from said move.

However, this is inefficient, and we can perform [Alpha Beta Pruning](https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning) to stop exploring states that you already know have a worse outcome.

Notice that _Alpha Beta Pruning_'s is more efficient if we try the better moves first. So we can first compute some heuristic of each state and try the states with a higher heuristic. This further improves performance by ~10x.

This allows `Pat` to pretty much respond immediately despite searching a depth of `10`, though I still made the server sleep to prevent players from overwhelming the server.

We still need to form some kind of heuristic for each state that says how good a state is. For that I considered a modified game where visiting previous states are allowed. This allows the game state to not be dependent on previous visited states which makes it a lot easier to analyse, which also allows aggressive pruning.

I then computed the probability of a player winning at the current state, assuming the opponent will pick the best move `~70%` of the time (and the other moves uniformly randomly), and used that as the heuristic. I then traversed the game tree _once_ to compute the heuristics of all reachable states, and save it into a lookup table. This takes... a negligible amount of time.

All these is implemented in around `150` lines of code.

{% capture code %}
```py
import sys
sys.setrecursionlimit(10000)

# state = (a,b,c,d,turn)
init_state = (1,1,1,1,0)
NHANDS = 7

def is_win(state):
    a,b,c,d,turn = state
    if a+b == 0: return True, 1
    if c+d == 0: return True, 0
    return False, None

def add_move(a,b):
    x = a+b
    if x >= NHANDS: return 0
    return x

def gen_possible(state, _cache={}):
    
    win, player = is_win(state)
    if win: return set()
    if state in _cache: return _cache[state].copy()
    
    a,b,c,d,turn = state
    ret = []
    if turn == 0:
        n = a+b
        ret += [(i,n-i,c,d,1) for i in range(1,NHANDS) if 0<n-i<NHANDS and 0<i<NHANDS and i<=n-i]
        if c!=0: ret += [(a,b,*sorted((add_move(c,j),d)),1) for j in (a,b) if j!=0]
        if d!=0: ret += [(a,b,*sorted((c,add_move(d,j))),1) for j in (a,b) if j!=0]
        if a!=0: ret += [(*sorted((j,add_move(b,a))),c,d,1) for j in (a,b)]
    else:
        n = c+d
        ret += [(a,b,i,n-i,0) for i in range(1,NHANDS) if 0<n-i<NHANDS and 0<i<NHANDS and i<=n-i]
        if a!=0: ret += [(*sorted((add_move(a,j),b)),c,d,0) for j in (c,d) if j != 0]
        if b!=0: ret += [(*sorted((a,add_move(b,j))),c,d,0) for j in (c,d) if j != 0]
        if c!=0: ret += [(a,b,*sorted((j,add_move(c,d))),0) for j in (c,d)]
        
    ret = set(ret)
    _cache[state] = ret
    return ret.copy()

def gen_win_states(player):
    
    if player == 0:
        return [
            (i,j,0,0,1) for i in range(NHANDS) for j in range(i,NHANDS)
        ][1:]
    
    return [
        (0,0,i,j,0) for i in range(NHANDS) for j in range(i,NHANDS)
    ][1:]

INF = 1.1
def gen_lookup_scores(player, _state=None, _cache=None, _visited=None):
    
    if _state == None: _state = init_state
    if _cache == None: _cache = {}
    if _visited == None: _visited = set()
    
    s = _state; t = s[-1]
    
    w,p = is_win(s)
    if w:
        sc = [-1,1][p == player] * INF
        _cache[s] = sc
        return sc, _cache
    if s in _cache:
        return _cache[s], _cache
    if s in _visited:
        return 0, _cache # Idk
    _visited = _visited.copy()
    _visited.add(s)
    
    ns = gen_possible(s)

    if t==player:
        ms = 0
        for n in ns:
            sc, _cache = gen_lookup_scores(player, n, _cache, _visited)
            ms = max(ms, sc)  
        _cache[s] = ms
        return ms, _cache
    
    ms = []
    for n in ns:
        sc, _cache = gen_lookup_scores(player, n, _cache, _visited)
        ms += [sc]

    midx = ms.index(min(ms))
    w = .7
    sc = (1-w)*(sum(ms) - ms[midx]) + w*ms[midx]
    _cache[s] = sc/len(ms)
    return sc, _cache

p_lookup = [
    gen_lookup_scores(0)[1],
    gen_lookup_scores(1)[1]
]
def alphabeta(player, state, depth, visited, _a=-INF, _b=INF):
    
    # `visited` doesn't contains `state`
    
    s = state; t=s[-1]
    visited = visited.copy(); visited.add(s)
    
    w,p = is_win(s)
    if w:
        return [INF,-INF][p!=player]
    if depth == 0:
        return p_lookup[t][s] * [1,-1][t!=player]
    
    ns = sorted([*(gen_possible(s) - visited)],
               key=lambda x: p_lookup[1^t][x])
    
    if player==t: # max tiem
        val = -INF
        for n in ns:
            val = max(val, alphabeta(player, n, depth-1, visited, _a, _b))
            if val >= _b:
                break
            _a = max(_a, val)
        return val
    
    val = INF
    for n in ns:
        val = min(val, alphabeta(player, n, depth-1, visited, _a, _b))
        if val <= _a:
            break
        _b = min(_b, val)
    return val

def evaluate_possible(state, depth, visited):
    
    # `visited` doesn't contains `state`
    
    visited = visited.copy(); visited.add(state)
    t = state[-1]
    ns = sorted([*(gen_possible(state) - visited)],
               key=lambda x: p_lookup[1^t][x])
    alpha = -INF
    vs = []
    for n in ns:
        v = alphabeta(t, n, depth, visited, alpha)
        vs.append(v)
        alpha = max(v, alpha)
        if alpha == INF:
            return alpha, n
    
    idx = vs.index(max(vs))
    return vs[idx], ns[idx]
```
{% endcapture %}

<details>
<summary>See here for the strategy code</summary>
{{ code | markdownify }}
</details>

# White Cage

- Category: **Reverse**
- Difficulty: **2/5**
- Solved: `2`
- Points: `1000`
- Flag: `CTFSG{I_respect_Ur_Cunning_BUT_no}`

```
I found this script somewhere in Kebun Baru, it seems to require a password.
```

Players are given a singular python script that asks the user for the flag, and checks the input with a function `verify` whether it's the correct flag.

```py
flag = input("Input flag: ")
match = re.match(r'^CTFSG\{[a-zA-Z_]+\}$', flag)
if match and verify(flag.encode('utf-8')):
    print("Flag is: %s"%flag)
else:
    print("Wrong flag")
```

The `verify` function is probably the most visually aesthetic piece of code I've ever written:


{% capture code %}
```py
verify = (
    
lambda h,e,w,r,o:h(e(h(h(w)(e(1)))(e(0))))(h(e(h(o(lambda f:lambda a:lambda b:(lambda c:lambda d:lambda i:lambda g:
c(a)(c(b)(e)(e(w)))(g(d(a))(d(b))(lambda 

                                                   x
                                                   :f(i(a))(
                                                  i(b))(x))(e(w
                                                  ))))(h(w)(e(e)))
                                                      (h(e(h(w)(e(e))
                                                       ))(h(w)(e(e(w))))
                                                         )(h(e(h(w)(e(e(w))
                                                   )))(h    (w)(e(e(w)))))(h(e
                                                           (h(h(e(h(e(h(h(h)(e(h(
                                                    e(h      (h)(e(e))))(h(e(e))(h(e
                                                        (h))(h(e(h(w)))(e)))))))(e(h(e
                                                     (h(e     (h(e(h(h)(e(e))))(h(e(e))(h
                                                        (h)   (e(e(w)))))))))(h(e(h(h)(e(h(
                                                            e(h(e(h(e(h(w)))(e)))))(h(e(h(w))
                                                          )(e))))))(e))))))(e))))(e(e(w)))))(h
                                                               (e(h(h(e(h))(h(e(h(h)(e(h(e(h(h)
                                                             (e(h(e(e))(h(e(h))(e))))))(h(e(e))(
                                                               h(e(h(h)))(e)))))))(h(e(h(e(h))))(
                                                             h(e(h(h)(e(h(e(h(h)(e(h(e(e))(h(e(h))(             e))))))(h(e(e)
                                                                )(h(e(h(h)))(h(e(e))(h(e(h(h)(e(e))))   (h(e(e))(h))))))))))(h
                                                               (e(e))(h(e(h))(h(e(e))(h(e(h(e(h(e(h(h)(e(h(h(h))(e)(h)))))(
                                                                 e)))))(h(e(h(h)(e(e))))(h(e(e))(h(e(h))(h(e(h))(h(e(e))(
                                                                  h(e(h(e(w))))(h(e(h))(h(e(e))(h(e(h(h)))(h(e(e))(e))
                                                                  )))))))))))))))))))(h(e(h(e(e))))(h(e(h(h)(e(h(e(h
                                                                  (w)))(h(e(e))(e))))))(h(e(e))(h(e(h(h)))(h(e(e)
                                                                  )(e)))))))(e))))(e(h(e(h(h(h)(e(e(h(h(e(h(h(
                                                                 w)(e(h(h(e(h))(e)))))))(e))(h(h(e(h))(e)))
                                                              (h(e(h(h(h(e(h))(e)))))(e)(h(h(e(h(h(w)(e(
                                                           h(h(e(h))(e)))))))(e))(h(h(e(h))(e)))(h(h
                                                      (e(h))(e))(h(h(e(h))(e))(w))))(w))))))(e(h
                                               (e(h(h(w)(e(h(h(e(h))(e)))))))(e)(h(e(h(h(
                                          h(e(h))(e)))))(e)(h(
                                         h(e(h))(e))(w))
                                          (h(h(e(h))
                                              (e




                                                                                   ))(    w
                                                                            )    ))(h(  e(h(
                                                                           h(h   (e(h   ))(   e
                                                                         )))))(  e)(h  (h(e  (h)
                                                                     )(e))(h(h(e(h))(e))(h(h(e(
                                                                    h))(e))(w))))(h(h(e(h))(e))
                                                                (w)))))))(h(e(h(h)(e(h(e(h(h)(
                                                              e(h(e(h(e(h(e(h))(h(e(e))(h(e(h
                                                           ))(h(e(e))(h(e(h(w)))))))))))(h(
                                                        e(h(h)(e(h(e(e))(h(e(h(h)))(h(e(e)
                                                      )(e)))))))(h(e(e))(h(e(h(h)))(h(e(e
                                                     ))(h(e(h(e(h(w)))))(h(h(e(h))(h(e(e
                                                   ))(h(e(h(h)))(h(e(e))(e)))))(h(e(h(
                                                 e(h(e(h(w)))(h(e(h(h)(e(e(h(h(e(h(h(w
                                                )(e(h(h(e(h))(e)))))))(e))(h(h(e(h))(e
      )))(h                                    (h(e(h))(e))(h(e(h(h(h(e(h))(e)))))(
     e)(h(h(e(h))                             (e))(h(h(e(h))(e))(h(h(e(h))(e))(h
     (h(e(h))(e))(h(                         h(e(h))(e))(w))))))(w))))))))(h(e
       (h(w)))(h(e(h(h)(                    e(e(h(h(e(h))(e))(h(h(e(h(h(w)(e(
          h(h(e(h))(e)))))))(e)             )(h(h(e(h))(e)))(h(h(e(h))(e))(h(
             h(e(h))(e))(h(h(e(h))(e))(h(e(h(h(h(e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h)
                )(e))(w)))(h(h(e(h))(e))(w))))))))))))(h(w)))))))))(h(e(h(h)(e(h(e(h(w)))(h
                    (e(h(h)(e(e(h(e(h(h(w)(e(h(h(e(h))(e)))))))(e)(h(h(e(h(h(h(e(h))(e))
                           )))(e))(h(h(e(h))(e)))(h(h(e(h))(e))(w)))(h(e(h(h(h(e(h))(
                                    e)))))(e)(h(h(e(h))(e))(w))(h(h(e(h))(e))(h(h(e
                                   (h))(e))(h(h(e(h))(e))(w))))))))))(h(e(h(w)
                                ))(h(e(h(h)(e(e(h(h(e(h))(e))(h(e(h(h(h(e
                             (h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h))
                         (e))(h(h(e(h))(e))(h(h(e(h))(e))(h(h
                     (e(h))(
                e))(w))
           ))))(w)
      ))))))(






                                                        h(
                                                   w))))))
                                                )))(h(e(e)
                                              )(h(e(h(h)
                                           ))(h(e(e))(e
                                         ))))))))))))
                                      ))))(h(e(e))(h
                                    (e(h(h)))(h(e(e
                                  ))(h(e(h(e(h(e(h(h(e
                                (h))(h(e(e))(h(e(h   (h)
                              ))(h(e(e))(e)))))))(
                             h(e(h(h)(e(h(e(h(h)(e(h
                            (w)))))(h(e(e))(h(e(h(h))
                           )(h(e(e))(e))))))))(h(e(
                          e))(h(e(h))(e))))))))(h(
      e(h(h)(e(h(        e(h(h)(e(h(w)))))(h(e(e))(
       h(e(h(h)))(h(e(e))(e))))))))(h(e(e))(h(e(h
         ))(h(e(e))(h(e(h(e(h(w)))))(h(e(h(h)(e(h
           (w)))))(h(e(e))(h(e(h(h)))(h(e(e))(e)
             )))))))))))))))))(h(e(h(e(h(e(h))(
                h(e(e))(h(e(h(h)(e(e(h(h(e(h))(e                            )  )(
                  h(h(e(h))(e))(h(h(e(h(h(w)(e(h                            (h  (e (h
                    ))(e)))))))(e))(h(h(e(h))(e))                         )(h(h (e (h(
                       h(w)(e(h(h(e(h))(e)))))))(e))                       (h(h(e(h))(e))
                           )(h(e(h(h(h(e(h))(e)))))(e)(h                   (h(e(h))(e))(h(h
                                (e(h))(e))(w)))(h(h(e(h))(e)                )(w)))))))))))(h(
                                                    e(h))(h(e(e))             (h(e(h(e(h(h(e(h(
                                                       e(h(h(e(h(              e(h(h(h)(e(e(h(e(h
                                                          (e(h(                e(h(h)(e(e))))(h(e(
                                                                                e))(h(e(h))(h(e(h(w
                                                                                  )))(e))))(e(w)))))                )(h(e
                                                                                   (h(h)(e(h(e(e))(h(            e(h))(h(
                                                                                    e(h(w)))(e)))))))       (h(e(e))(h(
                                                                             e(h(h(h)(e(e)))))(e))))))))(e(h(e(h(h(h(
                                                                              e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(
                                                                                h))(e))(h(e(h(h(h(e(h))(e)
                                                                                   ))))(e)(h(h(e(h))(e))(h
                                                                                        (h(e(h))(e))(w)))(w))
                                                                                             ))(w)))))(h(e(h(h)
                                                                                                                (e(
                                                                                                                   e)))









                                                                                )  (h(e(h(e(h))(h(
                                                                                    w)))))))))(e(h(h(
                                                                                  e(h(h)(e(e(e(w))))))(
                                                                                    h(e(h(w)))(h(e(e))(h
                                                                                    (e(h(h)(e(e))))(h(e(e)        )(h(e(h(
                                                                                     h(h(w)(e(h(h(e(h))(e))))))))(e))))))
                                                                                      )(h(h(e(h))(e)))(h(h(e(h))(e))(h
                                                                                      (e(h(h(h(e(h))(e)))))(e)(h(h(
                                                                                      e(h))(e))(h(h(e(h))(e))(w
                                                    )                             ))(w)))))))(h(h(e(h))(h(e
                                               (e  ))  (h                  (e(h(h)))(h(e(e))(e))))))
                                            )))(e(h(h(e(h(h(           w)(e(h(h(
                                         e(h))(e)))))))(e))
                                      (h(h(e(h))(e)))(h(e
                                   (h(h(h(e(h))(e)))))(e
                                 )(h(h(e(h))(e))(h(h(e
                               (h))(e))(h(h(e(h))(e))(
     h(h(e(h                  ))(e))(h(h(e(h))(e))
      (w))))))(w             ))))))))(h(e(h(h)(e(
          h(e(h(e(h(e(h))(h (e(e))(h(e(h))(h(e(e))(h(e
              (h(e(h(w)))(h(e(h(h)(e(e(h(h(e(h(h(w)(e(h
                        (h(e(h))(e)))))))(e))(h(h(e(
                      h))(e)))(h(h(e(h))(e))(h
                 (h(e(h))(e))(w))))))))
            (h(e
        (h









            (w)))
           (h(e(h(
           h)(e(e(h  (
           h(e(h(h(w)(e
          (h(h(e(h))(e))
          )))))(e))(h(h(e(
          h))(e)))(h(h(e(h)
          )(e))(h(e(h(h(h(e(
        h))(e)))))(e)(h(h(e(h
 ))(e))(h(h(e(h))(e))(w)))(w)))
   )))))(h(e(h(w)))(h(e(h(h)(e(e(h(e(h(h(w
      )(e(h(h(e(h))(e)))))))(e)(h(e(h(h(h
           (e(h))(e)))))(e)(h(h

                                              (e(h))(e))(w
                                               ))(h(h(e(h))(e))
                                                 (h(h(e(h))(e))(h(h
                                                   (e(h))(e))(w)))))(h
                                                   (e(h(h(h(e(h))(e)))))(
                                                  e)(h(h(e(h))(e))(h(h(e(h)
                                                 )(e))(h(h(e(h))(e))(w))))(h(
                                                h(e(h))(e))(w))))))))(h(e(h(w))
                                                )(h(e(h(h)(e(e(h(e   (h(h(h(e(h))(e
                                               )))))(e)(h(h(e(h)            )(e))
                                               (h(h(e(h))(e))
                                               (h(h(e(h)  )
                                              (e))(h(h  (
                                              e(h))(e )                                                           )(w)
                                              ))))  (                                                          w)))))
                                              )(h(e(                                                        h(w)))(
                                              h(e(h(                                                     h)(e(e(h(h
                                             (e(h))                                                    (e))(h(h(e( h)
                                              )(e                                                    ))(h(h(e(h))(e
                                                                                                    ))(h(h(e(h))(e
                                                                                        ))(h(      h(e(h(h(h(e(h))
                                                                                         (e)))))(e))(h(h(e(h))(e)
                                                                                           ))(h(h(e(h))(e))(w)))
                                                                                              ))))))))(h(w))))))
                                                                                                 )))))))))))))))(h
                                                                                                     (h(e(h))(h(e(e))(
                                                                                                                   h(e(h(h
                                                                                                                       )




                                                                                                           ))(h(e(e)
                                                                                                     )(e))))))))))(
                                                                                                 h(e(e))(h(e(h(h)
                                                                                             ))(e)))))))))))))(
                                                                                           h(h(e(h))(h(e(e))(h(
                                                                                         e(h))(h(e(e))(h(e(h))(h
                                                                                       (e(e))(h(e(h(e(h(e(h(h)(e(
                                                                                                 e))))(h(e(e))(h(e
                                                                                                 (h))(h(e(h(w)))(h
                                                       (e(h(h                                      )(e(e(h(h(e(h))(
                                                         e))(h(e(                                     h(h(h(e(h))(e
                                                           )))))(e)(h                                     (h(e(h))(
                                                            e))(h(h(e(h)                                 )  (e))(h(
                                                           h(e(h))(e))(h(h                                 ( e(h))(e
                                                            ))(w)))))(h(h(e(                                 h ))(e)
                                                             )(w))))))))(h(w))))))))))(h                      ( h(e(
                                                              h))(h(e(e))(h(e(h(h)))(                         h(e(e)
                                                              )(e)))))(h(e(h(e(h(w                             )))))
                                                           (h(h(e(h))(h(e(e))(                                   h(e
                                 (h (h ))           )(h(e(e))(e)))))(h
                              (e(h(e(h(e(h         (w)))
                           (h(e(h(h)(e(e(
                        h(h(e(h))(e))(h
                      (h(e(h(h(w)(e(h(
  h(e(h             ))(e)))))))(e))
   (h(h(e(h))      (e)))(h(e(h(h(h
        (e(h))(e)))))(e)(h(h(e(h))(e))(
               h(h(e(h))(e))(h(h(e(h
             ))(e))(h(h(e(h))(








       e))(
      h(h(e(
      h))(e))(w
     ))))))(w)))
     )))))(h(w))))
      )))(h(e(h(h)(
 e(h(e(h(w)))(h(e(h(
h)(e(e(h(h(e(h(h(w)(e(h(h(e(h
   ))(e)))))))(e))(h(h(e(h))
         (e)))(h(h(                           e(h))(e)
                                                )(h(h(e(h))
                                                 (e))(h(e(h(h(
                                                h(e(h))(e)))))(e
                                               )(h(h(e(h))(e))(h(h
                                               (e(h))(e))(w  )))(w))))
                                               )))))(h(w)                                       )
                                              )))))(                                        h(e(e
                                              ))(h                                        (e(h(
                                              h))                                      )(h(e(e)
                                              )(e)                                   ))))))))))
                                              )))                                   ))(h(e(h(e
                                              (                              h(h(e(h))(h(e(e)
                                                                               )(h(e(h(h)))(h
                                                                                  (e(e))(e))))
                                                                                      )))))(h(e(h(
                                                                                                 h)(






                                                                                                                            e
                                                                                                                        (h(e(e))(
                                                                                                                    h(e(h))(h(e(
                                                                                                                  e))(h(e(h(e(
                                                                                                  h             (e(h(w)))(h(e
                                                                                                  (h(h)(       e(e(h(e(h(h(
                                                                                                      h(e(h))(e)))))(e)(h(h(e(
                                                                                                           h))(e))(w))(h(h









                                             (
                                            e    (h))
                                            (  e)    )
                                             (h(h(                                                         e(h))(e))(h(h(e(h
                                            ))(e))(                                                   w)))))))))(h(w))))))
                                           )(h(e(h(h                                                  )(e(h(    w)))))(h(e
                                      (e))(h(e(h (h)))(h(e                                            (e          ))(e))
                                  ))))) ) )) ) )  ( h(e  (e))                                                      (h(e
                         (h(h   )  )   )     ( h  (  e (   e))(h                                                  (e(
                       h(e(h(e(  h          (  h  )   (  e   (  e)
                      )))(h(e   (   e   )   )  (   h      (    e  (
                      h))(h(w )    )   )   )   )   )   )   )    (   h                (e(h
                      (h)(e(e)             )   )   )    (   h    (   e                 (e))(
                        h(e(h))       (    h   (        e         (   h                (w)))(h
                       (   e     (    h    (   h    (    w         )   (               h(h(w)(h(
                      h    (    w    )         (  e(h(e( h    (         h               )(e(e))))
                     (    h          (         e(e))(h(e (          h    )              )(h(e(h(w)))(e)))
                    )    (     e     )    (    e))))(e(h  (    h     (    e              (h(h(w)(e(h(h(
                    e    (     h    )     )   (e)))))))(  e          )    )              (h(h(e(h(h(w
                   )                (     e (h(h(e(h))(e) )           )    )         )))(e))(h(h(
                   e    (     h     )     )(e))))(h(e(h(h (     h     (    e      (h))
                  (     e     )     )     )))(e)(h(h(e(h  )           )     (
                  e                 )    )(h(h(e(h))(e))                    (
                  h    (            h   (e(h))(e))(h(h     (           e    (
                  h    )            )   (e))( w))))  )     (           w    )
                  )    )           ))  )(e(h  (e(   h(h    (           h    (
                  e(h))(e))  ))    )( e)(h(  h(e(   h)    )(    e)  )(h(e(h(h
                  (    h      (     e(h)  )    (     e     )           )    )
                  )    )           (e)    (    h           (           h    (
                  e    (           h)     )    (           e                )
                  )    (            h     (    h           (                e
                  (    h            )     )    (                            e
                  )    )            (     w    )                            )
                  )    (            w     )    )                            )
                  (    w            )     )    )                            )
                  )    )            )     (    e                            )
                  )    )            )     )    )                            )
                  )    )            )     )    )          )                 )
                  )    (            h     (    h          (                 e
                  (    h            )     )    (          e                 )
                  )    (      h    (h     (    e    (h    ))          (e    )
                  )    (h    (e    (h    (h    (h   (e    (h    ))    (e    )
                 ))))(e)(h(h(e(h))(e))(h(h(e(h))(e))(w)))(w))))))))(o(lambda y:
                lambda z:h(e(h(e(h(e(h(h)(e(e))))(h(e(e))(h(e(h))(h(e(h(w)))(e))
                
))(e(w))))))(h(e(h(h)(e(h(e(e))(h(e(h))(h(e(h(w)))(e)))))))(h(e(e))(h(e(h(h(h)(e(e)))))(e))))(lambda x:y(z[1:])(x))(o(lambda y:
lambda m: h(h(e(h))(e))(y(r(m))) if r(m) else w)(z[0])) if z else  h(e(h(h)(e(e))))(h(e(e))(h(e(h))(h(e(h(w)))(e))))(e)(e)))))(
lambda x:lambda y:lambda z:x(z)(y(z)),lambda x:lambda y:x,lambda x:x,lambda n:(n+2022)%127,lambda f:(lambda g:f(g(g)))(lambda g
:f(lambda y: g(g)(y))))
```
{% endcapture %}

<details>
<summary>Please click to see how pretty <strong>verify</strong> is</summary>

<style>
#uwu * {
    font-size:calc(min(1vw, 8px)) !important;
    line-height: 1.3em;
}
</style>

<div id="uwu">
{{ code | markdownify }}
</div>
</details>

## Solution A

The intended solution is a side-channel attack. The `verify` function is intended to look super freaking scary to _deter_ any attempts to reverse it (it's still possible!). There are _many_ ways to do the side channel, but the basic idea is that, there is some statistical difference in having `n` characters correct, and `n+1` characters correct.

This means that you can guess the 1st char and use the statistical difference to know if the 1st char is correct, and move on to the next char, and so on.

I chose to use `sys.settrace` to log debugging events. But you can totally modify the `verify` function like counting the number of times one of the `lambda`s got called in `verify`, it all works.

For my `sys.settrace` method, experimentation shows if a character is guessed wrong, regardless of the next character, the difference in number of events is less than `1000`. If the character is guessed right, the number of events shoot up really obviously. This'll be the statistical difference to exploit.

{% capture code %}
```py
import chal # Challenge code
import sys, time

t = time.time()

ALLOWED = b"_qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM{}"

N_EVT = 0
def tracer(frame, event, arg=None):
    global N_EVT
    N_EVT += 1
sys.settrace(tracer)

def side_channel(b:bytes)->int:
    global N_EVT
    N_EVT = 0
    chal.verify(b)
    return N_EVT

flag = []
while True:

    for c in ALLOWED:
        d = abs(side_channel(flag+[c,0]) - side_channel(flag+[c,1]))
        print(f"{chr(c)} {d}   ", end="\r")
        if d > 1000: break

    flag += [c]
    flagpt = bytes(flag).decode('utf-8')
    print(f"{flagpt}" + " "*15)

    if chal.verify(flag):
        break

print(f"DONE {time.time()-t}s")
```
{% endcapture %}

<details>
<summary>Here's the script to brute-force character by character:</summary>
{{ code | markdownify }}
</details>

Using `pypy` bcuz it's faster, you'll get the flag in abt 250 seconds.

## Solution B

Time to actually reverse the challenge! I guess this counts as an unintended solution but
if someone actually manages to do this, they totally deserve the flag.

So go ahead and use python formatter to prettify the challenge code, and you'd see at the bottom
some interesting functions:

```py
h = lambda x: lambda y: lambda z: x(z)(y(z)), # S
e = lambda x: lambda y: x, # K
w = lambda x: x, # I
r = lambda n: (n + 2022) % 127, # Something
o = lambda f: (lambda g: f(g(g)))(lambda g: f(lambda y: g(g)(y))), # Z Combinator
```

If you're familiar with lambda calculus, you might recognise some of the functions used:

- `h`: [S Combinator in SKI Calculus](https://en.wikipedia.org/wiki/SKI_combinator_calculus)
- `e`: [K Combinator in SKI Calculus](https://en.wikipedia.org/wiki/SKI_combinator_calculus)
- `w`: [I Combinator in SKI Calculus](https://en.wikipedia.org/wiki/SKI_combinator_calculus)
- `r`: Meh just keep this in mind
- `o`: [Z Combinator](https://en.wikipedia.org/wiki/Fixed-point_combinator)
    - Like the _Y Combinator_ but hardier.

You might also notice a huge chunk of stuff made up of only `h`, `e` and `w`.

{% capture code %}
```py
e(h(e(h(h(h)(e(e(h(h(e(h(h(w)(e(h(h(e(h))(e)))))))(e))(h(h(e(h))(e)))(h(e(h(h(h(
e(h))(e)))))(e)(h(h(e(h(h(w)(e(h(h(e(h))(e)))))))(e))(h(h(e(h))(e)))(h(h(e(h))(e
))(h(h(e(h))(e))(w))))(w))))))(e(h(e(h(h(w)(e(h(h(e(h))(e)))))))(e)(h(e(h(h(h(e(
h))(e)))))(e)(h(h(e(h))(e))(w))(h(h(e(h))(e))(w)))(h(e(h(h(h(e(h))(e)))))(e)(h(h
(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(w))))(h(h(e(h))(e))(w)))))))(h(e(h(h)(e(h
(e(h(h)(e(h(e(h(e(h(e(h))(h(e(e))(h(e(h))(h(e(e))(h(e(h(w)))))))))))(h(e(h(h)(e(
h(e(e))(h(e(h(h)))(h(e(e))(e)))))))(h(e(e))(h(e(h(h)))(h(e(e))(h(e(h(e(h(w)))))(
h(h(e(h))(h(e(e))(h(e(h(h)))(h(e(e))(e)))))(h(e(h(e(h(e(h(w)))(h(e(h(h)(e(e(h(h(
e(h(h(w)(e(h(h(e(h))(e)))))))(e))(h(h(e(h))(e)))(h(h(e(h))(e))(h(e(h(h(h(e(h))(e
)))))(e)(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(w
))))))(w))))))))(h(e(h(w)))(h(e(h(h)(e(e(h(h(e(h))(e))(h(h(e(h(h(w)(e(h(h(e(h))(
e)))))))(e))(h(h(e(h))(e)))(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(h(e(h(h(h(
e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h))(e))(w)))(h(h(e(h))(e))(w))))))))))))(h(w
)))))))))(h(e(h(h)(e(h(e(h(w)))(h(e(h(h)(e(e(h(e(h(h(w)(e(h(h(e(h))(e)))))))(e)(
h(h(e(h(h(h(e(h))(e)))))(e))(h(h(e(h))(e)))(h(h(e(h))(e))(w)))(h(e(h(h(h(e(h))(e
)))))(e)(h(h(e(h))(e))(w))(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(w))))))))))
(h(e(h(w)))(h(e(h(h)(e(e(h(h(e(h))(e))(h(e(h(h(h(e(h))(e)))))(e)(h(h(e(h))(e))(h
(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(w))))))(w)))))))(h(w)))))
))))(h(e(e))(h(e(h(h)))(h(e(e))(e))))))))))))))))(h(e(e))(h(e(h(h)))(h(e(e))(h(e
(h(e(h(e(h(h(e(h))(h(e(e))(h(e(h(h)))(h(e(e))(e)))))))(h(e(h(h)(e(h(e(h(h)(e(h(w
)))))(h(e(e))(h(e(h(h)))(h(e(e))(e))))))))(h(e(e))(h(e(h))(e))))))))(h(e(h(h)(e(
h(e(h(h)(e(h(w)))))(h(e(e))(h(e(h(h)))(h(e(e))(e))))))))(h(e(e))(h(e(h))(h(e(e))
(h(e(h(e(h(w)))))(h(e(h(h)(e(h(w)))))(h(e(e))(h(e(h(h)))(h(e(e))(e))))))))))))))
))))(h(e(h(e(h(e(h))(h(e(e))(h(e(h(h)(e(e(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h(h(
w)(e(h(h(e(h))(e)))))))(e))(h(h(e(h))(e)))(h(h(e(h(h(w)(e(h(h(e(h))(e)))))))(e))
(h(h(e(h))(e)))(h(e(h(h(h(e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h))(e))(w)))(h(h(e
(h))(e))(w)))))))))))(h(e(h))(h(e(e))(h(e(h(e(h(h(e(h(e(h(h(e(h(e(h(h(h)(e(e(h(e
(h(e(h(e(h(h)(e(e))))(h(e(e))(h(e(h))(h(e(h(w)))(e))))(e(w))))))(h(e(h(h)(e(h(e(
e))(h(e(h))(h(e(h(w)))(e)))))))(h(e(e))(h(e(h(h(h)(e(e)))))(e))))))))(e(h(e(h(h(
h(e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h))(e))(h(e(h(h(h(e(h))(e)))))(e)(h(h(e(h)
)(e))(h(h(e(h))(e))(w)))(w))))(w)))))(h(e(h(h)(e(e))))(h(e(h(e(h))(h(w)))))))))(
e(h(h(e(h(h)(e(e(e(w))))))(h(e(h(w)))(h(e(e))(h(e(h(h)(e(e))))(h(e(e))(h(e(h(h(h
(w)(e(h(h(e(h))(e))))))))(e)))))))(h(h(e(h))(e)))(h(h(e(h))(e))(h(e(h(h(h(e(h))(
e)))))(e)(h(h(e(h))(e))(h(h(e(h))(e))(w)))(w)))))))(h(h(e(h))(h(e(e))(h(e(h(h)))
(h(e(e))(e)))))))))(e(h(h(e(h(h(w)(e(h(h(e(h))(e)))))))(e))(h(h(e(h))(e)))(h(e(h
(h(h(e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(h(h
(e(h))(e))(w))))))(w))))))))(h(e(h(h)(e(h(e(h(e(h(e(h))(h(e(e))(h(e(h))(h(e(e))(
h(e(h(e(h(w)))(h(e(h(h)(e(e(h(h(e(h(h(w)(e(h(h(e(h))(e)))))))(e))(h(h(e(h))(e)))
(h(h(e(h))(e))(h(h(e(h))(e))(w))))))))(h(e(h(w)))(h(e(h(h)(e(e(h(h(e(h(h(w)(e(h(
h(e(h))(e)))))))(e))(h(h(e(h))(e)))(h(h(e(h))(e))(h(e(h(h(h(e(h))(e)))))(e)(h(h(
e(h))(e))(h(h(e(h))(e))(w)))(w))))))))(h(e(h(w)))(h(e(h(h)(e(e(h(e(h(h(w)(e(h(h(
e(h))(e)))))))(e)(h(e(h(h(h(e(h))(e)))))(e)(h(h(e(h))(e))(w))(h(h(e(h))(e))(h(h(
e(h))(e))(h(h(e(h))(e))(w)))))(h(e(h(h(h(e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h))
(e))(h(h(e(h))(e))(w))))(h(h(e(h))(e))(w))))))))(h(e(h(w)))(h(e(h(h)(e(e(h(e(h(h
(h(e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(w))))
)(w))))))(h(e(h(w)))(h(e(h(h)(e(e(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(h(h(
e(h))(e))(h(h(e(h(h(h(e(h))(e)))))(e))(h(h(e(h))(e)))(h(h(e(h))(e))(w)))))))))))
(h(w)))))))))))))))))))))(h(h(e(h))(h(e(e))(h(e(h(h)))(h(e(e))(e))))))))))(h(e(e
))(h(e(h(h)))(e)))))))))))))(h(h(e(h))(h(e(e))(h(e(h))(h(e(e))(h(e(h))(h(e(e))(h
(e(h(e(h(e(h(h)(e(e))))(h(e(e))(h(e(h))(h(e(h(w)))(h(e(h(h)(e(e(h(h(e(h))(e))(h(
e(h(h(h(e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(
w)))))(h(h(e(h))(e))(w))))))))(h(w))))))))))(h(h(e(h))(h(e(e))(h(e(h(h)))(h(e(e)
)(e)))))(h(e(h(e(h(w)))))(h(h(e(h))(h(e(e))(h(e(h(h)))(h(e(e))(e)))))(h(e(h(e(h(
e(h(w)))(h(e(h(h)(e(e(h(h(e(h))(e))(h(h(e(h(h(w)(e(h(h(e(h))(e)))))))(e))(h(h(e(
h))(e)))(h(e(h(h(h(e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(h(h
(e(h))(e))(h(h(e(h))(e))(w))))))(w))))))))(h(w)))))))(h(e(h(h)(e(h(e(h(w)))(h(e(
h(h)(e(e(h(h(e(h(h(w)(e(h(h(e(h))(e)))))))(e))(h(h(e(h))(e)))(h(h(e(h))(e))(h(h(
e(h))(e))(h(e(h(h(h(e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h))(e))(w)))(w)))))))))(
h(w)))))))(h(e(e))(h(e(h(h)))(h(e(e))(e))))))))))))))))(h(e(h(e(h(h(e(h))(h(e(e)
)(h(e(h(h)))(h(e(e))(e)))))))))(h(e(h(h)(e(h(e(e))(h(e(h))(h(e(e))(h(e(h(e(h(e(h
(w)))(h(e(h(h)(e(e(h(e(h(h(h(e(h))(e)))))(e)(h(h(e(h))(e))(w))(h(h(e(h))(e))(h(h
(e(h))(e))(h(h(e(h))(e))(w)))))))))(h(w)))))))(h(e(h(h)(e(h(w)))))(h(e(e))(h(e(h
(h)))(h(e(e))(e))))))))))))(h(e(e))(h(e(h(h)))(h(e(e))(h(e(h(e(h(e(h(h)(e(e))))(
h(e(e))(h(e(h))(h(w))))))))(h(e(h(h)(e(e))))(h(e(e))(h(e(h))(h(e(h(w)))(h(e(h(h(
w)(h(h(w)(h(h(w)(e(h(e(h(h)(e(e))))(h(e(e))(h(e(h))(h(e(h(w)))(e))))(e)(e))))(e(
h(h(e(h(h(w)(e(h(h(e(h))(e)))))))(e))(h(h(e(h(h(w)(e(h(h(e(h))(e)))))))(e))(h(h(
e(h))(e))))(h(e(h(h(h(e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h))(e))(h(h(e(h))(e))(
h(h(e(h))(e))(w)))))(w))))))(e(h(e(h(h(h(e(h))(e)))))(e)(h(h(e(h))(e))(h(e(h(h(h
(e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h))(e))(w)))(w)))(w)))))))(e)))))))))))))))
(h(h(e(h))(e))(h(h(e(h))(e))(h(e(h(h(h(e(h))(e)))))(e)(h(h(e(h))(e))(h(h(e(h))(e
))(w)))(w)))))
```
{% endcapture %}

<details>
<summary>See huge chunk:</summary>
{{ code | markdownify }}
</details>

Since said "huge chunk" is made up of only SKI combinators, we could [beta-reduce](https://en.wikipedia.org/wiki/Lambda_calculus#%CE%B2-reduction) it into regular lamba expressions and _hope_ that it converges.

We don't need to write our own beta reduction algo (tho I did write it, see `The Making`), we could just use one [online](http://ski.aditsu.net/). 

This one online however has some annoying limits: `Reduction error: length exceeded 1000`, so I just modified the `js` limit to be some ungodly huge number, and the site outputs the following (huge) lambda expression:

{% capture code %}
```js
(x0->(x1->x1((x2->(x3->x3)))((x4->x4((x5->(x6->x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5
(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5
(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5
(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x5(x6))))))))))))))))))))))
))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))(
(x7->x7((x8->(x9->x9)))((x10->x10((x11->(x12->x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11
(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11
(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11
(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11
(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x11(x12)))))))))))))))))))))))))))))))))))))))))))))))))))))
))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))((x13->x13((x14->(x15->x15)))((x16->x16((x17->
(x18->x17(x17(x17(x17(x17(x17(x17(x18))))))))))((x19->x19((x20->(x21->x21)))((x22->x22((x23->(x24->x23(x23
(x23(x23(x23(x23(x23(x23(x23(x23(x23(x23(x23(x23(x23(x23(x23(x23(x23(x23(x23(x24))))))))))))))))))))))))(
(x25->x25((x26->(x27->x27)))((x28->x28((x29->(x30->x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29
(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29
(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29
(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29(x29
(x29(x30)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))(
(x31->x31((x32->(x33->x33)))((x34->x34((x35->(x36->x35(x35(x35(x35(x35(x35(x35(x35(x35(x35(x35(x35(x35(x35
(x35(x35(x35(x35(x35(x35(x35(x35(x35(x35(x35(x36))))))))))))))))))))))))))))((x37->x37((x38->(x39->x39)))(
(x40->x40((x41->(x42->x41(x41(x41(x41(x41(x41(x41(x41(x41(x41(x41(x41(x41(x41(x41(x41(x41(x41(x41(x41(x42))))
)))))))))))))))))))((x43->x43((x44->(x45->x45)))((x46->x46((x47->(x48->x47(x47(x47(x47(x47(x47(x47(x47(x47
(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47
(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47
(x47(x47(x47(x47(x47(x47(x47(x47(x47(x47(x48)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
)))))))))))((x49->x49((x50->(x51->x51)))((x52->x52((x53->(x54->x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53
(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53
(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53
(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53
(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x53(x54)))))))))))))))))))))
)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))((x55->x55(
(x56->(x57->x57)))((x58->x58((x59->(x60->x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59
(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59
(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59
(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59(x59
(x59(x60)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
)((x61->x61((x62->(x63->x63)))((x64->x64((x65->(x66->x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65
(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65
(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65(x65
(x65(x65(x65(x65(x65(x65(x65(x66)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
)((x67->x67((x68->(x69->x69)))((x70->x70((x71->(x72->x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71
(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71
(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x71(x72)))))))))))))))))))))
))))))))))))))))))))))))))))))))))))))))))))((x73->x73((x74->(x75->x75)))((x76->x76((x77->(x78->x77(x77(x77
(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77
(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77
(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77
(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x77(x78)))))))))))))))))))))))))))))))))))))))))))))
)))))))))))))))))))))))))))))))))))))))))))))))))))))))))((x79->x79((x80->(x81->x81)))((x82->x82((x83->
(x84->x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83
(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x83(x84)))))))))))))))))
))))))))))))))))))))))))))))))))))((x85->x85((x86->(x87->x87)))((x88->x88((x89->(x90->x89(x89(x89(x89(x89(x89
(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89(x89
(x89(x89(x89(x89(x90))))))))))))))))))))))))))))))))))))))))((x91->x91((x92->(x93->x93)))((x94->x94((x95->
(x96->x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95
(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95
(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x95(x96)))))))))))))))))))))))))
)))))))))))))))))))))))))))))))))))))))))))))))))))((x97->x97((x98->(x99->x99)))((x100->x100((x101->
(x102->x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101
(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101
(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101
(x101(x101(x101(x101(x101(x101(x101(x101(x101(x101(x102))))))))))))))))))))))))))))))))))))))))))))))))))))))
)))))))))))))))))))))((x103->x103((x104->(x105->x105)))((x106->x106((x107->(x108->x107(x107(x107(x107(x107
(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107
(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107
(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107
(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107
(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107(x107
(x107(x107(x107(x108)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
)))))))))))))))))))))))))))((x109->x109((x110->(x111->x111)))((x112->x112((x113->(x114->x113(x113(x113(x113
(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113
(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113
(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113(x113
(x113(x113(x113(x113(x113(x113(x114))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
))((x115->x115((x116->(x117->x117)))((x118->x118((x119->(x120->x119(x119(x119(x119(x119(x119(x119(x119(x119
(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119
(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119
(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119
(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119
(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119(x119
(x119(x119(x119(x119(x119(x119(x119(x120)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
)))))))))))))))))))))))))))))))))))))))))))))))))))))))((x121->x121((x122->(x123->x123)))((x124->x124((x125->
(x126->x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125
(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125
(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125
(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125
(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125
(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125(x125
(x125(x126)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
))))))))))))))))))))))))))))))((x127->x127((x128->(x129->x129)))((x130->x130((x131->(x132->x131(x131(x131
(x131(x131(x131(x131(x131(x131(x131(x131(x132))))))))))))))((x133->x133((x134->(x135->x135)))((x136->x136(
(x137->(x138->x137(x137(x137(x137(x137(x137(x137(x137(x137(x137(x137(x138))))))))))))))((x139->x139((x140->
(x141->x141)))((x142->x142((x143->(x144->x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143
(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143
(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143
(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x143(x144)))))))))
))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))((x145->x145((x146->(x147->x147)))(
(x148->x148((x149->(x150->x149(x149(x149(x149(x149(x149(x149(x149(x149(x149(x149(x150))))))))))))))(
(x151->x151((x152->(x153->x153)))((x154->x154((x155->(x156->x155(x155(x155(x155(x155(x155(x155(x155(x155(x155
(x155(x155(x155(x155(x155(x155(x155(x155(x155(x155(x155(x155(x155(x156))))))))))))))))))))))))))((x157->x157(
(x158->(x159->x159)))((x160->x160((x161->(x162->x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161
(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161
(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161
(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x161(x162)))))))))
)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))((x163->x163((x164->(x165->x165)))(
(x166->x166((x167->(x168->x167(x167(x167(x167(x167(x167(x167(x167(x167(x167(x167(x167(x167(x167(x167(x167
(x167(x167(x167(x167(x167(x167(x167(x167(x167(x167(x167(x167(x167(x167(x167(x167(x168))))))))))))))))))))))))
)))))))))))((x169->x169((x170->(x171->x171)))((x172->x172((x173->(x174->x173(x173(x173(x173(x173(x173(x173
(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173
(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173
(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173(x173
(x173(x173(x174)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))((x175->x175(
(x176->(x177->x177)))((x178->x178((x179->(x180->x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179
(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179
(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179
(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179
(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179
(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x179(x180))))))))))))))))))))))))))))))))))
)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))((x181->x181((x182->
(x183->x183)))((x184->x184((x185->(x186->x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185
(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185
(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185
(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x185(x186))))))))))))))
))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))((x187->x187((x188->(x189->x189)))((x190->x190(
(x191->(x192->x191(x191(x191(x191(x191(x191(x191(x191(x191(x191(x191(x192))))))))))))))((x193->x193((x194->
(x195->x195)))((x196->x196((x197->(x198->x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197
(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197
(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197
(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197
(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197(x197
(x197(x197(x197(x198)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
))))))))))))))((x199->x199((x200->(x201->x201)))((x202->x202((x203->(x204->x203(x203(x203(x203(x203(x203(x203
(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203
(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203
(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203(x203
(x203(x203(x203(x203(x203(x203(x204))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
)))))((x205->x205((x206->(x207->x206)))((x208->(x209->x208)))))))))))))))))))))))))))))))))))))))))))))))))))
))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
```
{% endcapture %}

<details>
<summary>See <strong>Hyuge</strong> lambda expression:</summary>
{{ code | markdownify }}
</details>

Finally! Patterns! It doesn't take a seer to guess that this probably represents the string that `verify` is checking user input against, which is the flag!

The lambda expression consists of a lot of repeated applications of a function, like `f(f(f(...)))`. One can guess that the string is encoded with [Church Encoding](https://en.wikipedia.org/wiki/Church_encoding), though it is also feasible to reverse that out without guessing, since it's relatively readable now.

Reversing further will find that I represented the flag as a linked list of integers. You can read the article I linked above about _Church Encoding_ on how exactly I did that.

Getting out the array of integers in that lambda expression is relatively striaght-forward:

```py
lambda_expression = "(x0->(x1->x1((x2->(x3-> ... )))))))))))))))"
nums = [lambda_expression.count(f"x{i}(") for i in range(208)]
nums = [i for i in nums if i>2] # Whatever, crude approximation
print(nums)
print(bytes(nums))

# > [121, 110, 7, 21, 96, 25, 20, 73, 113, 99, 75, 62, 99, 48, 37, 73, 72, 113, 73, 121, 126, 11, 11, 74, 11, 23, 73, 32, 72, 110, 73, 11, 100, 76]
# > b'yn\x07\x15`\x19\x14IqcK>c0%IHqIy~\x0b\x0bJ\x0b\x17I HnI\x0bdL'
```

_Oh_ but the numbers are gibberish! However, recall that while a _Church Encoding_ for an integer is `n_church = f -> x -> f^n(x)`, we still need a way to convert from the _Church Encoding_ to an actual integer! The common way to do it is to simply do `n_church(x -> x+1)(0)`. This would simply apply `x -> x+1`, `n` times to `0` and you'll output the integer `n`. That's not what is happening in the challenge! (I didn't do that to slightly harden the challenge. Tho if you've made it this far, it shouldn't hinder you too much either.)

So, `verify` would have to _Church Encode_ the user input in order to compare the user input with the string within `verify`, or the other way around. Reversing a little more on the `verify` function, specifically this:

```py
o( # char by char loop
    lambda y: lambda z: h(
        e(h(e(h(e(h(h)(e(e))))(h(e(e))(h(e(h))(h(e(h(w)))(e))))(e(w)))))
    )(
        h(e(h(h)(e(h(e(e))(h(e(h))(h(e(h(w)))(e)))))))(
            h(e(e))(h(e(h(h(h)(e(e)))))(e))
        )
    )(
        lambda x: y(z[1:])(x)
    )(
        o( # char -> church loop
            lambda y: lambda m: h(h(e(h))(e))(y(r(m))) if r(m) else w
        )(z[0])
    )
    if z
    else h(e(h(h)(e(e))))(h(e(e))(h(e(h))(h(e(h(w)))(e))))(e)(e)
)
```

Would show that it's the former. Also notice how `r = lambda n: (n + 2022) % 127` is being used? It turns out, `verify` converts the integer `n` into the _Church Encoding_ `f -> x -> f^m(x)`, where `r^m(n) = (n + 2022*m) % 127 = 0`. This means, to convert a _Church Encoded_ `n_church` integer back into an integer in `verify`, you'd do
`n_church(x -> (x - 2022)%127)(0)`, or, since it's easier for us, `(n_church(x -> x+1)(0)*-2022) % 127`.

Fun fact, if I could write the above in SKI combinators, _I would_, but Python doesn't do lazy evaulation properly so that's impossible.

Let's modify the code above to do the latter to get the flag!

```python
lambda_expression = "(x0->(x1->x1((x2->(x3-> ... )))))))))))))))"
nums = [lambda_expression.count(f"x{i}(") for i in range(208)]
nums = [i for i in nums if i>2] # Whatever, crude approximation
nums = [(-i*2022)%127 for i in nums]
print(bytes(nums))

# > b'CTFSG{I_respect_Ur_Cunning_BUT_no}'
```

## The Making

This is **The Fun Part**, it'll take too long to write abt all the detail I wanna write so maybe I'll write a follow up post just on the SKI compiler itself. If you're interested, [here's the source](https://github.com/JuliaPoo/CTFSG-2022-JuliaPoo/blob/master/challenges/Reverse/White-Cage/src/ski/skiio.py)

If you've read the 2nd solution for this challenge you'll know that the challenge is written in SKI Combinators, and implements _Church Encodings_. 

But SKI Combinators is an insanely low level language to write in so I actually wrote my lambda expressions in [Floof](/projects/2021-03-25-floof.html) syntax, an esolang I wrote a while back, and used a compiler I wrote last year, but never published, to compile into SKI Combinators.

> A little on _floof_ syntax: The function $\lambda x. y$ is represented as `[x:y]`. Imo its a way more elegant thing to write.

Once I've got the challenge code, I then made an image of a bird flying out of a cage and formatted the code look like that.

### The Naive Compiler

If you look at the wikipedia page for [Combinatory Logic](https://en.wikipedia.org/wiki/Combinatory_logic#Completeness_of_the_S-K_basis), you'd see a compiler $T$ described in 6 lines:

$$
\begin{aligned}
T[x] &= x \\
T[AB] &= T[A] \: T[B] \\
T[\lambda x. E] &= K \:T[E]  & \text{if x does not occur free in E} \\
T[\lambda x.x] &= I \\
T[\lambda x. \lambda y. E] &= T[\lambda x. T[\lambda y.E]] & \text{if x occurs free in E} \\
T[\lambda x. AB] &= S \: T[\lambda x.A] \: T[\lambda x.B] & \text{if x occurs free in A and B}
\end{aligned}
$$

This is what it looks like compiling the numbers `0` to `3` from church encoding to SKI:

```py
>>> str2str_compile("[f:[x:x]]")
'K(I)'
>>> str2str_compile("[f:[x:f(x)]]")
'S(S(K(S))(S(K(K))(I)))(K(I))'
>>> str2str_compile("[f:[x:f(f(x))]]")
'S(S(K(S))(S(K(K))(I)))(S(S(K(S))(S(K(K))(I)))(K(I)))'
>>> str2str_compile("[f:[x:f(f(f(x)))]]")
'S(S(K(S))(S(K(K))(I)))(S(S(K(S))(S(K(K))(I)))(S(S(K(S))(S(K(K))(I)))(K(I))))'        
>>> len(str2str_compile(church(128)))
2308
```

As you can see, the length of the compiled expression grows pretty quickly. Compiling the number `128` results in an expression of over 2k chars! In fact, simply trying to evaluate the number `33` results in a parsing stack overflow in Python 3.8, let alone evaluating a whole string!

```py
>>> eval(str2str_compile(church(33)))
s_push: parser stack overflow
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
MemoryError
```

Clearly the naive compiler method isn't scalable enough.

### Compiler Optimizations

If you were to take a look at my [compiler](https://github.com/JuliaPoo/CTFSG-2022-JuliaPoo/blob/master/challenges/Reverse/White-Cage/src/ski/skiio.py), which is in need of reorganising, you'd see that a lot of it has to do with optimization, in particular, the compiler optimises based on a set of _Rules_.

```py
def compile_SKI(expr:SKInode_T, optimisation:bool=True) -> SKInode_T:
    opt_rules = [
            Rule("M(L)(N(L))", "S(M)(N)(L)"),
            Rule("S(K(S(K(A))))(S(K(S(K(B))))(C))", "S(K(S(K(S(K(A))(B)))))(C)"),
            Rule("S(K(S(K(A))))(S(K(B)))", "S(K(S(K(A))(B)))"),
            Rule("S(K(A))(K(B))", "K(A(B))"),
            Rule("S(K(A))(I)", "A"),
            Rule("S(S(K(A))(B))(K(C))", "S(K(S(A)(K(C))))(B)"),
            Rule("S(S(I(A)))(I)", "S(S(S)(K))(A)"),
        ] if optimisation else []
    expr = _compile_SKI(expr, opt_rules)
    return expr
```

Every time the compiler does a step in the naive compiler, it traverses the entire [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree) to see if it can apply any of the above rules to simplify the AST. Needless to say this is really slow so I implemented aggressive caching to greatly speed up the optimization.

Here's the results:

```py
>>> str2str_compile("[f:[x:x]]")
'K(I)'
>>> str2str_compile("[f:[x:f(x)]]")
'I'
>>> str2str_compile("[f:[x:f(f(x))]]")
'S(S(K(S))(K))(I)'
>>> str2str_compile("[f:[x:f(f(f(x)))]]")
'S(S(K(S))(K))(S(S(K(S))(K))(I))'
>>> len(str2str_compile(church(128)))
1906
```

Unfortunately, **It's Not Enough** as now our limit is only `99`. An improvement from `33`, but not exactly ideal.

```py
>>> eval(str2str_compile(church(99)))
s_push: parser stack overflow
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
MemoryError
```

### An optimal-ish way to represent a byte in SKI

Remember how a church encoded integer $n$ is simply `[f:[x:f^n(x)]]`? So far we've simply written $n$ as `[f:[x:f(f(f(...(x)...)))]]` and asked the compiler to compile it. That's not ideal, as the starting expression is alr pretty long. Take for example, this expression that represents $8^9 = 134217728$: `[p:p(p([f:[x:f(f(x))]]))]([a:[x:a(a(a)(x))]])`. Clearly this expression is many times more efficient than our naive scheme.

```py
>>> expr = "[p:p(p([f:[x:f(f(x))]]))]([a:[x:a(a(a)(x))]])"
>>> eval(str2str_compile(expr) + "(lambda n:n+1)(0)")
134217728
>>> str2str_compile(expr)
'S(I)(S(I)(K(S(S(K(S))(K))(I))))(S(S(K(S))(K))(S(I)(I)))'
```

To find more efficient representations, am gonna introduce _operations_ on church integers. Take for instance `[n:[f:[x:f(n(f)(x))]]]`. This increments a church numeral. There are also lambda expressions that do addition, multiplication, subtraction, power, etc.

The idea is to find a more efficient representation in the form of these operations. E.g. $8^9$ can be represented as $8^9 = p(p(2)), p(x) = x^{x+1}$, and results in the above concise expression.

I hence basically _bruteforced_ the operations to find the most concise one. I start with a list of church numerals encoded with the naive method, and perform operations on them, saving the shorter one until the list converges.

See [here](/assets/posts/2021-12-30-ctfsg2022-author-writeup/ski-nums.txt) to see the final results. In particular, `128` went down from needing `1906` characters to represent to only `121` characters. The source code for this bruteforce can be found [here](https://github.com/JuliaPoo/CTFSG-2022-JuliaPoo/blob/master/challenges/Reverse/White-Cage/src/gen_nums.py).

I then used this representation to craft the church encoded flag string and used it in the challenge.

# Xor Can't Be That Hard

- Category: **Crypto**
- Difficulty: **1/5** (Personal rating)
- Solved: `11`
- Points: `980`
- Flag: `CTFSG{81aee17d64bd59cd167ffce34523060f7e2bcac0}`

```
XorXorXorXorXorXorXorXorXorXorXorXorXorXorXorXor
```

Players are given a script `xor.py` and a file `ct`. `xor.py` generates a random key and plaintext, and xors the key with the plaintext, and saves the 'encrypted' text into the file `ct`. The key length is random, and the plaintext is made up of a characters in `string.ascii_lowercase + '_- .!?'`. Players are required to decrypt `ct` without the key and find the `sha1` hash of the plaintext.

{% capture code %}
```py
import os
import string
import random
from itertools import cycle
from hashlib import sha1

allowed_chars = string.ascii_lowercase + '_- .!?'
allowed_chars = allowed_chars.encode('utf-8')

xor_enc = lambda pt,key: [x^y for x,y in zip(pt, cycle(key))]

pt  = [allowed_chars[i&31] for i in os.urandom(0x100000)]
key = os.urandom(random.randint(10,0x1000))

ct = xor_enc(pt, key)

open('flag', 'w').write(f"CTFSG{sha1(bytes(pt)).hexdigest()}")
open('ct', 'wb').write(bytes(ct))
```
{% endcapture %}

<details>
<summary>See here for the challenge file:</summary>
{{ code | markdownify }}
</details>

## Solution

### Finding the key length

Since the plaintext is made up of only printable characters, the `MSB` of each char is always `0`. Hence, upon xor-encrypt with the key, the `MSB` of each 'block', which is the same length as the key, should always be the same. We can use this property to find the key length.

For each character of the key, we can guess among the `256` possibilities. We'd know that a guess is correct if when we decrypt all the `ct` bytes that got xored by said key character, they are all within `allowed_chars`.

Upon recovering the key, we can simply compute the `sha1` hash and get the flag.

{% capture code %}
```py
from itertools import cycle
import string
from hashlib import sha1

ct = open("../dist/ct", 'rb').read()
allowed_chars = string.ascii_lowercase + '_- .!?'
allowed_chars = allowed_chars.encode()

def is_key_len(ct_msb, klen):
    for x,y in zip(ct_msb[:klen], ct_msb[klen:2*klen]):
        if x!=y: return False
    return True

ct_msb = [x >> 7 for x in ct[:0x20000]]
klen = 10
while not is_key_len(ct_msb, klen): 
    klen += 1
print("Key length:", klen)

# p^k = c
# Find for possible p, the possible k given c
c_to_k = {}
for p in allowed_chars:
    for k in range(0x100):
        c = p^k
        if c not in c_to_k:
            c_to_k[c] = set()
        c_to_k[c].add(k)

# Recover the key
key = []
for kidx in range(klen):
    data = ct[kidx::klen]
    k = c_to_k[data[0]].copy()
    for c in data[1:]:
        k &= c_to_k[c]
    assert len(k) == 1, "Not enough info!"
    key.append(list(k)[0])

# Recover secret
pt = [c^k for c,k in zip(ct, cycle(key))]
flag = f"CTFSG{sha1(bytes(pt)).hexdigest()}"
print(flag)
```
{% endcapture %}

<details>
<summary>See here for the solve script:</summary>
{{ code | markdownify }}
</details>


# Roll Your Own AE

- Category: **Crypto**
- Difficulty: **3/5** (Personal rating)
- Solved: `2`
- Points: `1000`
- Flag: `CTFSG{d0_n0t_r0ll_y0ur_0wn_ae_ev4r}`

```
Okay so you've heard of AE? It's so in right now.
Even Signal uses AES-CBC HMAC-SHA256.
I too, wanna use AES-CBC HMAC-SHA256,
but python doesn't really have one built in.

EZ, I made mah own.
With some goodies too!

1. Random IVs!
2. Salted keys!
3. Unknown padding! (No padding oracles here!)

This is obviously so secure right now.

http://chals.ctf.sg:10201
```

This challenge is based on the [Cryptographic Doom Principle](https://moxie.org/2011/12/13/the-cryptographic-doom-principle.html).

Players are given a http server to interact with and the source code for the server. The server assumes the player's name is Ash, and prompts the player to change their name. The player's name is stored as a cookie, which is an encrypted string containing the `username` and the `flag`. The player's goal is to exploit the decryption routine to leak the `flag`.

This is my attempt at writing a "_realistic_" challenge that isn't too unwieldy. There's a common problem in the industry where developers combine otherwise secure cryptographic primitives together in insecure ways, and am tryna emulate that.

{% capture code %}
```py
from Crypto.Cipher import AES
from urllib import parse
import base64
import hmac
import re
import os

import secret # Only the server has this >-<

from flask import Flask
from flask import request, make_response, render_template
app = Flask(__name__, template_folder='templates/')

class CryptError(Exception):
    pass
    
class CookieError(Exception):
    pass

class Crypt:
    
    '''
    Encrypt/Decrypt object that totally securely
    implements AES-CBC HMAC-SHA256 yall:
    
    Encrypted message format:
        final_encrypt  = [salt:16][iv:16][encrypted_data]
        encrypted_data = AESCBC(PAD([len:2][data][hmac:32]))
        hmac           = HMACSHA256([len:2][data])
        
    Awesome features of this implementation:
        1. Random IVs!
        2. Salted keys!
        3. Unknown padding! (No padding oracles here!)
    '''
    
    def __init__(self, key:bytes):
        if len(key) != 16:
            raise CryptError("Invalid key size. `key` has to be 16 bytes.")
        self.key = key
    
    @staticmethod
    def _pad(data:bytes)->bytes:
        
        '''
        Pads `data` to blocksize 16 with random
        bytes. No padding oracle attack here >-<
        '''
        
        i = -len(data)%16
        return data+os.urandom(i)
    
    @staticmethod
    def _unpad(data:bytes, length:int)->bytes:
        '''
        Unpads `data`. `length` must be given as
        self._pad pads with random bytes.
        '''
        return data[:length]
    
    def _AESCBC(self, data:bytes, salt:bytes, decrypt=False)->bytes:
        
        '''
        Encrypts/decrypts `data` with self.key
        If `decrypt` == False (default), 
          `data` is encrypted with AES-CBC and 
          the iv appended to the start.
        If `decrypt` == True,
          `data` is decrypted, assuming the iv is
          the first 16 bytes of `data`
        '''
        
        iv = data[:16] if decrypt else os.urandom(16)
        cipher = AES.new(self.key+salt, AES.MODE_CBC, iv=iv)
        if decrypt:
            return cipher.decrypt(data[16:])
        return iv + cipher.encrypt(data)
    
    def _HMAC(self, data:bytes, salt:bytes)->bytes:
        
        '''
        Returns HMAC-SHA256 of `data`
        '''
        
        auth = hmac.new(self.key+salt, digestmod='sha256')
        auth.update(data)
        return auth.digest()
    
    def encrypt(self, data:bytes)->bytes:
        
        '''Encrypts `data`'''
        
        length = len(data)+34
        if not (length < 1<<16):
            raise CryptError("Encryption of `data` length %d>%d not supported"%(length, 1<<16))
        
        # Generate salt
        salt = os.urandom(16)
        
        # Add length field
        data = length.to_bytes(2, 'little') + data
        
        # Generate signature
        hmac = self._HMAC(data, salt)
        data += hmac
        
        # Pad and AES encrypt
        data = self._pad(data)
        data = self._AESCBC(data, salt)
        
        # Add salt to data and return
        return salt+data
    
    def decrypt(self, data:bytes)->bytes:
        
        '''Decrypts data and verifies signature'''

        if len(data)%16 != 0 and len(data)>=80:
            raise CryptError("`data` has to be multiple of 16 and at least length 80")
        
        # Get salt
        salt, data = data[:16], data[16:]
        
        # Verify length field before unpadding
        data = self._AESCBC(data, salt, decrypt=True)
        length = int.from_bytes(data[:2], 'little')
        if not (len(data) < 1<<16 and len(data)-16 < length <= len(data)):
            raise CryptError("`data` has invalid length")
        
        # Unpad data
        data = self._unpad(data, length)
        
        # Verify hmac
        data, hmac = data[:-32], data[-32:]
        if not hmac == self._HMAC(data, salt):
            raise CryptError("`data` does not have a valid signature")
        
        # Remove length field
        data = data[2:]
        return data

class Cookie:

    def __init__(self):
        self.crypt = Crypt(secret.key)
        self.data = None
        pass

    def parse(self, cookie:str)->bool:

        '''
        Parses `cookie`.
            Inits self.cookie, self.data.
        @Returns bool
            True if success
            False if fail. Error can be accessed at self.error
        '''

        self.cookie = cookie
        try:
            cookie = base64.b64decode(cookie+'='*4) # fix padding
        except Exception as e:
            self.error = e
            return False

        try:
            serialized = self.crypt.decrypt(cookie).decode('utf-8', errors='ignore')
        except CryptError as e:
            self.error = e
            return False

        self.data = dict(parse.parse_qsl(serialized, strict_parsing=True))

        return True

    def gen(self, username:str)->bool:

        '''
        Generates cookie based on `username`.
            Inits self.cookie, self.data.
        @Returns bool
            True if success
            False if fail. Error can be accessed at self.error
        '''

        naked_flag = re.findall(r"^CTFSG\{([a-z0-9_]+)\}$", secret.flag)[0]
        self.data = {
            "username": username,
            "flag": naked_flag,
            "placeholder": "yo!~~"
        }
        serialized = parse.urlencode(self.data).encode('utf-8', errors='ignore')

        try:
            cookie = self.crypt.encrypt(serialized)
        except CryptError as e:
            self.error = e
            return False

        self.cookie = base64.b64encode(cookie)
        return True

    def get(self, param:str):

        '''
        Gets `param` from cookie
        @Returns bool
            True if success
            False if fail. Error can be accessed at self.error
        '''

        try:
            if type(self.data) != dict:
                raise CookieError("Cookie not initialised! Call self.gen or self.parse")

            if param not in self.data:
                raise CookieError("Param `%s` not in cookie!"%param)
        except CookieError as e:
            self.error = e
            return False, None

        return True, self.data[param]
        

@app.route('/', methods=['POST', 'GET'])
def index():

    cookie = Cookie()
    status = True
    username = None

    if request.method=='POST' and 'username' in request.form:
        username = request.form['username']
        status &= cookie.gen(username)
    else:
        user = request.cookies.get('user')
        status &= cookie.parse(user) if user else cookie.gen("Ash")
    
    if status:
        status, username = cookie.get("username")

    error = None if status else str(cookie.error)
    if not status:
        cookie.gen('Ash')
        _,username = cookie.get("username")

    resp = make_response(
             render_template(
               "index.html", 
               username=username,
               error=error
             )
           )
    resp.set_cookie("user", cookie.cookie)
    return resp
```
{% endcapture %}

<details>
<summary>See here for the challenge file:</summary>
{{ code | markdownify }}
</details>

## Solution

### The Decryption Routine

The data that is being encrypted has this format: `b'username={username}&flag={flag}&placeholder=yo%21~~'`, and obviously we wanna leak the `flag` parameter.

The server code also documents the encrypted message format:

```
Encrypted message format:
    final_encrypt  = [salt:16][iv:16][encrypted_data]
    encrypted_data = AESCBC(PAD([len:2][data][hmac:32]))
    hmac           = HMACSHA256([len:2][data])
```

And the decryption routine:

```py
def decrypt(self, data:bytes)->bytes:
        
    '''Decrypts data and verifies signature'''

    if len(data)%16 != 0 and len(data)>=80:
        raise CryptError("`data` has to be multiple of 16 and at least length 80")
    
    # Get salt
    salt, data = data[:16], data[16:]
    
    # Verify length field before unpadding
    data = self._AESCBC(data, salt, decrypt=True)
    length = int.from_bytes(data[:2], 'little')
    if not (len(data) < 1<<16 and len(data)-16 < length <= len(data)):
        raise CryptError("`data` has invalid length")
    
    # Unpad data
    data = self._unpad(data, length)
    
    # Verify hmac
    data, hmac = data[:-32], data[-32:]
    if not hmac == self._HMAC(data, salt):
        raise CryptError("`data` does not have a valid signature")
    
    # Remove length field
    data = data[2:]
    return data
```

As you can see the encrypted message is "verified" by the `hmac` parameter, so if you were to change the ciphertext, the server will error out at `data does not have a valid signature` as the hmac won't match. Furthermore, the padding consists of random bytes, and so in order for the decryption routine to unpad the message, the length of the `data` has to be stored within the encrypted message format.

However, note that the `hmac` is computed on the **decrypted data**. This means that, in order for the server to verify the `hmac`, it has to first decrypt the data, and then compute the `hmac`. Notice anything dangerous in this design choice? Can you leak any information about the decrypted data before the `hmac` is computed?

Turns out the `length` field is one part of the decrypted data that is being leaked! If the server returns no errors or a `data does not have a valid signature` error, we _know_ that the length field has to satisfy this check: `if not (len(data) < 1<<16 and len(data)-16 < length <= len(data))`, otherwise the server would have returned a `data has invalid length` error!

So what if we can trick the server into thinking the `length` field is something else, like the flag? Then we can leak information about the flag!

### Exploit!

Because the encryption algorithm uses the [CBC Block Ciphering Mode](https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Cipher_block_chaining_(CBC)), we could easily have the server decrypt from a random block in the encryption instead of from the start. We do this simply by feeding the previous block as the IV.

Here's what we can do:

1. Specify the `username` to be a length such that the server intepretes one of the chars of the flag to be the length field if you start decrypting from another block.
2. Guess the value of the first char of the flag. Pad the cookie such that the server won't complain about the length of the data if the guess is correct.
3. If the error returned is `data has invalid length`, the guess is wrong: Guess again. Otherwise repeat for the next chars.

It's a little finicky to get all the offsets right but once done, the flag can be recovered in ~700 requests to the server.

{% capture code %}
```py
import requests
import base64
from threading import Thread

URL = "http://192.168.1.112:7777"
n_requests = 0


def get_cookie(username: bytes):

    global n_requests
    n_requests += 1

    r = requests.post(URL, data={b'username': username})
    return base64.b64decode(r.cookies['user'])


def test_cookie(cookie):

    global n_requests
    n_requests += 1

    cookie = base64.b64encode(cookie).decode('utf-8')
    r = requests.get(URL, cookies={'user': cookie})
    content = r.content.decode('utf-8')

    if "An error occurred!" not in content:
        return 0  # No error
    if "`data` has invalid length" in content:
        return 1  # Length invalid
    if "`data` does not have a valid signature" in content:
        return 2  # Length valid

    return 3  # Should not be encountering this case


def pad(data: bytes):
    i = -len(data) % 16
    return data + b'\0'*i


def job(c: int, send: bytes):
    global job_ret
    if job_ret:
        return
    case = test_cookie(send)
    if case == 2:
        job_ret = c  # Valid length! value of `c` has been leaked!


allowed = b'0123456789_qwertyuiopasdfghjklzxcvbnm?'
known = ord(b'=')
k = 6

flag = ""
idx = 0
while True:

    enc = get_cookie(b'A'*(64-idx))
    salt = enc[:16]
    curr = enc[16*k:16*k+32]

    threads = []
    job_ret = None
    for c in allowed:
        i = c*0x100 + known - 16
        send = salt + curr + b'\0'*i
        send = pad(send)
        threads.append(Thread(target=job, args=(c, send)))
    for t in threads:
        t.start()
    for t in threads:
        t.join()

    known = job_ret
    # None of `allowed` matches. End of flag.
    if not known:
        break

    flag += chr(known)
    idx += 1
    print(flag, end="\r")


print(f"Flag: CTFSG{flag}")
print("Number of requests made:", n_requests)
```
{% endcapture %}

<details>
<summary>See here for the solve script:</summary>
{{ code | markdownify }}
</details>

# Textbook RSA

- Category: **Crypto**
- Difficulty: **4/5** (Personal rating)
- Solved: `2`
- Points: `1000`
- Flag: `CTFSG{https://arxiv.org/abs/1802.03367?salt=290nlk01nx}`

```
Two times the RSA mean two times the security.

Connect to the service at:
chals.ctf.sg:10301
```

The player is given a server to connect to and the source code to said server. The server pads the `flag` with a half-assed [OAEP](https://en.wikipedia.org/wiki/Optimal_asymmetric_encryption_padding) so it's reasonably secure. 

The server then encrypts the flag with a keys `pub1, priv1`, and then encrypts `priv1` with keys `pub2, priv2`.
The encrypted flag, encrypted `priv1`, and both public keys are made known to the player.

The server then repeatedly asks for `enc_priv1` and tries to decrypt `flag` with the player's input for `enc_priv1`.
If the decrypted flag matches the actual `flag`, the server exits.

{% capture code %}
```py
from typing import Tuple

from Crypto.Util.number import bytes_to_long, getPrime
from os import urandom
from hashlib import shake_128

from flag import flag

e = 1+(1 << 16)
def xor_bytes(a, b): return type(a)([x ^ y for x, y in zip(a, b)])


def gen(strength: int) -> Tuple[int, int]:

    p = getPrime(strength)
    q = getPrime(strength)
    n = p*q
    phi = n - p - q + 1
    d = pow(e, -1, phi)

    return n, d


def pad(msg: bytes) -> bytes:

    # Yea I made the padding really hard to attack,
    # so don't attack it

    assert len(msg) < 60

    l = 76-len(msg)-8
    msg = bytearray(
        msg + urandom(8) + bytes([l]*l)
    )
    msg[:38] = xor_bytes(msg[:38], shake_128(msg[38:]).digest(38))
    msg[38:] = xor_bytes(msg[38:], shake_128(msg[:38]).digest(38))
    return bytes(msg)


def unpad(msg: bytes) -> bytes:
    msg = bytearray(msg)
    msg[38:] = xor_bytes(msg[38:], shake_128(msg[:38]).digest(38))
    msg[:38] = xor_bytes(msg[:38], shake_128(msg[38:]).digest(38))
    msg = msg[:-msg[-1]-8]
    return bytes(msg)


def rsa_enc(pub: int, msg: int) -> int:
    assert msg < pub, "Error encrypting!"
    return pow(msg, e, pub)


def rsa_dec(pub: int, priv: int, msg: int) -> int:
    assert msg < pub and priv < pub, "Error decrypting"
    return pow(msg, priv, pub)


def main():

    pflag = bytes_to_long(pad(flag))

    # 306>305 so it doesn't error out on
    # rsa_dec(pub2, priv2, enc_priv1)
    pub1, priv1 = gen(305)
    pub2, priv2 = gen(306)

    enc_flag = rsa_enc(pub1, pflag)
    enc_priv1 = rsa_enc(pub2, priv1)

    print("enc_flag =", hex(enc_flag))
    print("enc_priv1 =", hex(enc_priv1))
    print("pub1 =", hex(pub1))
    print("pub2 =", hex(pub2))

    while True:

        while not (user_in := input("enc_priv1: ")).isdigit():
            ...
        user_in = int(user_in)

        dflag = 0
        try:
            dec_priv1 = rsa_dec(pub2, priv2, user_in)
            dflag = rsa_dec(pub1, dec_priv1, enc_flag)
        except AssertionError as e:
            print(f"[x] Error! {e}")
            continue

        if dflag == pflag:
            break

        print("[*] Wrong!")

    print("[*] Byeeee ^-^")
    print("[*] Remember to get the flag on your way out!")


if __name__ == "__main__":
    main()
```
{% endcapture %}

<details>
<summary>See here for the challenge file:</summary>
{{ code | markdownify }}
</details>

## Solution

So clearly the server never actually prints the flag so the player has to somehow leak the flag in the main loop. I wanna bring our attention to this few lines:

```py
def rsa_dec(pub: int, priv: int, msg: int) -> int:
    assert msg < pub and priv < pub, "Error decrypting"
    return pow(msg, priv, pub)

...

# 306>305 so it doesn't error out on
# rsa_dec(pub2, priv2, enc_priv1)
pub1, priv1 = gen(305)
pub2, priv2 = gen(306)

enc_flag = rsa_enc(pub1, pflag)
enc_priv1 = rsa_enc(pub2, priv1)
```

Note that when encrypting `priv1`, `priv1` isn't padded? We're gonna exploit this. Furthermore, notice that `priv1 < pub2`. This is so that `priv1` is always small enough to be encrypted by `pub2` (and not loop around). However, this also implies that it is possible to feed the server a `enc_priv1` value that results in `priv1 > pub1`. Refering to the `rsa_dec` function, this would result in the server raising `Error decrypting`. We can use whether or not the error appears to perform the [Bleichenbacher's Attack](http://archiv.infsec.ethz.ch/education/fs08/secsem/bleichenbacher98.pdf).

The idea behind _Bleichenbacher's Attack_ is very simple. If we can get reduce the possible values of the plaintext by mutating the ciphertext and querying the server, we could repeat that until the number of possible values is small enough to bruteforce.

So how can we reduce the search space on `priv1` from the server?

RSA has this unfortunate property whereby mutating the ciphertext can have very predictable outcomes on the plaintext. This is [one of many reason why I hate RSA](https://blog.trailofbits.com/2019/07/08/fuck-rsa/). (_I wanted to write an article about why we should stop teaching RSA as The Encryption to students but **Trail Of Bits** already beat me to that_).

From now on, I'll be refering to `pub1` and `pub2` as $n_1$ and $n_2$, and `priv1` and `priv2` as $d_1$ and $d_2$, and `enc_priv1` as $c$.

If you were to send the server $c' = c x^e \text{ mod } n_2$, the server will decrypt $d_1' = d_1 c \text{ mod } n_2$. If $d_1' > n_1$, the server will throw `Error decrypting`.

Now say for a given $x_l \le x < x_h$, the server doesn't throw `Error decrypting` but will for $x_h$. Then we can infer that:

$$
\begin{aligned}
x_h d_1 &\ge n_1 \quad \text{ mod } n_2 \\
x_h d_1 - n_2 k &\ge n_1 \quad \text{ for one of integer } 0 \le k \le \frac{x_h d_1 - n_1}{n_2} < x_h - \frac{n_1}{n_2} \\
d_1 &\ge \frac{n_1 + n_2k}{x_h}
\end{aligned}
$$

Similarly,

$$
\begin{aligned}
x_l d_1 &\le n_1 \quad \text{ mod } n_2 \\
x_l d_1 - n_2 k &\le n_1 \quad \text{ for one of integer } 0 \le k \le \frac{x_l d_1 - n_1}{n_2} < x_l - \frac{n_1}{n_2} \\
d_1 &\le \frac{n_1 + n_2k}{x_l}
\end{aligned}
$$

Since for all $x_l \le x < x_h$ the server doesn't throw `Error decrypting`, the $k$ value would be the same for both the upper and lower bound. For simplicity of implementation, we shall say that

$$
d_1 \in \bigcup_{k = 0} ^ {\lfloor  x_h - n_1/n_2 \rfloor} \left[\frac{n_1 + n_2k}{x_h}, \frac{n_1 + n_2k}{x_l}\right] \quad -(1)
$$

which isn't as tight as is possible, but it's sufficient. Now we just repeat this for progressively bigger and bigger $x$ until our search space reduces to a bruteforcable amount. I chose to increase $x$ by a factor of $\lfloor n2/n1 \rfloor$ each time. However, sometimes this is too fast, as it would take too long to compute the intersection of the sets $(1)$. If that happens, I simply rerun the solution script.

`priv1` and hence the flag can be recovered from the server in ~1000 to ~3000 requests.

```
> python sol.py
[*] Queried server 1073 times!
[*] Flag: CTFSG{https://arxiv.org/abs/1802.03367?salt=290nlk01nx}
```

{% capture code %}
```py
from hashlib import shake_128
from Crypto.Util.number import long_to_bytes
from typing import Tuple
from nclib import Netcat
from libnum.ranges import Ranges

NC = ("192.168.139.128", 7777)

# Let p be priv1,
#     c be enc_priv1,
#     d be priv2,
#     n2 be pub2,
#     n1 be pub1

# c^d = p
# (x^e c)^d = x^ed c^d = xp
# If it does not error from xl to xh-1, but does so at xh,
# then xl*p - n2*k < n1 <= xh*p - n2*k:
#
#    Upper:
#    xh*p - n2*k >= n1, k <= (xh*p - n1) / n2, p >= (n1 + n2*k) / xh
#        Since 0 < p < n2, 0 <= k <= (xh*p - n1) / n2 < xh - n1/n2
#
#    Lower:
#    xl&p - n2*k < n1, _, p < (n1 + n2*k) / xl
#
#    For 0 < k < x - n1/n2:
#       (n1 + n2*k) / xh <= p < (n1 + n2*k) / xl


def ru(nc: Netcat, b: bytes) -> bytes:
    """recieve until"""

    s = b""
    while b not in s:
        s += nc.recv(1)
    return s[:-len(b)]


def init_nc() -> Netcat:
    return Netcat(NC)


def get_constants_from_server(nc: Netcat) -> Tuple[int, int, int, int]:

    ctn = ru(nc, b"enc_priv1: ").decode()
    ctn = ctn.split("\n")
    enc_flag = int(ctn[0].split("=")[1], 16)
    enc_priv1 = int(ctn[1].split("=")[1], 16)
    pub1 = int(ctn[2].split("=")[1], 16)
    pub2 = int(ctn[3].split("=")[1], 16)
    return enc_flag, enc_priv1, pub1, pub2


nquery = 0
def test_waters(nc: Netcat, x: int) -> int:

    global nquery
    nquery += 1
    tosend = (pow(x, 0x10001, n2)*c) % n2

    nc.send(str(tosend).encode() + b"\n")
    res = ru(nc, b"enc_priv1: ").decode().strip()

    if res == "[x] Error! Error decrypting":
        return 0
    if res == "[*] Wrong!":
        return 1
    return 2


def get_x(nc: Netcat, start: int) -> Tuple[int, int]:

    x = 0
    while True:

        res = test_waters(nc, x+start)
        if x == 0 and res == 0:
            start += 1
            continue

        if res == 0:
            break

        x += 1

    return start, x+start


def improve_range(nc: Netcat, start: int, r: Ranges) -> Tuple[int, Ranges]:

    xl, xh = get_x(nc, start)

    nr = Ranges()
    for rl, rh in r._segments:

        # (n1 + n2*kl)/xl + 1 > rl
        # kl > ((rl-1)*xl - n1) / n2
        kl = ((rl-1)*xl - n1) // n2 + 1

        # ((n1 + n2*kh)//xh + 1 < rh
        # kh < ((rh-1)*xh - n1) / n2
        kh = ((rh-1)*xh - n1) // n2

        for k in range(kl, kh+1):
            al, ah = (n1 + n2*k)//xh + 1, (n1 + n2*k)//xl
            al, ah = max(rl, al), min(rh, ah)
            nr = nr | Ranges((al, ah))

    return xh, nr


def xor_bytes(a, b): return type(a)([x ^ y for x, y in zip(a, b)])
def unpad(msg: bytes) -> bytes:
    msg = bytearray(msg)
    msg[38:] = xor_bytes(msg[38:], shake_128(msg[:38]).digest(38))
    msg[:38] = xor_bytes(msg[:38], shake_128(msg[38:]).digest(38))
    msg = msg[:-msg[-1]-8]
    return bytes(msg)


def rsa_dec(pub: int, priv: int, msg: int) -> int:
    assert msg < pub and priv < pub, "Error decrypting"
    return pow(msg, priv, pub)


nc = init_nc()
f, c, n1, n2 = get_constants_from_server(nc)

growth = int(n2//n1)
while True:

    assert growth >= 2, "[x] Ratio between n1 and n2 not big enough!"

    r = Ranges((0, n1))
    xh = 2
    i = 0

    succ = True
    while r.len > 1 << 10:

        lr = len(r._segments)
        bl = xh.bit_length()
        print(f"{i} {lr} {bl} ~{int(bl/602*100+.5)}% {nquery} queries \r", end="")
        i += 1

        if lr >= 20:  # Growth rate too fast!
            print(f"[*] Growth rate `{growth}` too big!")
            print(f"[*] Potential unlucky run, consider rerunning if it takes too long.")
            growth -= 1
            succ = False
            break

        xh, r = improve_range(nc, xh, r)
        xh = xh*growth

    if succ:
        break

print(f"[*] Queried server {nquery} times!")

for p in r:
    flag = rsa_dec(n1, p, f)
    flag = unpad(long_to_bytes(flag))
    if b"CTFSG" in flag:
        break

print("[*] Flag:", flag.decode())
```
{% endcapture %}

<details>
<summary>See here for the solve script:</summary>
{{ code | markdownify }}
</details>

# SHA-CBC

- Category: **Crypto**
- Difficulty: **5/5** (Personal rating)
- Solved: `1`
- Points: `1000`
- Flag: `CTFSG{Oh I gUesS I hAVe alwAys likEd pOurIng ThingS inTo oTher ThiNgs}`

```
Luz attempted to implement SHA-CBC. It's like AES-CBC but with SHAKE-128 instead.
Luz got as far as implementing the encryption before Luz realised:
SHAKE-128 isn't symmetric like AES is.
Luz can't write the decryption at all.
Even if Luz knew the key.

Luz, being overzealous, Luz encrypted the flag and threw it away.

Have fun recovering it.
```

Players are given a file `flag.enc` which contains the encryption of the flag (without the `CTFSG{...}` prefix and suffix) repeated `100000` times. The encryption algo uses the `CBC` block ciphering mode but with `SHAKE-128` as the primitive instead of `AES`. The block length is `4` bytes.

{% capture code %}
```py
import hashlib
import re

class SHACBC:

    def __init__(self, key:bytes, block_size:int):
        self.bz = block_size
        self.key = key
        
    def _gethash(self, block:bytes):
        return hashlib.shake_128(self.key+block).digest(self.bz)
        
    def _pad(self, pt:bytes):
        padlen = (-len(pt))%self.bz
        return pt + b'\0'*padlen
    
    def encrypt(self, pt:bytes):

        ct = b""
        prev_ct_blk = b"\0"*self.bz
        pt = self._pad(pt)
        pt = [pt[i*self.bz : (i+1)*self.bz] for i in range(len(pt)//self.bz)]
        
        for blk in pt:
            xored = bytes([x^y for x,y in zip(prev_ct_blk, blk)])
            prev_ct_blk = self._gethash(xored)
            ct += prev_ct_blk

        return ct

    def decrypt(self, ct:bytes):

        "Oh no"

flag = open('flag').read()
match = re.match(r"^CTFSG\{([a-zA-Z ]+)\}$", flag)
assert match, "`flag` doesn't follow flag format!"

naked_flag = match.group(1)
naked_flag = naked_flag.encode('utf-8')

key = open('key', 'rb').read()

s  = SHACBC(key, 4)
pt = naked_flag*100000
ct = s.encrypt(pt)

open('flag.enc', 'wb').write(ct)
```
{% endcapture %}

<details>
<summary>See here for the challenge file:</summary>
{{ code | markdownify }}
</details>

## Solution

So since `SHAKE-128` is a hashing function, there is no hope in writing a decryption routine. Furthermore, because of the usage of an unknown key, rainbow tables aren't possible either. However, the block length is suspiciously small, meaning there's a huge chance for block collisions.

<center>
<img src="/assets/posts/2021-12-30-ctfsg2022-author-writeup/CBC_encryption.svg" alt="CBC Encryption diagram">
</center>

Refering to the image above, there are three reasons for ciphertext block collision:

1. Block cipher hash collision, two different input into the block cipher resulted in the same hash
2. Collision in the input of the block cipher whereby the ciphertext blocks that were xored with the plaintext are different.
3. Collision in the input of the block cipher where both the ciphertext blocks and the plaintext that were xored together are the same.

Only collisions resulting from reason $(2)$ leaks information about the flag. Say ciphertext blocks $c_i$ and $c_j$ collide via reason $(2)$. Then we know that $c_{i-1} \oplus p_i = c_{j-1} \oplus p_j, \; p_i \oplus p_j = c_{i-1} \oplus c_{j-1}$. Since we know the $rhs$, we've obtain a constraint on the plaintext, i.e. the flag.

However, we still need to differentiate collisions resulting from reason $(2)$ from $(1)$ and $(3)$. Due to the repetitive nature of the plaintext (it's just the flag times `100000`), we expect to see _a lot_ of collisions from reason $(3)$. Luckily, we can differentiate reason $(3)$ by checking if $c_{i-1} = c_{j-1}$.

Unfortunately, there doesn't seem to be a way to distinguish reason $(1)$. After removing all collisions from reason $(3)$, there are about $130$ collisions, of which half of which we expect to be from reason $(2)$ since $(1)$ and $(2)$ occur roughly with the same probability.

If we were to treat all $130$ collisions as being from reason $(2)$, we find that there are _**no**_ solutions for the flag. We hence need to find a way to seperate collisions from reason $(1)$ and $(2)$. Let's assume there is a unique solution for the flag. Then there exists a locally maximal subset of collisions which, if treated as all from reason $(2)$, contains a unique solution which is the flag.

We can achieve this via depth first search. Start with a random collision and assume it is from reason $(2)$. We progressively add another one until there are no solutions. We can then remove the latest one we added, and try adding another one. If we can't add any more collisions, we've reached a locally maximal subset, and we print the solutions. After that, we simply try another branch.

Doing so, we find that $63$ out of the $130$ collisions resulted from reason $(2)$.

```
> python solve.py
Found 130 potential collisions
New depth reached, 67 constraints left
Possible flag: CTF{Oh I gUesS I hAVe alwAys likEd pOurIng ThingS inTo oTher ThiNgs}
Done
```

{% capture code %}
```py
import z3

# Init parameters
ct = open('../dist/flag.enc','rb').read()
blksize = 4
n = 100000
iv = b'\0'*4
allowed = b"qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM "

# Get cipher text blocks
cblks = [ct[i*blksize:(i+1)*blksize] for i in range(len(ct) // blksize)]
# Don't consider collisions from blocks with too high frequency
# as that would probably be from same-input collisions.

# Init symbolic flag
flag_len = len(ct)//n
flag_sym = [z3.BitVec("f%02d"%i, 8) for i in range(flag_len)]

# Get all collisions
# This cannot distinguish identical cipher text blocks due to
# hash collisions or input collisions (input = xor(prev_plaintext_blk, curr_ciphertext_blk))
# We only want input collisions as that leaks plaintext info.
collisions = {}
for idx,blk in enumerate(cblks):
    if blk not in collisions: 
        collisions[blk] = []
    # Remove all collisions that results from reason 3.
    if cblks[idx-1] in [cblks[i-1] for i in collisions[blk]]:
        continue
    collisions[blk].append(idx)
collisions = [idxlist for _, idxlist in collisions.items() if len(idxlist)!=1]

# Flatten collisions into pairs
collisions = [(L[i], L[j]) for L in collisions for i in range(len(L)) for j in range(i+1,len(L))]

print("Found %d potential collisions"%len(collisions))

def init_solver():

    '''
    Init z3 solver and 
    constraint flag to be composed of `allowed` characters
    '''

    s = z3.Solver()
    for c_sym in flag_sym:
        s.add(z3.Or([c_sym == c for c in allowed]))
    return s

def build_constraints(collisions):

    '''
    Returns constraints on `flag_sym` assuming collisions
    are caused by input collisions and not hash collisions
    '''

    constraints = []
    for idxlist in collisions:
        tmp = ()
        prev_blks = [cblks[idx-1] if idx != 0 else iv for idx in idxlist]
        ci,cj = prev_blks[0], prev_blks[1]
        ii,ij = idxlist[0], idxlist[1]
        cxor = [x^y for x,y in zip(ci,cj)]
        for k in range(blksize):
            pi = flag_sym[(ii*blksize + k)%flag_len]
            pj = flag_sym[(ij*blksize + k)%flag_len]
            tmp += (pi^pj == cxor[k],)
        constraints.append(tmp)
    return constraints

def print_sols(solver, n=3):

    '''
    Given a solver, print n solutions for `flag_sym` (default 3)
    '''

    while solver.check()!=z3.unsat and n>0:
        m = solver.model()
        print(f"Possible flag: CTF{
            bytes([m[c].as_long() for c in flag_sym]).decode('utf-8')
        }")
        solver.add(z3.Not(z3.And([m[c]==c for c in flag_sym])))
        n -= 1
    if solver.check()!=z3.unsat:
        print("...")

def recurse(solver, constraints):

    '''
    Recursively tries all maximal subsets of `constraints` that yield a satisfiable model (>0 solutions)
    A maximal subset A of `constraints` means it is impossible to increase the size of subset A
    by adding more constraints from `constraints` such that A still yields a satisfiable model.

    This allows finding a sufficient subset of `constraints` caused by input collisions and not
    hash collisions, recovering the flag.

    Prints solutions reached by these maximal subsets
    Returns True if solver is satisfiable
    '''
    
    # Stores the minimum number of constraints left ever reached.
    global depth_left
    # Stores constraints tried
    global tried
    # Init default globals
    if 'depth_left' not in globals():
        depth_left = len(constraints)
    if 'tried' not in globals():
        tried = []

    # Check if has tried
    s = set(constraints)
    for c in tried:
        if c.issubset(s):
            return True
    # Update tried
    tried.append(s)

    # Stop recursing if solver is already unsatisfiable
    if solver.check()==z3.unsat:
        return True

    # Stop recursing if no constraints are left.
    if len(constraints)==0:
        print_sols(solver)
        return True
    
    print("Constraints left: %d"%len(constraints), end="  \r")

    valid = False
    # Try to append one more constraint from those left
    for c in constraints:
        # Duplicate current solver
        new_solver = solver.translate(z3.main_ctx())
        new_solver.add(c)
        valid != recurse(new_solver, [con for con in constraints if con!=c])

    # None of the new models are satisfiable
    # set of constraints in `solver` is maximal
    if not valid:
        # depth reached before, ignore
        if len(constraints) >= depth_left:
            return True
        # Depth not reached before, print solutions
        depth_left = len(constraints)
        print("New depth reached, %d constraints left"%depth_left)
        print_sols(solver)

    return True


solver = init_solver()
constraints = build_constraints(collisions)
recurse(solver, constraints)
print("Done")
```
{% endcapture %}

> Author's note: During the CTF I realised, since all the constraints are linear, you can just gaussian eliminate to find the largest set of constaints that's satisfiable, no need for all that fancy depth first search.

<details>
<summary>See here for the solve script:</summary>
{{ code | markdownify }}
</details>

<center>
    <img style="height:1.5em; padding-top:3em" src="/assets/img/feather.svg">
</center>