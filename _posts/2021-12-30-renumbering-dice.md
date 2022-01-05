---
layout: post
author: JuliaPoo
category: Unlisted #Mathematics

display-title: "Renumbering Dice"
tags:
    - math
    - combinatorics
    - polynomial-factoring
    - dice

nav: |
    * TODO

excerpt: "An exploration of multiple ways to describe rolling dice, and answering questions on re-numbering dice."
---

<!-- 
TODO:
1. Probability distribution of dice rolling
2. Polynomial way of looking at dice rolling.
3. Dice renumbering problem 1
3. Solving problem 1
4. Dice renumbering problem 2
5. Generalised Number bases
6. Solving problem 2
-->

## Metadata

This post collates some math exploration I did in 2017. They were originally posted on the now defunct forums of [brilliant.org](https://brilliant.org). Due to a series of unfortunate events (and financial incentives) the entire forum had been effectively deleted.

Here I've reorganised my work and added some new stuff.

## Probability distribution of rolling dice.

**_Define_** an $n$-die as a die with $n$ sides.

**_Define_** a _regular_ $n$-die as a die with $n$ sides numbered $\\{1,2,3,\cdots,n\\}$

So a typical way of rolling dice is to take one or more dice, rolling and then summing their results. For instance, a common case is taking two regular 6-die, rolling them and summing the results.

In this example, you can get a $2$ by rolling $(1,1)$, up to a $12$ by rolling $(6,6)$.

However, the probabilities of getting a $2$ through $12$ aren't the same.

{% capture img %}
![two 6-die probabilities](/assets/posts/2021-12-30-renumbering-dice/2-6die.svg)
{% endcapture %}
<center>
{{ img | markdownify }}
</center>

Similarly, rolling more than two 6-die will result in a different probability distribution. For instance, here is three 6-dice:

{% capture img %}
![three 6-die probabilities](/assets/posts/2021-12-30-renumbering-dice/3-6die.svg)
{% endcapture %}
<center>
{{ img | markdownify }}
</center>

There's a generic method to compute this distribution: we could simply tally all possible rolls. For the case of rolling two 6-die, we have $6^2 = 36$ possibilities, each of equal probability. For each possibility, we can find the sum of the results and construct a table as follows:

{% capture tab %}
|<!-- -->|<!-- -->|<!-- -->|<!-- -->|<!-- -->|<!-- -->|<!-- -->|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
||<span class="glow-text">1</span>|<span class="glow-text">2</span>|<span class="glow-text">3</span>|<span class="glow-text">4</span>|<span class="glow-text">5</span>|<span class="glow-text">6</span>|
|<span class="glow-text">1</span>|2|3|4|5|6|7|
|<span class="glow-text">2</span>|3|4|5|6|7|8|
|<span class="glow-text">3</span>|4|5|6|7|8|9|
|<span class="glow-text">4</span>|5|6|7|8|9|10|
|<span class="glow-text">5</span>|6|7|8|9|10|11|
|<span class="glow-text">6</span>|7|8|9|10|11|12|
{% endcapture %}

<center class="table-no-outline table-no-header table-tight table-scrollx">
{{ tab | markdownify }}
</center>

The probability that the result is $n$ is simply the number of times $n$ appears in the table divided by $6^2$.

## Using polynomials instead of a table

You might have noticed that the table is remarkably similar to polynomial multiplication. For instance, try expanding $(x^6+x^5+x^4+x^3+x^2+x^1)^2$. In order to keep track of the coefficients of the final expanded result, you might construct a similar table:

{% capture tab %}
|<!-- -->|<!-- -->|<!-- -->|<!-- -->|<!-- -->|<!-- -->|<!-- -->|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
||<span class="glow-text">1</span>|<span class="glow-text">2</span>|<span class="glow-text">3</span>|<span class="glow-text">4</span>|<span class="glow-text">5</span>|<span class="glow-text">6</span>|
|<span class="glow-text">1</span>|$x^{2}$|$x^{3}$|$x^{4}$|$x^{5}$|$x^{6}$|$x^{7}$|
|<span class="glow-text">2</span>|$x^{3}$|$x^{4}$|$x^{5}$|$x^{6}$|$x^{7}$|$x^{8}$|
|<span class="glow-text">3</span>|$x^{4}$|$x^{5}$|$x^{6}$|$x^{7}$|$x^{8}$|$x^{9}$|
|<span class="glow-text">4</span>|$x^{5}$|$x^{6}$|$x^{7}$|$x^{8}$|$x^{9}$|$x^{10}$|
|<span class="glow-text">5</span>|$x^{6}$|$x^{7}$|$x^{8}$|$x^{9}$|$x^{10}$|$x^{11}$|
|<span class="glow-text">6</span>|$x^{7}$|$x^{8}$|$x^{9}$|$x^{10}$|$x^{11}$|$x^{12}$|
{% endcapture %}

<center class="table-no-header table-no-outline table-scrollx">
{{ tab | markdownify }}
</center>

The coefficient of say $x^5$ is the number of times $x^5$ appears in the table.

Notice how the powers in the table are identical to the previous table? That's bcuz it's exactly the same operation!

### Okay so what

This is great bcuz in our analysis of the probabilty distribution of rolling dice, we could and will map it into a problem about polynomials, which we can analyse with the numerous, powerful methods developed to analyse polynomials.

### An Informal-Formal Formulation

The relation between polynomials and rolling dice can be made explicit as such:

**_Lemma 1_**:

> Let $D_{A}$ be a dice numbered with numbers from the set $A = \\{a_1, a_2, \cdots, a_n\\}$. Let $P(A) = \sum_{a \in A} x^a$ be the polynomial representing the numbers of $D_{A}$.
> 
> Upon rolling $k$ dice $D_{A_1}, D_{A_2}, \cdots, D_{A_k}$ and summing the results, the probability of the result being $r$ is $c_r \prod_{1 \le i \le k}\|A_i\|^{-1}$, where $c_r$ is the coefficient of $x^r$ in the polynomial $\prod_{1 \le i \le k} P(A_i)$.

This relation explicitly converts the probability distribution of rolling dice, into a polynomial.

## Dice Renumbering Problem

Now we're ready to introduce a problem on rolling dice. Many board games require rolling two or three regular 6-dice and taking the sum of the output. 

**_Question 1_**:
> Is there a way to renumber two 6-dice with positive integers such that the sum of results for rolling the two renumbered dice has the same probability distribution as rolling two regular 6-dice?

We could tackle this problem by analysing $p_{6,6} = P(\\{1,2,3,4,5,6\\})^2$, the polynomial that represents the probability distribution of the result upon rolling two regular 6-dice.

Say we have an alternate numbering $D_B$ and $D_C$, $B = \\{b_1,b_2,\cdots,b_6\\}$, $C = \\{c_1,c_2,\cdots,c_6\\}$, then by **_lemma 1_**, we have $p_{6,6} = P(B) P(C) = p_B p_C$. This means that both $p_B$ and $p_C$ are _factors_ of $p_{6,6}$.

We also know that $P(B)$ and $P(C)$ represent numberings on 6-sided dice, so we have the addtional conditions:

1. $p_B\vert_{x=1} = p_C\vert_{x=1} = 6$, on account of being 6-dice.
2. The coefficients of both $p_B$ and $p_C$ must all be positive integers.

We could easily factorize $p_{6,6}$ computationally (or by noting that the factors are [Cyclotomic Polynomials](https://en.wikipedia.org/wiki/Cyclotomic_polynomial)):

$$
p_{6,6} = x^{2} \cdot (x + 1)^{2} \cdot (x^{2} - x + 1)^{2} \cdot (x^{2} + x + 1)^{2}
$$

Thereafter, we can try every combination of $p_B$ and $p_C$ such that the two conditions above are satisfied. This yields the below numberings:

{% capture tab %}
|**$D_B$**| 1| 3| 4| 5| 6| 8|
|**$D_C$**| 1| 2| 2| 3| 3| 4|
||||||||
|**$D_B$**| 1| 2| 3| 4| 5| 6|
|**$D_C$**| 1| 2| 3| 4| 5| 6|
{% endcapture %}

<center class="table-no-outline table-no-header table-scrollx">
{{ tab | markdownify }}
</center>

The second numbering corresponds to regular 6-dice. The first is hence the only numbering possible that answers the question. 

In other words, renumbering the dice $\\{1,3,4,5,6,8\\}$ and $\\{1,2,2,3,3,4\\}$ is the only way to renumber dice with positive integers such that rolling and summing the results is equivalent to using two regular 6-dice.

### General Case

We could renumber dice to emulate other dice as well. For instance, what if we wanna say, emulate a regular 18-die with two 6-dice? We could do a similar analysis as above and find all possible numberings! For the sake of generalisation, we shall relax the condition for numberings to become _non-negative integers_ as opposed to the previous _positive integers_. In other words, we are allowed to number a face $0$.

The generalisation can be written as such:

> How many ways are there to renumber, with non-negative integers, $k$ dice with sides $n_1, n_2, \cdots, n_k$ such that it emulates the rolling and summing of $k'$ regular dice with sides $t_1, t_2, \cdots, t_{k'}$

Here's code to automatically compute the numberings for the general case, written in [Sage](https://www.sagemath.org/):

```python
from sympy.utilities.iterables import multiset_partitions
from collections import Counter
from typing import List

# Work in integer polynomials
x = PolynomialRing(ZZ, 'x').gen()

def dice(n:int) -> "PolynomialZZ":
    
    """Returns polynomial of a regular n-sided die"""
    
    return x*sum(x^i for i in range(n))

def get_numberings(nsides: List[int], tsides: List[int]) -> List[List[int]]:
    
    """
    Returns possible numberings of dice with sides `nsides`
    that when rolled and summed, gives the same distribution as
    regular dice of sides `tsides`
    """
    
    # Check if numberings is even possible
    nx,tx = reduce(lambda a,b: a*b, nsides), reduce(lambda a,b: a*b, tsides)
    assert nx % tx  == 0, \
        "No numberings possible"
    
    # Target distribution
    target = reduce(lambda a,b: a*b, map(dice, tsides)) * (nx//tx)

    # Factors of target distribution
    # Stored as [(factor, sum of coefficients), ...]
    tfactors = [(f,f(1)) for f,c in target.factor() for _ in range(c)]

    tsols = [] # Stores the possible numberings
    _ns = Counter(nsides)
    for ps in multiset_partitions(tfactors, len(nsides)):

        # Skip solutions where new dice don't have `nsides` sides
        ns = [reduce(lambda a,b:a*b[1], p, 1) for p in ps]
        if Counter(ns) != _ns:
            continue

        # Multiply factors together
        ps = [reduce(lambda a,b:a*b[0], p, 1) for p in ps]

        # Skip solutions with negative coefficients
        if min(min(p.coefficients()) for p in ps) < 0:
            continue

        # Convert polynomials to numberings
        tsols.append([
            [c for c,n in p.dict().items() for _ in range(n)]
            for p in ps
        ])
        
    return tsols

def print_numberings(tsols: List[List[int]]) -> None:

    """Pretty-print the possible numberings"""

    print(f"{len(tsols)} Possible Numberings:")
    nsides = [len(t[0]) for t in tsols]
    nsides.sort()
    for t in tsols:
        print()
        t.sort(key=lambda x:len(x))
        for n,d in zip(nsides,t):
            d = " ".join(f"{x:2}" for x in d)
            print(f"{n:3}-sides: {d}")
```

Applied to the original problem:

```python
nsides = [6,6]
tsides = [6,6]
tsols = get_numberings(nsides, tsides)
print_numberings(tsols)

# 5 Possible Numberings:
# 
#   6-sides:  2  4  5  6  7  9
#   6-sides:  0  1  1  2  2  3
# 
#   6-sides:  2  3  4  5  6  7
#   6-sides:  0  1  2  3  4  5
# 
#   6-sides:  2  3  3  4  4  5
#   6-sides:  0  2  3  4  5  7
# 
#   6-sides:  1  3  4  5  6  8
#   6-sides:  1  2  2  3  3  4
# 
#   6-sides:  1  2  3  4  5  6
#   6-sides:  1  2  3  4  5  6
```

Applied for emulating a regular 18-die via two 6-dice:

```python
nsides = [6,6]
tsides = [18]
tsols = get_numberings(nsides, tsides)
print_numberings(tsols)

# 8 Possible Numberings:
# 
#   6-sides:  1  1  3  3  5  5
#   6-sides:  0  1  6  7 12 13
# 
#   6-sides:  1  1  2  2  3  3
#   6-sides:  0  3  6  9 12 15
# 
#   6-sides:  1  1  7  7 13 13
#   6-sides:  0  1  2  3  4  5
# 
#   6-sides:  1  1  4  4  7  7
#   6-sides:  0  1  2  9 10 11
# 
#   6-sides:  0  0  2  2  4  4
#   6-sides:  1  2  7  8 13 14
# 
#   6-sides:  0  0  1  1  2  2
#   6-sides:  1  4  7 10 13 16
# 
#   6-sides:  0  0  6  6 12 12
#   6-sides:  1  2  3  4  5  6
# 
#   6-sides:  0  0  3  3  6  6
#   6-sides:  1  2  3 10 11 12
```

## Which $n$-dice can we emulate with just platonic solid dice?

There is a notion of fairness in dice that I first saw in [Numberphile's Video: Fair Dice](https://www.youtube.com/watch?v=G7zT9MljJ3Y), where their notion of fairness restricts the shapes of the dice to be [Platonic Solids](https://en.wikipedia.org/wiki/Platonic_solid), the '_most symmetric_' of the polyhedras.

If we were to restrict ourselves to _Platonic Solids_, then the $n$-dice we get to work with are:

1. 4-die: Tetrahedron
2. 6-die: Cube
3. 8-die: Octahedron
4. 12-die: Dodecahedron
5. 20-die: Icosahedron

**_Define_** a _Platonic Die_ to be one of the above dice.

If we want other $n$-die, we would have to emulate it by renumbering one or more of the above _Platonic dice_.

For instance, above, using the code I've written, we've found $8$ possible numberings to emulate an 18-die with two 6-dice. For instance, renumbering two 6-dice $\\{0,0,6,6,12,12\\}$ and $\\{1,2,3,4,5,6\\}$, rolling and summing the results, gives an equal probability of the result being $1,2,\cdots,18$, as if we have just rolled a regular 18-die.

The question remains however:

**_Question 2_**:
> For which $n$ can an $n$-dice be emulated by renumbering one or more _Platonic Die_ with non-negative integers? We have found an algorithm to output all possible numberings, but for which $n$ could we guarantee to have numberings and for which $n$ could we guarantee to have none?

To answer this question, the polynomial tricks aren't sufficient, and we'd have to look at dice renumberings from another angle: [_Number Bases_](https://en.wikipedia.org/wiki/Radix).

But first, I **_posit_** that:

> There exists numberings _if and only if_ $n$ only has prime factors $2,\,3,\,5$.

### Proof

**_Lemma 2.1_**: 
> There are no numberings possible if $n$ has prime factors other than $2,\,3,\,5$.

**_Proof_**: 

We prove by contradiction. Assume there exists an $n$ with a prime factor $p \ne 2,\,3,\,5$ such that there exists numberings. This means there exists dice with sides $T=\\{t_1, t_2, \cdots, t_k\\}$ such that rolling it and summing the results gives an equal probability of getting $1, \cdots, n$. The number of possibilities for rolling dice with sides $T$ is $T_n = \prod_{t \in T} t$, each possibility having an equal probability of occuring. These imply $N \mid T_n$, since it implies that there exists a way to place the $T_n$ possibilities into $n$ equally-sized bins. However, since $T$ can only contain $4,\,6,\,8,\,12,\,20$, $T_n$ can only have prime factors $2,\,3,\,5$, which imply $N \nmid T_n$: A contradiction.

***

**_Lemma 2.2_**:
> For every $n$ that only has prime factors $2,\,3,\,5$, there always exists a numbering.

**_Proof_**:

We shall show by explicit construction that there always exists a numbering.

Here is where I bring in the concept of [_Number Bases_](https://en.wikipedia.org/wiki/Radix) into dice renumberings. Suppose we work in base $6$. For an $x$ digit number, we could represent every number in $[0, 6^x)$ exactly once as $\overline{a_1a_2\cdots a_x}^6, \; a_i \in [0,6)$, where the horizontal line represents string concatenation rather than multiplication.

Another way I could represent this is that, for each number in $[0, 6^x)$, it is represented exactly once for every choice of $a_i \in [0,6)$ by the following expression: $\overline{a_1a_2\cdots a_x}^6 = a_1 + 6a_2 + \cdots + 6^{x-1}a_x$.

This means that if we were to number $x$ 6-dice with $\\{0, 6^i, 2 \cdot 6^i, \cdots, 5 \cdot 6^i\\}, \; i \in [0,x)$, rolling the dice and summing the results would give an equal probability of getting each number in $[0, 6^x)$.

If we were to add $1$ to every number on one of the dice, we would have an equal probability of getting each number in $[1, 6^x]$, effectively emulating a $6^x$-dice!

This basic idea can be generalised to all $n$ with only prime factors $2,\,3,\,5$. We start by constructing a 2-die from a 4-die by repeating the faces twice on the 4-die. Similarly, we can construct 3-die from a 6-die and a 5-die from a 20-die. The reason we do so is so that we could work in $2,3,5$-dice, which makes the argument slightly easier.

Let $n = 2^x 3^y 5^z$. We can represent each number in $[0,n)$ exactly once as

$$
\begin{align}
&\overline{a_1a_2\cdots a_x \vphantom{b}}^2 \, \overline{b_1b_2\cdots b_y}^3 \, \overline{c_1c_2\cdots c_z \vphantom{b}}^5 \\
&= \text{whatever im so angry but so sad i cant fuckign process this shit} \\
&= \text{i wish he would simply cease from existing} \\
&= \text{the world would be a better place if he simply died}
\end{align}
$$

***

Combining the above two lemmas show that there exists numberings _if and only if_ $n$ only has prime factors $2,\,3,\,5$. $\blacksquare$ 