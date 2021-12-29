---
layout: post
author: JuliaPoo
category: Mathematics

display-title: "The Most Inefficient Way to Compute $\\pi$"
tags:
    - math
    - random-walk
    - coin-flip
    - stirlings-approximation
    - pi

nav: |
    * [The Procedure](#the-procedure)
    * [Its efficiency](#its-efficiency)
    * [Why it works](#why-it-works)
        * [Proof](#proof)

excerpt: "A surprising and incredibly inefficient way to compute $\\pi$ based on coin flips"
---

## The Procedure

Here's my steps to compute $\pi$:

1. Take a large number of coins, say $N$ coins.
2. Throw all of them down the stairs
3. Count the number of heads $h$ and tails $t$ and compute $d = \|h-t\|$, the absolute difference between the two.
4. Repeat steps 1-3 a large number of times, say $M$ times, and take the average of $d$: $d_{avg}$
5. Compute $\frac{2N}{d_{avg}^2} \approx \pi$

<span class="glow-text" style="font-size:large">_Disclaimer_</span>: This is probably not actually the most inefficient way, but is imo one of the more interesting ones.

<span class="glow-text" style="font-size:large">_Fun Fact_</span>: My friend Clyde actually tried to do this with `100` coins. He threw them down the stairs, counted them _manually_, and the value is _nothing_ close to $\pi$. I might have failed to mention how _inefficient_ this is.

## Its efficiency

Of course I'm not gonna be actually doing this with coins, when I can just do it with code. For simplicity, am gonna just set $N = M$

```py
from random import getrandbits
from timeit import timeit

def approx_pi(N, M):
    d_sum = 0
    for _ in range(M):
        h = bin(getrandbits(N))[2:].count('1')
        t = N - h
        d_sum += abs(h-t)
    d_avg = d_sum/M
    pi = 2*N / (d_avg*d_avg)
    print("Pi:", pi)
    return pi

s = timeit("approx_pi(10,10)", number=1, globals=globals())
print(f"Time Taken: {s}s")

s = timeit("approx_pi(100,100)", number=1, globals=globals())
print(f"Time Taken: {s}s")

s = timeit("approx_pi(1000,1000)", number=1, globals=globals())
print(f"Time Taken: {s}s")

s = timeit("approx_pi(10000,10000)", number=1, globals=globals())
print(f"Time Taken: {s}s")

s = timeit("approx_pi(100000,100000)", number=1, globals=globals())
print(f"Time Taken: {s}s")
```

Results:

{% capture table1 %}
| $N,M$ | $\pi$ | Time taken (s) |
| --- | ----- | ---------- |
| 10  | 1.9531 | 0.0034 |
| 100 | 2.7423 | 0.0042 |
| 1000 | <span class="glow-text">**3**</span>.0966 | 0.0309 |
| 10000 | <span class="glow-text">**3.1**</span>108 | 0.7314 |
| 100000 | <span class="glow-text">**3.14**</span>71 | 71.2566 |
{% endcapture %}

<center class="table-scrollx">
{{ table1 | markdownify }}
</center>

You need to throw `100,000` coins `100,000` times, for a total of `10,000,000,000` (10 billion!) coin tosses to compute just 3 correct digits of $\pi$.

## Why it works

The procedure can be reframed as a 1D random walk. Say each time you toss a coin, you move to the right by 1 step if it's a heads, and to the left if it's a tail, and you do so for $N$ coin tosses. As $M \rightarrow \infty$, $d_{avg}$ is actually equivalent to the expected distance you are from your starting point after $N$ steps!

Now let $E_n$ be the expected distance you are from your starting point after $n$ steps. It turns out that

$$
\lim_{n \rightarrow \infty} \frac{2n}{E_n^2} = \pi
$$

### Proof

Consider plotting the number of possible paths that lead to a position after $n$ steps.

{% capture table1 %}
| Steps |-6|-5|-4|-3|-2|-1|0|+1|+2|+3|+4|+5|+6|
| ----- |:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 0     | | | | | | |1| | | | | | |
| 1     | | | | | |1|0|1| | | | | |
| 2     | | | | |1|0|2|0|1| | | | |
| 3     | | | |1|0|3|0|3|0|1| | | |
| 4     | | |1|0|4|0|6|0|4|0|1| | |
| 5     | |1|0|5|0|10|0|10|0|5|0|1| |
| 6     |1|0|6|0|15|0|20|0|15|0|6|0|1|
{% endcapture %}

<center class="table-no-outline table-scrollx">
{{ table1 | markdownify }}
</center>

> At step $0$, there is only one possible path, which is where you are currently standing on. \\
> At step $1$, you could have taken a step to the right or to the left, a total of one path to `+1` or `-1`. \\
> At each additional step, the total number of paths to a position `x` is the sum of the paths to position `x-1` and `x+1`.

Does the values look familiar? It is the values of the [Pascal's Triangle](https://en.wikipedia.org/wiki/Pascal%27s_triangle). The values on the triangle are [Binomial Coefficients](https://en.wikipedia.org/wiki/Binomial_coefficient).

$E_n$ can be computed by taking the average of the distance travelled from all the paths. For instance, looking at the `6-th` row on the table, 

$$
\begin{align}
E_6 &= \frac{1}{2^6}(1 \times 6 + 6 \times 4 + 15 \times 2 + 20 \times 0 + 15 \times 2 + 6 \times 4 + 1 \times 6)
\end{align}
$$

For simplicity, let's consider even $n$. In general, for even $n$, 

$$
\begin{align}
E_n &= \frac{1}{2^{n-2}} \sum_{j=1}^{n/2} j \binom{n}{n/2 + j} \\
&= \frac{n}{2^{n}} \binom{n}{n/2} 
\end{align}
$$

Since we are gonna take the limit $n \rightarrow \infty$, we don't actually need to care about odd $n$ since the limit is the same. 

Taking the limit, we can use [Stirling's Approximation](https://en.wikipedia.org/wiki/Stirling%27s_approximation) to approximate the asymptopic behaviour of $E_n$

$$
\begin{align}
\lim_{n \rightarrow \infty} E_n &= \sqrt{\frac{2n}{\pi}} \\
\pi &= \lim_{n \rightarrow \infty} \frac{2n}{E_n^2} \quad \blacksquare
\end{align}
$$