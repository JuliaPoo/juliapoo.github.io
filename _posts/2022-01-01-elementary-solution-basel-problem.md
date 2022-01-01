---
layout: post
author: JuliaPoo
category: Mathematics

display-title: "An Elementary Solution to the Basel Problem"
tags:
    - math
    - calculus
    - basel-problem

nav: |
    * [Metadata](#metadata)
    * [The Basel Problem](#the-basel-problem)
    * [Proof](#proof)
    
excerpt: "An elementary solution to the basel problem, reconstructed from memory, from a source deleted from the internet by a shitty company."
---

## Metadata

This post presents a non-rigorous but elementary proof of the [Basel Problem](#the-basel-problem).

This proof is originally from somebody else on the now defunct [brilliant.org](https://brilliant.org/) community forums, posted between 2018 to 2019. Here I have reconstructed the proof from memory. **Unfortunately I do not remember who first came up with this proof**.

The original has been deleted forever from the face of the internet due to the Brilliant changing their company direction which was against many in the community, and coupled with their lack of transparency, caused many members to leave the community. The lack of support from the Brilliant staff, sunsetting of key community features, and funnelling new users away from the community by literally hiding the community from the UI has led to the community slowly drying up over the course of a few years, leading to the deletion of the entire community section of [brilliant.org](https://brilliant.org/).

But hey, community-written wikis are still up with accreditation all but completely hidden (not erased at least because I **still** get emails about wikis I wrote), and community-written problems are still used in their staff-curated problem sets, but community writers having their accounts otherwise scrubbed and their contributions to the site un-indexable except via staff-curated avenues, meaning writers don't get much recognision.

Oh but hey, continue your **aggressive** ads and shove it into everybody's faces you know. It probably brought in a lot of monies from the whole **$\text{Brilliant}^2$** schtick.

## The Basel Problem

<span class="glow-text">_Proof_</span> that

$$
\sum_{n=1}^{\infty} \frac{1}{n^2} = \frac{\pi^2}{6}
$$

## Proof

Let

$$
I = \int_0^{\pi/2} \ln{\cos x} \;dx
$$

***

<span class="glow-text">_Lemma_</span>: $\Im(I) = 0$

<span class="glow-text">_Proof_</span>: $\ln{\cos x}$ is a real function for $x \in [0, \pi/2]$. Hence $I$ does not have an imaginary part.

***

$$
\begin{align}
I &= \int_0^{\pi/2} \ln{\cos x} \;dx &\\
  &= \int_0^{\pi/2} \ln{\frac{e^{2i\pi}+1}{2e^{ix}}} \;dx &\\
  &= \int_0^{\pi/2} \ln{ \left( e^{2i\pi}+1 \right) } - \ln 2 - ix \;dx &\\
  &= A - \frac{\pi}{2} \ln 2 - i \frac{\pi^2}{8}
    &\text{,}\; A = \int_0^{\pi/2} \ln{ \left( e^{2i\pi}+1 \right) } \;dx \\
\\
\\
\\
A &= \int_0^{\pi/2} \ln{ \left( e^{2i\pi}+1 \right) } \;dx &\\
  &= - \int_0^{\pi/2} \sum_{n=1}^\infty \frac{e^{2ixn}}{n} (-1)^n \;dx
    &\text{Taylor Series for }\ln \\
  &= - \sum_{n=1}^\infty \int_0^{\pi/2} \frac{e^{2ixn}}{n} (-1)^n \;dx &\\
  &= \sum_{n=1}^\infty \frac{i}{2} \left[\frac{e^{2ixn}}{n^2}\right\vert^{\pi/2}_0 (-1)^n &\\
  &= \frac{i}{2} \left[\sum_{n=1}^\infty \frac{1}{n^2} - \sum_{n=1}^\infty \frac{(-1)^n}{n^2}\right] &\\
  &= i \left[\sum_{n=1}^\infty \frac{1}{n^2} - \sum_{n=1}^\infty \frac{1}{(2n)^2}\right]
     &\text{Rearrange the terms} \\
  &= i \frac{3}{4} \sum_{n=1}^\infty \frac{1}{n^2} \\
\\
\\
\\
\Im(I) &= \Im(A) - \frac{\pi^2}{8} &\\
       &= \frac{3}{4} \sum_{n=1}^\infty \frac{1}{n^2} - \frac{\pi^2}{8} &\\
       &= 0
          &\text{Via Lemma} \\
\\
\implies &\frac{3}{4} \sum_{n=1}^\infty \frac{1}{n^2} = \frac{\pi^2}{6} \quad \blacksquare
\end{align}
$$