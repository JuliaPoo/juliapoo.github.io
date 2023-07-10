---
layout: post
author: JuliaPoo
category: Unlisted

display-title: "Solving Equations Over Certain Finite Soluble Groups"
tags:
    - math
    - group-theory
    - soluble-groups

nav: |
    * TODO

    
excerpt: "Solving systems of equations over finite abelian groups is easy: It's just some flavor of gaussian elimination. This becomes significantly harder when the group is non-abelian. It is known that showing existence of a solution for a fixed, finite number of equations is $P$ for nilpotent groups and $NP$-complete for non-solvable groups, but the question remains open for soluble groups in general. Considering a simplification of this problem, this post presents informally a polynomial-time algorithm for groups in the closure of finite abelian groups with the semi-direct product, which contains non-nilpotent soluble groups."
# $A_0 \\ltimes (A_1 \\ltimes (\\ldots \\ltimes A_n)\\ldots)$ where $A_i$ are abelian.
---

# Motivation

This is a blog post so I can write whatever I want. In the spirit of internet recipes here's how I chanced upon this problem:

Instead of studying for my exams [\{insert rant on my first year experience in university\}](https://youtu.be/juBv2XWnwt8), I spent a whole day writing a CTF challenge for SEETF 2023, whereby my intended solution didn't work and I spent the next 3-4 hours in a `this is probably impossible` and `or am I just stupid` loop. In the end I managed to solve my own challenge (with modifications) and in the process come up with the main ideas of what will be written in this post. I then went and searched for literature about this and turns out it's a studied problem. I can't find literature for the exact class of groups that I dealt with, and I don't think whatever I found is worthy to be written in some paper so blog post it is. Also as of right now I should be studying for an exam because `academics-are-paramount-oh-my-god-we-will-literally-treat-you-as-second-class-if-you-dont-do-well` but I'm here writing this post because studying is ver boring.

# Metadata

- For those who have an adverse reaction to mathematics in dark-mode, here's a [latex-formatted, light-mode pdf for your viewing pleasure](TODO)
- [Code that implements the algorithm described in this post](TODO)

# Introduction

> **Definition**
> 
> Let $\mathbb{A}$ be the set of finite abelian groups. Define the set of _ENA groups_ $\mathbb{E}$ (I can name it however I want) to be the smallest set containing $\mathbb{A}$ such that $E_1, E_2 \in \mathbb{E} \implies E_1 \ltimes E_2 \in \mathbb{E}$. I.e., $\mathbb{E}$ is the closure of $\mathbb{A}$ under semi-direct product.

> **Definition**
>
> For a group $G$, the simplified Equation Satisfiability Problem $\texttt{EqnSysSat}$ with $N$ unknowns and $M$ equations over $G$ is defined as follows:
>
> Let $X = \lbrace x_1, \ldots, x_N\rbrace$ be a set of $N$ free variables. Define an _equation_ to be an expression $\alpha \in (X \cup G)^\ast$ and let $A = \lbrace \alpha_1, \ldots, \alpha_M\rbrace$ to be a set of $M$ equations. $\texttt{EqnSysSat}$ asks if there exists some assignment $\sigma: X \rightarrow G^N$ such that $\forall \alpha_i, \; \alpha_i = 1_G$.
>
> Note that $\texttt{EqnSysSat}$ defined here is a simplification of the usual Equation Satisfiability Problem, where $\alpha \in (X \cup X^{-1} \cup G)^\ast$ instead of $(X \cup G)^\ast$.

This post only considers $G \in \mathbb{E}$, which is finite, and expresses equations $\alpha$ in the following form:

$$
\alpha = \prod_{i \in I} w_i, \; I \text{ is finite and } w_i \in X \cup G
$$

> **Example**
>
> When $G = C_p$ for prime $p$, $\texttt{EqnSysSat}$ over $N$ unknowns and equations reduces to gaussian elimination in $M_N(\mathbb{F}_p)$ to find the kernel of the affine map $(x_1, \ldots, x_N)^\intercal \rightarrow (\alpha_1, \ldots, \alpha_N)^\intercal$

# Main Result

> **Theorem 1**
> 
> For $G \in \mathbb{E}$, there is a polynomial-time algorithm to solve the $\texttt{EqnSysSat}$ problem in $N$ equations and $M$ unknowns. In addition, the algorithm solves for the space of all possible assignments $\sigma: X \rightarrow G^N$.

The algorithm does this by reducing $\texttt{EqnSysSat}$ over $G = K \ltimes H \in \mathbb{E}$ into $\texttt{EqnSysSat}$ over $K$ and $H$ seperately, recursively solving until it reaches $\texttt{EqnSysSat}$ over groups in $\mathbb{A}$. 

# The Algo

> **Lemma 2.1**
> 
> Let $G \in \mathbb{E}$, There exists generators $\lbrace g_1, \ldots, g_n\rbrace$ such that for all $g \in G$, $\exists e_i \in \mathbb{Z}_{\ge 0}$ such that $g = \prod_{i=1}^n g_{i}^{e_i}$. 
>
> **_Proof_**
> 
> Let $G \in \mathbb{A}$. By the classification of finite abelian groups, $G$ is isomorphic to a direct product of cyclic groups, say with generators $\lbrace g_1,\ldots,g_{n}\rbrace$. Since each generator has finite order, for all $g \in G$, we can express $g = \prod_{i=1}^{n} g_i^{e_i}$ for $e_i \in \mathbb{Z}_{\ge 0}$.
>
> Let $A,B \in \mathbb{E}$ such that $A$ and $B$ satisfies the desired property, and let $G = A \ltimes B$. Let $\lbrace a_1,\ldots,a_{n_a}\rbrace$ and $\lbrace b_1,\ldots,b_{n_b}\rbrace$ be such generators of $A$ and $B$ respectively. Then for all $g \in G$, $\exists a \in A, \; b \in B$ such that $g = ab$. We can express $a = \prod_{i=1}^{n_a} a_i^{e_i}$ and $b = \prod_{i=1}^{n_b} b_i^{d_i}$ for $e_i, d_i \in \mathbb{Z}\_{\ge 0}$. Since $\lbrace a_0,\ldots,a\_{n_a}, b_1\ldots, b\_{n_b}\rbrace$ generates $G$, $g$ can be written in the desired form.
>
> Hence via induction, the desired property holds for all $G \in \mathbb{E}$.



<!--
TODO: Consider X^-1?
- Maybe we can split into generators first and then perform inverse. We know the orders of all the generators.
TODO: A note about the modification

NEED TO SHOW:
Every element in G can be expressed as a single product of generators.

Notes:

We need to characterise the property of Aut(K) for K |x H.
Fix h and let x be free in K. x^h needs to be represented
as an equation over (x, h, H, K) in K.

Let f in Aut(K) induced by conjugation of K by h.
f(x) = you know what fuck it case by case basis.

Suppose x can be split into generators
x = g1^x1...gn^xn, unknown xi, and
f(gi) = g1^a{i,1}...gn^a{i,n}
Then f(x) 
= f(g1)^x1...f(gn)^xn
is (a super long) equation of n unknowns in K.

So starting from say N unknowns and M equations in K |x_phi1 H, and suppose we've solved it in H. Now we solve in K. Let p1 = |phi1(H)|
At this point we'll have p1*N unknowns and M equations.
Then the process of splitting everything into their n generators brings to n*p1*N unknowns and M equations.
We can describe the (p1 - 1) non-trivial elements in Aut(K) with an equation in K, bringing us to p1*M equations.

We need to split each p1*M equations on the generators of K into each generator. This is trivial if K is abelian cuz then all the generators permute and are independent.

If K = A |x_phi2 B, A and B are abelian,
{
    We rename gi to be a1...an_a, b1...bn_b., n_a + n_b = n.
    If we quotient by B, since B is abelian we can split each equation into n_b equations on each bi.
    we'll have n_b*p1*N unknowns and n_b*p1*M equations.
    So we can solve normally in B.

    Let p2 = |phi2(B)|
    When we do the same trick as above we'll end up with
    p2*p1*N unknowns and p1*M equations in A.
    We can describe the (p2 - 1) non-trivial elements in Aut(A) with an equation in B, decomposed into generators, leaving p2*p1*M equations.
    Since A is abelian we can similarly split into generators
    So n_a*p2*p1*N unknowns and n_b*p2*p1*M equations.
    So we can solve normally in A.
}

If K is an ENA group, I guess we just delay splitting until we hit an abelian group?
{
    TODO: Actual implementation to concretise this thinking
}
-->
