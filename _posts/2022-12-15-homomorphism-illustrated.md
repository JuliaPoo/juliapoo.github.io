---
layout: post
author: JuliaPoo
category: Mathematics

display-title: "Visualising Homomorphisms"
tags:
    - math
    - algebra
    - homomorphisms
    - isomorphism-theorems
    - eyecandy

nav: |
    * [Motivation](#motivation)
    * [Intuition](#intuition)
        * [First Isomorphism Theorem](#first-isomorphism-theorem)
        * [Lattice Isomorphism Theorem: Collapsing the Lattice](#lattice-isomorphism-theorem-collapsing-the-lattice)
            * [Shortfalls of the lattice visual intuition](#shortfalls-of-the-lattice-visual-intuition)
        * [Abstracting the Lattice: Slicing a Shape](#abstracting-the-lattice-slicing-a-shape)
    * [Applications](#applications)
        * [Isomorphism Theorems Visualised](#isomorphism-theorems-visualised)
        * [Subgroup Series](#subgroup-series)
            * [Composition Series](#composition-series)
            * [Other Subgroup Series](#other-subgroup-series)
        * [Abelian Groups and Other Abelian Things](#abelian-groups-and-other-abelian-things)

    
excerpt: Visual intuitions I've accrued while studying algebra, starting with a geometric interpretation of the isomorphism theorems and application into more "involved" concepts like composition series. Currently very Group focused, might update for more objects.
---

<!--
1. Brief Timeline
1. Motivation
2. Overview
    - Predictive power
-->

# Motivation

So I started learning abstract algebra from [Basic Algebra I by Nathan Jacobson](http://www.math.toronto.edu/~ila/Jacobson-Basic_algebra_I%20(1).pdf) earlier this year, and being a rather dense resource it lacked any form of discourse on the intuition of the concepts. For instance, here's how I got introduced to homomorphisms from _Nathan Jacobson_:

<center style="filter:invert(1);">
<img style="width:calc(min(100%, 800px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/nathan-homo.jpg">
</center>

Despite having been given no intuition, I formed my own visual intuition of certain concepts, and relied upon it up till Galois Theory. And then I lost interest. 

Fast forward to a few months later I got recommended **The** [Dummit and Foote](https://www.wiley.com/en-us/Abstract+Algebra%2C+3rd+Edition-p-9780471433347) which is an easier resource with plenty of intuition discussed. However, having formed my own intuition already, I realised the intuition written there had some shortcomings, but it helped in fixing certain issues in my intuition and is really an amazing and clear resource.

AND THEN I saw this [neat little visual](/assets/posts/2022-12-15-homomorphism-illustrated/PuzzlingThroughExactSequences-23.svg) on the [Snake Lemma](https://en.wikipedia.org/wiki/Snake_lemma) from [Puzzling Through Exact Sequences](https://www.3blue1brown.com/blog/exact-sequence-picturebook) and that motivated me to "concretise" my visual intuitions. Turns out my intuition is a generalisation of the intuition presented in _Puzzling Through Exact Sequences_.

Here, I'm going to describe the intuitions I've been using, starting from the most "concrete" and building up to those more "abstract", and demonstrate its explainability power in some examples, and as a treat, specialise this intuition for abelian groups to connect my interpretation with that from _Puzzling Through Exact Sequences_. This post is going to be very Groups focused but I'm sure there are ways to carry this to other structures like Rings. Will update this post when I get around to that.

This post is going to be VERY non-rigourous and assume some familiarity with the algebra behind. The intention is not to introduce the concepts but to detail certain intuitions one might miss out on. I hope my writing can help out others who are just starting in Algebra ^-^**\***.

# Intuitions

## First Isomorphism Theorem

We start with some fairly standard visual intuition of the first isomorphism theorem, which states:

> Let $G$ and $H$ be groups, and let $f : G \rightarrow H$ be an epimorphism and $K = \text{ker}\;f$. Then $K \trianglelefteq G$ and $H \cong G / K$.

The core claim here is that $G / K$ has "the same structure" as $H = \text{Im}\; f$. We build the visual intuition from the fact that $G$ is evenly partitioned by the cosets of $K$, and that $G / K$ is precisely the "structure" of these cosets.

<center>
<img style="width:calc(min(100%, 500px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/iso-1.svg">
</center>

The visual here shows the additive group $\\{(0,0), (0,1), (1,0), (1,1), (2,0), (2,1)\\}$$=\mathbb{Z}_3 \times \mathbb{Z}_2$, with two generators $(0,1)$ and $(1,0)$. The red lines correspond to adding $(0,1)$ and the blue arrows correspond to adding $(1,0)$. We have an epimorphism $f$ to $\mathbb{Z}_2$ with kernel $\mathbb{Z}_3$.

From the visual, we can see that an epimorphism collapses the kernel $K$ into a single point in the image $G / K$. All the other cosets of $K$ in $G$ are similarly collapsed into a unique point in $G/K$. Some properties become immediately apparent, such as [_Lagrange's Theorem_](https://en.wikipedia.org/wiki/Lagrange%27s_theorem_(group_theory)) ($\|G / K\| = \|G\|\,/\,\|K\|$ for finite $G$), as each point in $G / K$ is "made up" of $\|K\|$ elements in $G$. Furthermore, the collapsing of the cosets into single points reveals some structure of $G$: The red line on the right side of the visual, indicative of the structure of $G/K$, corresponds to the three red lines on the left side. More generally, the group operation on $G$ is well-defined over the cosets of $K$.

Collapsing some structure (that of $\text{ker}\;f = K$) into a single point begets the intuition that some structural information is lost upon a homomorphism $G \rightarrow G /K$ (in particular, a non-injective homomorphism) while retaining some information about the original structure (The red line on the right side of the visual): We are "collapsing" off some part of the structure to obtain the image of a homomorphism. This, I presume, is the origin of the term "quotient" and why its syntax bares resemblence to "dividing".

The First Isomorphism Theorem is also often stated with the following:

> For every normal subgroup $K$ of $G$, there is an epimorphism $f: G \rightarrow G / K$. (Via the first isomorphism theorem, this requires that $\text{ker}\;f = K$). Such an epimorphism can simply be the natural epimorphism of $g \in G$ into its coset $gK \in G/K$.

Hence, when studying homomorphisms, we are also studying normal subgroups. This visual can therefore also serve as intuitions about normal subgroups.

Unfortunately this visual intuition is very limited. It is difficult to see what exactly I mean by "collapsing". What was removed and what is left? The idea of "collapsing" the structure of $G$ will be made more explicit in the **Lattice Isomorphism Theorem** where we'll see a more common (and useful) way to visualise homomorphisms. 

## Lattice Isomorphism Theorem: Collapsing the Lattice

The Lattice Isomorphism Theorem as stated by itself is rather opaque:

> **(Dummit and Foote)** Let $G$ be a group and let $N$ be a normal subgroup of $G$. Then there is a bijection from the set of subgroups $A$ of $G$ which contain $N$ onto the set of subgroups of $G / N$, given by the map $A \rightarrow A/N$. In particular, every subgroup of $G/N$ is of the form $A/N$ for some subgroup $A$ of $G$ containing $N$ (namely, its preimage in $G$ under the natural projection homomorphism from $G$ to $G/N$). This bijection has the following properties: for all $A,B \le G$ with $N \le A$ and $N \le B$,
> 
> 1. $A \le B$ iff $A/N \le B/N$
> 2. If $A \le B$, then $\|B:A\| = \|B/N : A/N\|$
> 3. $\langle A,B \rangle / N = \langle A/N, B/N \rangle$
> 4. $A \cap B = A/N \cap B/N$
> 5. $A \trianglelefteq G$ iff $A/N \trianglelefteq G/N$

The "involved-ness" of this theorem is largely because it essentially formalises a way to visualise quotients by slicing the [Lattice of Subgroups](https://en.wikipedia.org/wiki/Lattice_of_subgroups). Dummit and Foote goes through in detail the visual implications of the Lattice Isomorphism Theorem on the _Lattice of Subgroups_. Since the visual intuition I'll present in the next section essentially builds on the intuition presented in Dummit and Foote, for completeness I'll touch a little on this.

First off, the _Lattice of Subgroups_ of a group $G$ can be seen to encode the structure of $G$. For illustration purposes I'll be using the [(finite) Dihedral Group](https://en.wikipedia.org/wiki/Dihedral_group) $D_8$ as an example:


<!--
\[\begin{tikzcd}
	&& {D_8} \\
	& {\langle s, r^2 \rangle} & {\langle r \rangle} & {\langle rs, r^2 \rangle} \\
	{\langle r \rangle} & {\langle r^2s \rangle} & {\langle r^2 \rangle} & {\langle rs \rangle} & {\langle r^3s \rangle} \\
	&& 1
	\arrow[no head, from=1-3, to=2-3]
	\arrow[no head, from=1-3, to=2-4]
	\arrow[no head, from=1-3, to=2-2]
	\arrow[no head, from=2-2, to=3-3]
	\arrow[no head, from=2-3, to=3-3]
	\arrow[no head, from=2-4, to=3-3]
	\arrow[no head, from=2-4, to=3-4]
	\arrow[no head, from=2-4, to=3-5]
	\arrow[no head, from=2-2, to=3-2]
	\arrow[no head, from=2-2, to=3-1]
	\arrow[no head, from=3-1, to=4-3]
	\arrow[no head, from=3-2, to=4-3]
	\arrow[no head, from=3-3, to=4-3]
	\arrow[no head, from=3-4, to=4-3]
	\arrow[no head, from=3-5, to=4-3]
\end{tikzcd}\]
-->
<center style="filter:invert(100%)">
<img style="width:calc(min(100%, 600px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/D8_lattice1.JPG">
</center>

Each line that connects two groups indicates _inclusion_, i.e., one is a subgroup of another (e.g., $\langle r^2 \rangle < \langle r \rangle$). Do note that while "_the shape_" of the lattice encodes the structure of the group, a particular "shape" is by no means unique to a subgroup (e.g., take the lattice for $\mathbb{Z}_2$ and $\mathbb{Z}_3$, which consists of a single line connecting $1$ to itself).

The Lattice Isomorphism Theorem gives an intuition for taking quotients by collapsing the lattice diagram. Say for insance we take $K = \langle r^2 \rangle$ and consider the lattice for $G / K = D_8 / K$. (you do first need to check that $\langle r^2 \rangle \trianglelefteq D_8$ in order for the quotient to be well-defined):

<!--
https://q.uiver.app/?q=WzAsMTcsWzIsMCwiRF84Il0sWzIsMSwiXFxsYW5nbGUgciBcXHJhbmdsZSJdLFsxLDEsIlxcbGFuZ2xlIHMsIHJeMiBcXHJhbmdsZSJdLFszLDEsIlxcbGFuZ2xlIHJzLCByXjIgXFxyYW5nbGUiXSxbMiwyLCJcXGxhbmdsZSByXjIgXFxyYW5nbGUiXSxbMSwyLCJcXGxhbmdsZSByXjJzIFxccmFuZ2xlIl0sWzAsMiwiXFxsYW5nbGUgciBcXHJhbmdsZSJdLFszLDIsIlxcbGFuZ2xlIHJzIFxccmFuZ2xlIl0sWzQsMiwiXFxsYW5nbGUgcl4zcyBcXHJhbmdsZSJdLFsyLDMsIjEiXSxbNiwwLCJEXzgvSyJdLFs1LDEsIlxcbGFuZ2xlIHNLIFxccmFuZ2xlIl0sWzYsMSwiXFxsYW5nbGUgcksgXFxyYW5nbGUiXSxbNywxLCJcXGxhbmdsZSBzcksgXFxyYW5nbGUiXSxbNiwyLCIxIl0sWzIsNCwiXFx0ZXh0e0xhdHRpY2UgZm9yfVxcXFxEXzgiXSxbNiw0LCJcXHRleHR7TGF0dGljZSBmb3J9IFxcXFxEXzgvXFxsYW5nbGUgcl4yIFxccmFuZ2xlIl0sWzAsMSwiIiwwLHsibGV2ZWwiOjIsInN0eWxlIjp7ImhlYWQiOnsibmFtZSI6Im5vbmUifX19XSxbMCwzLCIiLDIseyJsZXZlbCI6Miwic3R5bGUiOnsiaGVhZCI6eyJuYW1lIjoibm9uZSJ9fX1dLFswLDIsIiIsMix7ImxldmVsIjoyLCJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzIsNCwiIiwyLHsibGV2ZWwiOjIsInN0eWxlIjp7ImhlYWQiOnsibmFtZSI6Im5vbmUifX19XSxbMSw0LCIiLDAseyJsZXZlbCI6Miwic3R5bGUiOnsiaGVhZCI6eyJuYW1lIjoibm9uZSJ9fX1dLFszLDQsIiIsMCx7ImxldmVsIjoyLCJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzMsNywiIiwyLHsic3R5bGUiOnsiaGVhZCI6eyJuYW1lIjoibm9uZSJ9fX1dLFszLDgsIiIsMix7InN0eWxlIjp7ImhlYWQiOnsibmFtZSI6Im5vbmUifX19XSxbMiw1LCIiLDIseyJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzIsNiwiIiwyLHsic3R5bGUiOnsiaGVhZCI6eyJuYW1lIjoibm9uZSJ9fX1dLFs2LDksIiIsMix7InN0eWxlIjp7ImhlYWQiOnsibmFtZSI6Im5vbmUifX19XSxbNSw5LCIiLDEseyJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzQsOSwiIiwxLHsic3R5bGUiOnsiaGVhZCI6eyJuYW1lIjoibm9uZSJ9fX1dLFs3LDksIiIsMSx7InN0eWxlIjp7ImhlYWQiOnsibmFtZSI6Im5vbmUifX19XSxbOCw5LCIiLDEseyJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzE0LDExLCIiLDEseyJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzE0LDEzLCIiLDEseyJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzE0LDEyLCIiLDEseyJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzEyLDEwLCIiLDEseyJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzExLDEwLCIiLDEseyJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzEzLDEwLCIiLDEseyJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzQsMTQsIiIsMSx7ImN1cnZlIjozLCJjb2xvdXIiOlsyNDksNjgsNjBdLCJzdHlsZSI6eyJib2R5Ijp7Im5hbWUiOiJkYXNoZWQifX19XSxbMSwxMiwiIiwxLHsiY3VydmUiOjQsImNvbG91ciI6WzI0OSw2OCw2MF0sInN0eWxlIjp7ImJvZHkiOnsibmFtZSI6ImRhc2hlZCJ9LCJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzIsMTEsIiIsMSx7ImN1cnZlIjotMywiY29sb3VyIjpbMjQ5LDY4LDYwXSwic3R5bGUiOnsiYm9keSI6eyJuYW1lIjoiZGFzaGVkIn19fV0sWzMsMTMsIiIsMSx7ImN1cnZlIjotMywiY29sb3VyIjpbMjQ5LDY4LDYwXSwic3R5bGUiOnsiYm9keSI6eyJuYW1lIjoiZGFzaGVkIn19fV0sWzAsMTAsIiIsMSx7ImN1cnZlIjotMywiY29sb3VyIjpbMjQ5LDY4LDYwXSwic3R5bGUiOnsiYm9keSI6eyJuYW1lIjoiZGFzaGVkIn19fV1d

\[\begin{tikzcd}
	&& {D_8} &&&& {D_8/K} \\
	& {\langle s, r^2 \rangle} & {\langle r \rangle} & {\langle rs, r^2 \rangle} && {\langle sK \rangle} & {\langle rK \rangle} & {\langle rsK \rangle} \\
	{\langle r \rangle} & {\langle r^2s \rangle} & {\langle r^2 \rangle} & {\langle rs \rangle} & {\langle r^3s \rangle} && 1 \\
	&& 1 \\
	&& {\text{Lattice for}\\D_8} &&&& {\text{Lattice for} \\D_8/\langle r^2 \rangle}
	\arrow[Rightarrow, no head, from=1-3, to=2-3]
	\arrow[Rightarrow, no head, from=1-3, to=2-4]
	\arrow[Rightarrow, no head, from=1-3, to=2-2]
	\arrow[Rightarrow, no head, from=2-2, to=3-3]
	\arrow[Rightarrow, no head, from=2-3, to=3-3]
	\arrow[Rightarrow, no head, from=2-4, to=3-3]
	\arrow[no head, from=2-4, to=3-4]
	\arrow[no head, from=2-4, to=3-5]
	\arrow[no head, from=2-2, to=3-2]
	\arrow[no head, from=2-2, to=3-1]
	\arrow[no head, from=3-1, to=4-3]
	\arrow[no head, from=3-2, to=4-3]
	\arrow[no head, from=3-3, to=4-3]
	\arrow[no head, from=3-4, to=4-3]
	\arrow[no head, from=3-5, to=4-3]
	\arrow[no head, from=3-7, to=2-6]
	\arrow[no head, from=3-7, to=2-8]
	\arrow[no head, from=3-7, to=2-7]
	\arrow[no head, from=2-7, to=1-7]
	\arrow[no head, from=2-6, to=1-7]
	\arrow[no head, from=2-8, to=1-7]
	\arrow[color={rgb,255:red,104;green,84;blue,222}, curve={height=18pt}, dashed, from=3-3, to=3-7]
	\arrow[color={rgb,255:red,104;green,84;blue,222}, curve={height=24pt}, dashed, no head, from=2-3, to=2-7]
	\arrow[color={rgb,255:red,104;green,84;blue,222}, curve={height=-18pt}, dashed, from=2-2, to=2-6]
	\arrow[color={rgb,255:red,104;green,84;blue,222}, curve={height=-18pt}, dashed, from=2-4, to=2-8]
	\arrow[color={rgb,255:red,104;green,84;blue,222}, curve={height=-18pt}, dashed, from=1-3, to=1-7]
\end{tikzcd}\]
-->

<center style="filter:invert(100%)">
<img style="width:calc(min(100%, 1000px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/D8_lattice2.JPG">
</center>

Visually we can see that the lattice for $D_8 / K$ has the exact same shape as a "subgraph" of the lattice for $D_8$. In fact, it is everything _above_ the quotient $K$. The Lattice Isomorphism Theorem gives an explicit description of this visual similarity. E.g., it justifies the yellow lines in the image: All groups in $G$ that _contain_ $K$ gets uniquely mapped to a subgroup in $G/K$. In particular, $K$ is mapped to the identity in $G/K$. One can also check that the Lattice Isomorphism Theorem shows that inclusion relations of the "subgraph" in $G$ has the "same shape" as that of $G/K$. In fact, the fifth statement describes something even more that I didn't depict in the visual above: If an inclusion relation is that of "normality" ($A \triangleleft B$) in the lattice of $G$, its corresponding inclusion relation in the lattice of $G/K$ is also that of "normality" ($A/K \triangleleft B/K$).

What about the other subgroups of $G$? In particular, those that don't contain $K$? Where do they get mapped to? Well certainly if $C \le K$, $C$ gets mapped to identity in $G/K$. As for the other groups $D$ (that don't contain $K$) its image under the natural homomorphism from $G \rightarrow G/K$ is the same as the image of the subgroup $DK \le G$; and we have $K \le DK$! This means such a subgroup $D$ gets mapped _into_ one of the subgroups of $G/K$. Visually we have something like this:

<!--
https://q.uiver.app/?q=WzAsMTAsWzIsMCwiRF84Il0sWzIsMSwiXFxsYW5nbGUgciBcXHJhbmdsZSJdLFsxLDEsIlxcbGFuZ2xlIHMsIHJeMiBcXHJhbmdsZSJdLFszLDEsIlxcbGFuZ2xlIHJzLCByXjIgXFxyYW5nbGUiXSxbMiwyLCJcXGxhbmdsZSByXjIgXFxyYW5nbGUiXSxbMSwyLCJcXGxhbmdsZSByXjJzIFxccmFuZ2xlIl0sWzAsMiwiXFxsYW5nbGUgciBcXHJhbmdsZSJdLFszLDIsIlxcbGFuZ2xlIHJzIFxccmFuZ2xlIl0sWzQsMiwiXFxsYW5nbGUgcl4zcyBcXHJhbmdsZSJdLFsyLDMsIjEiXSxbMCwxLCIiLDAseyJsZXZlbCI6Miwic3R5bGUiOnsiaGVhZCI6eyJuYW1lIjoibm9uZSJ9fX1dLFswLDMsIiIsMix7ImxldmVsIjoyLCJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzAsMiwiIiwyLHsibGV2ZWwiOjIsInN0eWxlIjp7ImhlYWQiOnsibmFtZSI6Im5vbmUifX19XSxbMiw0LCIiLDIseyJsZXZlbCI6Miwic3R5bGUiOnsiaGVhZCI6eyJuYW1lIjoibm9uZSJ9fX1dLFsxLDQsIiIsMCx7ImxldmVsIjoyLCJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzMsNCwiIiwwLHsibGV2ZWwiOjIsInN0eWxlIjp7ImhlYWQiOnsibmFtZSI6Im5vbmUifX19XSxbMyw3LCIiLDIseyJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzMsOCwiIiwyLHsic3R5bGUiOnsiaGVhZCI6eyJuYW1lIjoibm9uZSJ9fX1dLFsyLDUsIiIsMix7InN0eWxlIjp7ImhlYWQiOnsibmFtZSI6Im5vbmUifX19XSxbMiw2LCIiLDIseyJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzYsOSwiIiwyLHsic3R5bGUiOnsiaGVhZCI6eyJuYW1lIjoibm9uZSJ9fX1dLFs1LDksIiIsMSx7InN0eWxlIjp7ImhlYWQiOnsibmFtZSI6Im5vbmUifX19XSxbNCw5LCIiLDEseyJzdHlsZSI6eyJoZWFkIjp7Im5hbWUiOiJub25lIn19fV0sWzcsOSwiIiwxLHsic3R5bGUiOnsiaGVhZCI6eyJuYW1lIjoibm9uZSJ9fX1dLFs4LDksIiIsMSx7InN0eWxlIjp7ImhlYWQiOnsibmFtZSI6Im5vbmUifX19XSxbOSw0LCIiLDAseyJvZmZzZXQiOi0xLCJjdXJ2ZSI6MSwiY29sb3VyIjpbMzUyLDc1LDYwXX1dLFs2LDIsIiIsMCx7Im9mZnNldCI6MSwiY3VydmUiOi0xLCJjb2xvdXIiOlszNTIsNzUsNjBdfV0sWzgsMywiIiwwLHsib2Zmc2V0IjotMSwiY3VydmUiOjEsImNvbG91ciI6WzM1Miw3NSw2MF19XSxbNywzLCIiLDAseyJvZmZzZXQiOjEsImN1cnZlIjotMSwiY29sb3VyIjpbMzUyLDc1LDYwXX1dLFs1LDIsIiIsMCx7Im9mZnNldCI6LTEsImN1cnZlIjoxLCJjb2xvdXIiOlszNTIsNzUsNjBdfV1d

\[\begin{tikzcd}
	&& {D_8} \\
	& {\langle s, r^2 \rangle} & {\langle r \rangle} & {\langle rs, r^2 \rangle} \\
	{\langle r \rangle} & {\langle r^2s \rangle} & {\langle r^2 \rangle} & {\langle rs \rangle} & {\langle r^3s \rangle} \\
	&& 1
	\arrow[Rightarrow, no head, from=1-3, to=2-3]
	\arrow[Rightarrow, no head, from=1-3, to=2-4]
	\arrow[Rightarrow, no head, from=1-3, to=2-2]
	\arrow[Rightarrow, no head, from=2-2, to=3-3]
	\arrow[Rightarrow, no head, from=2-3, to=3-3]
	\arrow[Rightarrow, no head, from=2-4, to=3-3]
	\arrow[no head, from=2-4, to=3-4]
	\arrow[no head, from=2-4, to=3-5]
	\arrow[no head, from=2-2, to=3-2]
	\arrow[no head, from=2-2, to=3-1]
	\arrow[no head, from=3-1, to=4-3]
	\arrow[no head, from=3-2, to=4-3]
	\arrow[no head, from=3-3, to=4-3]
	\arrow[no head, from=3-4, to=4-3]
	\arrow[no head, from=3-5, to=4-3]
	\arrow[shift left=1, color={rgb,255:red,230;green,76;blue,97}, curve={height=6pt}, from=4-3, to=3-3]
	\arrow[shift right=1, color={rgb,255:red,230;green,76;blue,97}, curve={height=-6pt}, from=3-1, to=2-2]
	\arrow[shift left=1, color={rgb,255:red,230;green,76;blue,97}, curve={height=6pt}, from=3-5, to=2-4]
	\arrow[shift right=1, color={rgb,255:red,230;green,76;blue,97}, curve={height=-6pt}, from=3-4, to=2-4]
	\arrow[shift left=1, color={rgb,255:red,230;green,76;blue,97}, curve={height=6pt}, from=3-2, to=2-2]
\end{tikzcd}\]
-->

<center style="filter:invert(100%)">
<img style="width:calc(min(100%, 600px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/D8_lattice3.JPG">
</center>

This visual intuition is certainly incredibly powerful. We see lattice diagrams in proofs with a fair amount of parts such as in [Lang's proof of the Butterfly Lemma](https://math.stackexchange.com/questions/3857104/understanding-the-proof-and-meaning-of-the-butterfly-lemma-zassenhaus-langs) as a way to understand how every part interacts together, which is a testament to its explainable power. However, I have some issues with this intuition as I still found it quite limiting.

### Shortfalls of the lattice visual intuition

To illustrate some of the shortfalls, let's try to use lattices to visualise the other isomorphism theorems:

Diamond Isomorphism Theorem:
>
> Let $G$ be a group and let $A$ and $B$ be subgroups of $G$, and assume $A \le N_G(B)$. Then $AB$ is a subgroup of $G$ and $B \trianglelefteq AB$, $A \cap B \trianglelefteq A$ and $AB / B \cong A / A\cap B$.
>
> We can illustrate the Diamond Isomorphism Theorem in "lattice-speak" as such, where I've annotated normality $\triangleleft$ with a tiny slash through the line. A similar diagram is also given in Dummit and Foote:
> 
> <center style="filter:invert(100%)">
> <img style="width:calc(min(100%, 600px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/iso-diamond1.JPG">
> </center>

I have several issues with this lattice visual for the Diamond Isomorphism Theorem:

1. Can you immediately "see" that $A \le N_G(B)$ implies
    1. $B \trianglelefteq AB$
    2. $A \cap B \trianglelefteq A$?
2. Can you immediately "see" that $AB / B \cong A / A\cap B$? They sure look like _pretty_ seperate parts of the diagram!

Next, let's go the deep end and attempt to illustrate the aesthetically pleasing Butterfly Lemma:

> Butterfly Lemma:
>
> Let $G$ be a group with subgroups $A$ and $C$. Suppose $B \triangleleft A$ and $D \triangleleft C$ are normal subgroups. Then 
>
> $$\frac{(A\cap C)B}{(A\cap D)B} \cong \frac{(A\cap C)D}{(B\cap C)D}$$
> 
> And here's [wikipedia's](https://en.wikipedia.org/wiki/Zassenhaus_lemma) admittedly very pretty illustration of all the parts:
> 
> <center style="filter:invert(100%)">
> <img style="width:calc(min(100%, 600px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/Butterfly_lemma.svg.png">
> </center>

Again, are you able to immediately "see" that the isomorphism holds? It does feel like it popped out of nowhere doesn't it? How about the vaidity of taking quotients in the first place? (i.e., that $(A\cap D)B \trianglelefteq (A\cap C)B$ and $(A\cap C)D \trianglelefteq (B\cap C)D$). Furthermore the lattice diagram implies a TONNE of moving parts! But in reality we only have `4` objects of concern here ($A,B,C,D$)! The Butterfly Lemma with this current intuition is notoriously difficult to reason about for newbies, as a cursory search on [math.stackexchange](https://math.stackexchange.com/questions/3857104/understanding-the-proof-and-meaning-of-the-butterfly-lemma-zassenhaus-langs) will tell you.

All in all, I feel the lattice visual suffers from the following core problems:

1. Unable to illustrate other relations between subgroups
    - How are $A$ and $N_G(A)$ related?
    - How are $A,B$ and $A \cap B$ related?
    - How are $A,B$ and $AB$ related?
    - etc.
    - Because we can't illustrate other relations apart from inclusion, we end up with a lot of disjoint parts in our lattice (e.g., we need to illustrate $A$, $B$, $A \cap B$ and $AB$ as seperate points in the lattice for the Diamond Isomorphism Theorem). This not only obscures how these are related, we might end up with so many parts to keep track of like in the Butterfly Lemma.
2. Unable to visualise normality of subgroups, and hence the validity of taking quotients.
    - Like sure we can annotate each line in the lattice to indicate normality, but what if $A \le B \le C$ and we want to illustrate that $A \trianglelefteq C$? (e.g., say $A$ is characteristic in $B$ and $B \trianglelefteq C$.)

Ngl being unable to visualise these connections kept bothering me, which motivated me to concretise a better way to visualise homomorphisms. My ideal visual intuition would make the isomorphism theorems look obvious, and have enough explainability power to visualise more involved concepts. **SO LETS MAKE SOMETHING BETTER**

<!--
- Unable to visualise quotients of quotients: E.g., Dummit Foote omited visualising the Third Isomorphism Theorem.
- Unable to nicely visualise operations on subgroups (intersect, product, etc)
- Unable to properly visualise normality of subgroups (and hence validity of taking quotients)
-->

<!--
1. Summary of all the core issues
2. Motivation for a new intuition
-->

## Abstracting the Lattice: Slicing a Shape

<!--
- Talk about the process of constructing this
    - E.g. MUST ILLUSTRATE AND OBEY THE ISOMORPHISM LAWS
- Include normal pls
- ALso highlight how this intuition, while inspired by lattice, deviates significantly.
- Oh yea for AB, mention that it assumes AB=BA (which is indeed true iff AB is to be a subgroup)
-->

We abstract a group $G$ into a shape (I like to draw a diamond), and we'd like to express the inclusion relation $A \le B$ by having the shape of $A$ be inside the shape of $B$. Since every subgroup of $G$ contains the trivial subgroup $1$, we designate some point on the edge of $G$ to represent $1$, and we need all subgroups of $G$ to contain the point. We can hence represent a subgroup $H$ of $G$ as a slice of $G$, partitioning $G$ with a dashed line. When it is obvious which section $H$ has to be (say, since $H$ has to contain $1$), I'll just annotate the partitioning line.

<center style="filter:invert(100%)">
<img style="width:calc(min(100%, 500px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/slicing1.png">
</center>

We can represent normal groups with a solid line with an arrow indicating its normaliser. This can be read as "$H$ is _normal_ up to $N_G(H)$". The arrow indicates whether it is valid to take quotients. For instance $N_G(H) / H$ is well-defined as $H$ is normal in $N_G(H)$. Similarly, $H \le K \le N_G(H)$ and so $H$ is normal in $K$ and hence $K/H$ is well-defined. Meanwhile, $G$, which the arrow doesn't extend all the way to, indicates that $H \not \trianglelefteq G$ and hence taking $G/H$ is not well-defined.

<center style="filter:invert(100%)">
<img style="width:calc(min(100%, 500px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/slicing2.png">
</center>

Now, we can visually represent $A \cap B$ as the _intersection_ of both of their shapes. As an example, consider $H$ and $K$ be subgroups of $G$. $H \cap K$ is visually represented as the tiny coloured square at the bottom. Furthermore $H \cap K \trianglelefteq N_G(H) \cap N_G(K)$, which can be seen visually below as $N_G(H) \cap N_G(K)$ is _within_ the domains specified by the two arrows ($H \cap K$ is defined by both the _pink_ and _blue_ solid lines, and is hence normal in anything within the domain bounded by both the _pink_ and _blue_ dashed lines). Visually we can also see that $H \cap K \trianglelefteq H\cap N_G(K)$ and $H \cap K \trianglelefteq N_G(H)\cap K$.

<center style="filter:invert(100%)">
<img style="width:calc(min(100%, 500px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/slicing3.png">
</center>

Now when we take quotients, we represent say $A/B$ with the _difference_ in the shape $A$ and $B$, and the identity of $A/B$ to be any point along the line slicing $B$ from $A$ (as long as all subgroups of $A/B$ contain that point). So for instance, reusing the above image, say we have $H \le K \le N_G(H)$ (which implies $H \trianglelefteq K$). Then $H/K$ is well-defined and is represented visually as the coloured region below:

<center style="filter:invert(100%)">
<img style="width:calc(min(100%, 500px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/slicing4.png">
</center>

Visually we are able to see that $H/K$ is well-defined simply because we can visually see that $H \trianglelefteq K$.

Oh! One more! Let's visually represent $HK$ for subgroups $H$ and $K$ in $G$ such that $H \le N_G(K)$. Note that $H \le N_G(K)$ implies that $HK$ is a subgroup of $G$, so that we can still represent $HK$ in our visuals. Now, this _is_ a stronger requirement for $HK$ to be a subgroup than the sufficient requirement that $HK = KH$ ($HK = KH$ iff $HK$ is a subgroup of $G$), but since our visual is going to rely on the Diamond Isomorphism Theorem, I'll leave the case of the weaker requirement $HK = KH$ as future work (I'm lazy). Otherwise, since $H \le N_G(K)$ implies $HK = KH$, our representation of $HK$ has to be _symmetrical_ with respect to $H$ and $K$. We will visually represent $HK$ as the _union_ of the shapes $H$ and $K$, which makes sense as $HK$ is the smallest subgroup that contains both $H$ and $K$:

<center style="filter:invert(100%)">
<img style="width:calc(min(100%, 500px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/slicing5.png">
</center>

As mentioned earlier, whatever representation we choose for $HK$ has to obey the Diamond Isomorphism Theorem so for recap here it is again:

> Diamond Isomorphism Theorem:
>
> Let $G$ be a group and let $H$ and $K$ be subgroups of $G$, and assume $H \le N_G(K)$. Then $HK$ is a subgroup of $G$ and $K \trianglelefteq HK$, $H \cap K \trianglelefteq H$ and $HK / K \cong H / H\cap K$.

Now we can check the visual. From the visual, one can visually verify that $H \le N_G(K)$ implies both $K \trianglelefteq HK$ and $H \cap K \trianglelefteq H$. Furthermore, we can visually verify that $HK / K \cong H / H\cap K$:

<center style="filter:invert(100%)">
<img style="width:calc(min(100%, 900px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/slicing6.png">
</center>

Notice that unlike the lattice visual above, $HK / K$ and $H / H\cap K$ occupies the exact same space in the diagram and we can therefore _visually see_ that they are "equal".

I'll be visualising more isomorphism theorems below but if you wanna you can check that this visual intuition obeys all the other isomorphism laws (really naturally too!).

# Applications

## Isomorphism Theorems Visualised

Alright let's put this intuition to good use! We'll first start simple and visualise some Isomorphism Theorems. Here's the Third Isomorphism Theorem visualised:

> Third Isomorphism Theorem:
> Let $G$ be a group and let $H$ and $K$ be normal subgroups of $G$ with $H \le K$. Then $K/H \trianglelefteq G/H$ and $(G/H)/(K/H) \cong G/K$.
>
> <center style="filter:invert(100%)">
> <img style="width:calc(min(100%, 900px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/third-iso-slice.png">
> </center>

Now recall that above, the Butterfly Lemma, when visualised with the lattice, looks pretty complicated. With our new visuals, the simplicity of the Butterfly Lemma becomes apparent:

> Butterfly Lemma:
>
> Let $G$ be a group with subgroups $A$ and $C$. Suppose $B \triangleleft A$ and $D \triangleleft C$ are normal subgroups. Then 
>
> $$\frac{(A\cap C)B}{(A\cap D)B} \cong \color{cyan}{\frac{A \cap C}{(A \cap D)(B \cap C)}} \cong \frac{(A\cap C)D}{(B\cap C)D}$$
> 
> <center style="filter:invert(100%)">
> <img id="butterfly-slice" style="width:calc(min(100%, 1000px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/butterfly-slice.png">
> </center>
> 
> Are you able to see the Diamond Isomorphism Theorem that's used to prove the Butterfly Lemma? If not, do go back up to see how the Diamond Isomorphism Theorem looks like in our visuals. 
> 

The key benefit of using our new visuals is that we can express how different groups relate to each other _without_ drawing new things (e.g., conversely, in the Lattice visuals $A$, $B$, $AB$ and $A\cap B$ are drawn seperately). This makes our visuals very economical. For instance, our visuals for the Butterfly Lemma is simple enough that we can _visually_ see how it is true AND how one can go about proving it.

However, do note that there is the fundamental limitation that our visuals are in 2D and hence the amount of relationships we can capture is rather limited (e.g., try to visualise 3 different _composition series_ of the same group with this visual. I can't, unless I move to 3D).

## Subgroup Series

### Composition Series

Recall that a _composition series_ of a group $G$ is a sequence of subgroups

$$
1 = N_0 \le N_1 \le \cdots \le N_{k-1} \le N_k = G
$$

such that $N_i \trianglelefteq N_{i+1}$ and $N_{i+1}/N_i$ is a simple group, for $0 \le i \le k-1$. $N_{i+1}/N_i$ are known as the _composition factors_ of $G$. 

For finite groups, the _composition factors_ of $G$ are often described as analagous to the _prime numbers_. We can see this analogy by visualising the Jordan-Hölder Theorem:

> Jordan-Hölder Theorem (Informal):
> Let $G$ be a finite group where $G \ne 1$. Then $G$ has a _composition series_. While said _composition series_ isn't unique in general, the _composition factors_ are unique up to permutation.
>
> <center style="filter:invert(100%)">
> <img style="width:calc(min(100%, 600px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/jordanholder-slice1.png">
> </center>
>
> Visually, it means we can slice the shape of $G$ up into smaller regions, and no matter how we slice $G$ up, we'll always end up with the same "smaller regions". Note that since each composition factor $N_{i+1}/N_i$ is simple, we cannot take non-trivial quotients. Visually, it means we can't slice each coloured region further.
>
> This is analogous to the "unique factorisation" property of the natural numbers, where we can decompose a natural into irreducible _prime numbers_, and such decomposition over the naturals is unique.

<!--
TODO: Visual proof of the Jordan-Hölder Theorem?
-->

Is there a visual way to see _why_ the Jordan-Hölder Theorem holds? Turns out there is! I've written a [follow-up post](/mathematics/2022/12/21/visual-proof-schreier-jordan-holder.html) using the visual intuition built here to provide a visual proof of the Jordan-Hölder and related theorems.

### Other Subgroup Series

These visuals make certain propositions seem "obvious". For instance, when a group is _Nilpotent_, it has a [_Lower Central Series_](https://groupprops.subwiki.org/wiki/Lower_central_series). Visually, this slices the group similarly to above into sections, and each section $G_{i+1}/G_i$ is the _center_ of the quotient $G/G_i$. Now, we know that $p$-groups have non-trival centers, and every quotient of a $p$-group is also a $p$-group, so each of the "section"s are non-trivial. Can you see that every $p$-group is _Nilpotent_? Furthermore, can you see that the number of sections (the _nilpotent class_ of the group) for a $p$-group of size $p^a$ has a maximum of $a-1$ (which happens when each factor group is of size $p$)?

Similarly, for a [_Solvable Group_](https://en.wikipedia.org/wiki/Solvable_group) $G$, where we have each factor group $G_{i+1}/G_i$ be abelian, one can visually see that if $H \trianglelefteq G$ and $G/H$ is solvable, then $G$ is solvable. In fact, one can visually see that if $H$ has a solvable length $< h$ and $G/H$ has a solvable length of $< q$, then $G$ has a solvable length of $< h + q$.

<center style="filter:invert(100%)">
<img style="width:calc(min(100%, 600px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/solvable-slice1.png">
</center>

Conversely, we can also visually see that if $G$ is solvable, and $H \trianglelefteq G$, then $H$ and $G/H$ is solvable too!

<center style="filter:invert(100%)">
<img style="width:calc(min(100%, 600px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/solvable-slice2.png">
</center>

Of course, the visuals aren't everything. E.g., One would have to verify, for instance, that each section of $G/H$ is well-defined and abelian.

A fun exercise would be to try to visualise the _Commutator Series_ of a group $G$ with relation to any one of its series with abelian factor groups. In particular, that the _Solvable Length_ of $G$ is well-defined (always the same regardless of the series one picks for $G$), and that in some sense, the _Commutator Series_ is the "fastest descending" series for $G$.

<!--
TODO: Direct products?
-->

## Abelian Groups and Other Abelian Things

For abelian groups, every subgroup is going to be normal, so there's no more need to draw the arrows ever! However, we still do need to indicate a direction somehow (a flow from the subgroup to the quotients, we don't ever want to confuse those two!). Why not draw our "slice" with a tiny wedge to indicate direction?

<center style="filter:invert(100%)">
<img style="width:calc(min(100%, 300px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/abelian-slice.png">
</center>

Well I'm not the first to come up with this! [Puzzling Through Exact Sequence](https://www.3blue1brown.com/blog/exact-sequence-picturebook) starts with this specialisation of our visuals that we build here _specifically_ for abelian things and took that intuition really far. Highly recommend reading that.

Turns out whatever we've been building in this post is a generalisation of _Puzzling Through Exact Sequence_'s intuition! Which hints that the intuition presented in this post could potentially be used for other algebraic objects.

<center>
    <a href="#">
    <img style="height:1.5em; padding-top:3em" src="/assets/img/feather.svg">
    </a>
</center>