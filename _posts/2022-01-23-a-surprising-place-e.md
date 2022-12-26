---
layout: post
author: JuliaPoo
category: Bites

display-title: "A Surprising Place $e$ Appears In"
tags:
    - math
    - combinatorics
    - e

nav: |
    * [Occurance](#occurance)
    * [Meta](#meta)
    * [Proof](#proof)

excerpt: "It takes an average of $e$ randomly generated numbers in $[0,1]$ for the sum to be more than $1$"
---

## Occurance

It takes an average of $e$ randomly generated numbers in $[0,1]$ for the sum to be more than $1$

## Meta

I was first told of this problem from Emilia on discord, and I was **_determined_** to find a solution with almost no calculus.

## Proof

Let $s_n$ be the probability distribution of the sum of $n$ numbers in $[0,1]$. Let $N$ be the probability distribution of the number of numbers you need to sum to get more than $1$. Let $P(x)$ be the probability of the predicate $x$ holding true.

***

> **_Lemma_**: $P(s_n < 1) = 1/n!$
> 
> **_Proof_**: 
> Subdivide the interval $[0,1]$ into $m$ parts, and say we can only pick the numbers $X = {x_1,x_2\cdots x_n}$ in multiples of $1/m$. There are $m^n$ ways to choose $X$. However, there's only $\text{Binomial}(m,n)$ ways to pick $X$ such that $\text{sum}(X) < 1$, which can be shown via the [_stars and bars method_](https://en.wikipedia.org/wiki/Stars_and_bars_(combinatorics)). Now the probability that $\text{sum}(X)<1$ is $P = \text{Binomial}(m,n)/m^n$, and as $m\rightarrow \infty$, $P\rightarrow 1/n!$. Hence proved.

***

Now,

$$
\begin{align}
P(s_n < 1) &= P(N > n) = \frac{1}{n!} \\
P(N = n) &= P(N > n-1) - P(N > n) = \frac{1}{(n-1)!} - \frac{1}{n!}
\end{align}
$$

You can see how $1 = \sum_{n=2}^{\infty} P(N = n)$ because it telescopes into 1.

Therefore, the expected value of $N$ can be found as such:

$$
\begin{align}
E(n) &= \sum_{n=2}^{\infty} P(N = n) \times n \\
     &= \sum_{n=2}^{\infty} \left[ \frac{1}{(n-1)!} - \frac{1}{n!} \right] \times n \\
     &= \sum_{n=2}^{\infty} \frac{1}{(n-2)!} \\
     &= \sum_{n=0}^{\infty} \frac{1}{n!} \\
     &= e    &\blacksquare
\end{align}
$$