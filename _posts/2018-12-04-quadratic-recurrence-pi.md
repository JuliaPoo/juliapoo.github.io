---
layout: post
author: JuliaPoo
category: Mathematics

display-title: "A Quadratic Recurrence Relation that Computes $\\pi$"
tags:
    - math
    - recurrence-relation
    - continued-fraction
    - pi

nav: |
    * [The Recurrence Relation](#the-recurrence-relation)
    * [Why it works](#why-it-works)
    * [Detailed proof](#detailed-proof)

excerpt: "I found a recurrence relation that computes $\\pi$. Here's why it works."
---

## The Recurrence Relation

Define the sequence $ A(x,y) = \\{ a_0, a_1, a_2, ... \\} $ such that

$$
a_n = 
\begin{cases}
x  & n = 0 \\
y  & n = 1 \\
6a_{n-1} + (2n-3)^2a_{n-2} &\text{Otherwise}
\end{cases}
$$

Now define $ P = \\{p_0, p_1, p_2, ...\\} = A(1,3) $ and $ Q = \\{q_0, q_1, q_2, ...\\} = A(0,1) $. In other words, the sequence $P$ and $Q$ are generated from the same recurrence relation, but have different starting values.

Now, I posit that

$$
\lim_{n \rightarrow \infty} \cfrac{p_n}{q_n} = \pi
$$

Here's a code version:

```py
N = 10000

p = [1,3]
for n in range(2,N):
    p.append(6*p[n-1] + (2*n-3)**2 * p[n-2])
    
q = [0,1]
for n in range(2,N):
    q.append(6*q[n-1] + (2*n-3)**2 * q[n-2])
    
print(p[N-1]/q[N-1])

# > 3.141592653589543
```

## Why it works

$P$ and $Q$ are the coefficients of the n-th term of the continued fraction:

$$
\pi = \cfrac{1^2}{6+\cfrac{3^2}{6+\cfrac{5^2}{6+\cfrac{7^2}{...}}}}
$$

Which is a well known approximation of $\pi$.

## Detailed proof

Lemma:

$$
\cfrac{xp_{n-1}+\left(2n-3\right)^{2}p_{n-2}}{xq_{n-1}+\left(2n-3\right)^{2}q_{n-2}}=\cfrac{\left[6+\cfrac{(2n-3)^{2}}{x}\right]p_{n-2}+(2n-5)^{2}p_{n-3}}{\left[6+\cfrac{(2n-3)^{2}}{x}\right]q_{n-2}+\left(2n-5\right)^{2}q_{n-3}}
$$

Proof:

$$
\begin{align}
\cfrac{xp_{n-1}+\left(2n-3\right)^{2}p_{n-2}}{xq_{n-1}+\left(2n-3\right)^{2}q_{n-2}}
&= \cfrac{x\left[6p_{n-2}+\left(2n-5\right)^{2}p_{n-3}\right]+\left(2n-3\right)^{2}p_{n-2}}{x\left[6q_{n-2}+\left(2n-5\right)^{2}q_{n-3}\right]+\left(2n-3\right)^{2}q_{n-2}}& \\
&= \cfrac{\left[6x+\left(2n-3\right)^{2}\right]p_{n-2}+x\left(2n-5\right)^{2}p_{n-3}}{\left[6x+\left(2n-3\right)^{2}\right]q_{n-2}+x\left(2n-5\right)^{2}q_{n-3}}& \\
&= \cfrac{\left[6+\cfrac{(2n-3)^{2}}{x}\right]p_{n-2}+(2n-5)^{2}p_{n-3}}{\left[6+\cfrac{(2n-3)^{2}}{x}\right]q_{n-2}+\left(2n-5\right)^{2}q_{n-3}} &\quad \blacksquare
\end{align}
$$

***

Using the lemma:

$$
\begin{align}
\cfrac{p_n}{q_n} &= \cfrac{6p_{n-1}+\left(2n-3\right)^{2}p_{n-2}}{6q_{n-1}+\left(2n-3\right)^{2}q_{n-2}} \\
&=\cfrac{\left[6+\cfrac{(2n-3)^{2}}{6}\right]p_{n-2}+\left(2n-5\right)^{2}p_{n-3}}{\left[6+\cfrac{(2n-3)^{2}}{6}\right]q_{n-2}+\left(2n-5\right)^{2}q_{n-3}} \\
&= \cfrac{\left[6+\cfrac{(2n-5)^{2}}{6+\cfrac{(2n-3)^{2}}{6}}\right]p_{n-3}+\left(2n-7\right)^{2}p_{n-4}}{\left[6+\cfrac{(2n-5)^{2}}{6+\cfrac{(2n-3)^{2}}{6}}\right]q_{n-3}+\left(2n-7\right)^{2}q_{n-4}}\\
& ... \\
&=\cfrac{F_{n}p_{1}+1^{2}p_{0}}{F_{n}q_{1}+1^{2}q_{0}}=\cfrac{3F_{n}+1}{F_{n}}=3+\cfrac{1}{F_{n}}
\end{align}
$$

Where I've applied the lemma repeatedly and 

$$
\displaystyle F_n=6+\cfrac{3^2}{6+\cfrac{5^2}{6+\cfrac{7^2}{...+\cfrac{...}{6+\cfrac{\left(2n-3\right)^2}{6}}}}}
$$

Hence

$$
\lim_{n \rightarrow \infty} \frac{p_n}{q_n} = \lim_{n \rightarrow \infty} 3+\frac{1}{F_n}=3+\cfrac{1^2}{6+\cfrac{3^2}{6+\cfrac{5^2}{6+\cfrac{7^2}{...}}}} = \pi \quad \blacksquare
$$