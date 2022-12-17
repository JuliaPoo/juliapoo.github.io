---
layout: post
author: JuliaPoo
category: Unlisted # Math

display-title: "Homomorphisms Illustrated"
tags:
    - math
    - algebra
    - homomorphism

nav: |
    * TODO
    
excerpt: Visual intuitions I've accrued while studying algebra, starting with a geometric interpretation of the isomorphism theorems and application into more "involved" concepts like composition series. Currently very Group focused, might update for more objects.
---

# Metadata

<!--
1. Brief Timeline
1. Motivation
2. Overview
    - Predictive power
-->

## Motivation

~~NA~~

So I started learning abstract algebra from [Basic Algebra I by Nathan Jacobson](http://www.math.toronto.edu/~ila/Jacobson-Basic_algebra_I%20(1).pdf) earlier this year, and being a rather dense resource it lacked any form of discourse on the intuition of the concepts. Despite that I formed my own visual intuition of certain concepts, and relied upon it up till Galois Theory. And then I lost interest. 

Fast forward to a few months later I got recommended **The** [Dummit and Foote](https://www.wiley.com/en-us/Abstract+Algebra%2C+3rd+Edition-p-9780471433347) which is an easier resource with plenty of intuition discussed. However, having formed my own intuition already, I realised the intuition written there had some shortcomings, but it helped in fixing certain issues in my intuition and is really an amazing and clear resource.

AND THEN I saw this [neat little visual](/assets/posts/2022-12-15-homomorphism-illustrated/PuzzlingThroughExactSequences-23.svg) on the [Snake Lemma](https://en.wikipedia.org/wiki/Snake_lemma) from [Puzzling Through Exact Sequences](https://www.3blue1brown.com/blog/exact-sequence-picturebook) and that motivated me to "concretise" my visual intuitions. Turns out my intuition is a generalisation of the intuition presented in _Puzzling Through Exact Sequences_.

Here, I'm going to describe the intuitions I've been using, starting from the most "concrete" and building up to those more "abstract", and demonstrate its predictive power in some examples, and as a treat, "specialise" this intuition for abelian groups to connect my interpretation with that from _Puzzling Through Exact Sequences_. This post is going to be very Groups focused but I'm sure there are ways to carry this to other structures like Rings. Will update this post when I get around to that.

This post is going to be VERY non-rigourous and assume some familiarity with the algebra behind. The intention is not to introduce the concepts but to detail certain intuitions one might miss out on.

# First Isomorphism Theorem

We start with some fairly standard visual intuition of the first isomorphism theorem, which states:

> Let $G$ and $H$ be groups, and let $f : G \rightarrow H$ be an epimorphism and $K = \text{ker}\;f$. Then $K \trianglelefteq G$ and $H \cong G / K$.

The core claim here is that $G / K$ has "the same structure" as $H = \text{Im}\; f$. We build the visual intuition from the fact that $G$ is evenly partitioned by the cosets of $K$, and that $G / K$ is precisely the "structure" of these cosets.

<center>
<img style="width:calc(min(100%, 600px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/iso-1.svg">
</center>

The visual here shows the additive group $\\{(0,0), (0,1), (1,0), (1,1), (2,0), (2,1)\\} = \mathbb{Z}_3 \times \mathbb{Z}_2$, with two generators $(0,1)$ and $(1,0)$. The red lines correspond to adding $(0,1)$ and the blue arrows correspond to adding $(1,0)$. We have an epimorphism $f$ to $\mathbb{Z}_2$ with kernel $\mathbb{Z}_3$.

From the visual, we can see that an epimorphism collapses the kernel $K$ into a single point in the image $G / K$. All the other cosets of $K$ in $G$ are similarly collapsed into a unique point in $G/K$. Some properties become immediately apparent, such as [_Lagrange's Theorem_](https://en.wikipedia.org/wiki/Lagrange%27s_theorem_(group_theory)) ($\|G / K\| = \|G\|\,/\,\|K\|$ for finite $G$), as each point in $G / K$ is "made up" of $\|K\|$ elements in $G$. Furthermore, the collapsing of the cosets into single points reveals some structure of $G$: The red line on the right side of the visual, indicative of the structure of $G/K$, corresponds to the three red lines on the left side. More generally, the group operation on $G$ is well-defined over the cosets of $K$.

Collapsing some structure (that of $\text{ker}\;f = K$) into a single point begets the intuition that some structural information is lost upon a homomorphism $G \rightarrow G /K$ (in particular, a non-injective homomorphism) while retaining some information about the original structure (The red line on the right side of the visual): We are "collapsing" off some part of the structure to obtain the image of a homomorphism. This, I presume, is the origin of the term "quotient" and why its syntax bares resemblence to "dividing".

The First Isomorphism Theorem is also often stated with the following:

> For every normal subgroup $K$ of $G$, there is an epimorphism $f: G \rightarrow G / K$. (Via the first isomorphism theorem, this requires that $\text{ker}\;f = K$). Such an epimorphism can simply be the natural epimorphism of $g \in G$ into its coset $gK \in G/K$.

Hence, when studying homomorphisms, we are also studying normal subgroups. This visual can therefore also serve as intuitions about normal subgroups.

Unfortunately this visual intuition is very limited. It is difficult to see what exactly I mean by "collapsing". What was removed and what is left? The idea of "collapsing" the structure of $G$ will be made more explicit in the **Lattice Isomorphism Theorem** where we'll see a more common (and useful) way to visualise homomorphisms. 

# Lattice Isomorphism Theorem: Collapsing the Lattice

The _Lattice Isomorphism Theorem_ often seems rather opaque:

> **(Dummit and Foote)** Let $G$ be a group and let $N$ be a normal subgroup of $G$. Then there is a bijection from the set of subgroups $A$ of $G$ which contain $N$ onto the set of subgroups of $G / N$, given by the map $A \rightarrow A/N$. In particular, every subgroup of $G/N$ is of the form $A/N$ for some subgroup $A$ of $G$ containing $N$ (namely, its preimage in $G$ under the natural projection homomorphism from $G$ to $G/N$). This bijection has the following properties: for all $A,B \le G$ with $N \le A$ and $N \le B$,
> 
> 1. $A \le B$ iff $A/N \le B/N$
> 2. If $A \le B$, then $\|B:A\| = \|B/N : A/N\|$
> 3. $\langle A,B \rangle / N = \langle A/N, B/N \rangle$
> 4. $A \cap B = A/N \cap B/N$
> 5. $A \trianglelefteq G$ iff $A/N \trianglelefteq G/N$

But this is because this theorem essentially formalises a way to visualise quotients by slicing the [Lattice of Subgroups](https://en.wikipedia.org/wiki/Lattice_of_subgroups). Dummit and Foote goes through in quite detail the visual implications of the _Lattice Isomorphism Theorem_ on the _Lattice of Subgroups_. However, since the visual intuition I present in the next section essentially builds on the intuition presented in Dummit and Foote, for completeness I'll touch a little on this.

First off, the _Lattice of Subgroups_ of a group $G$ can be seen to encode the structure of $G$. For illustration purposes I'll only be focusing on the [(finite) Dihedral Group](https://en.wikipedia.org/wiki/Dihedral_group) $D_8$:


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

Each line that connects two groups indicates _inclusion_, i.e., one is a subgroup of another (e.g., $\langle r^2 \rangle < \langle r \rangle$). Do note that while _the shape_ of the lattice encodes structure of the group, a particular "shape" is by no means unique to a subgroup (e.g., take the lattice for $\mathbb{Z}_2$ and $\mathbb{Z}_3$, which consists of a single line connecting $1$ to itself).

The _Lattice Isomorphism Theorem_ gives an intuition for taking quotients by collapsing the lattice diagram. Say for insance we take $K = \langle r^2 \rangle$ and consider the lattice for $D_8 / K$ (you do first need to check that $\langle r^2 \rangle \trianglelefteq D_8$):

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
<img style="width:calc(min(100%, 900px));" src="/assets/posts/2022-12-15-homomorphism-illustrated/D8_lattice2.JPG">
</center>

Visually we can see that the lattice for $D_8 / K$ has the exact same shape as a "subgraph" of the lattice for $D_8$. In fact, it is everything _above_ the quotient $K$. The _Lattice Isomorphism Theorem_ gives an explicit description of this visual similarity. E.g., we collapse $K = \langle r^2 \rangle$ into the identity in $G/K = D_8/K$, the bottom of the lattice of $G/K$. The _Lattice Isomorphism Theorem_ justifies the yellow lines in the image, that maps all groups in $G$ that _contain_ $K$ gets mapped to a subgroup in $G/K$. One can check that the _Lattice Isomorphism Theorem_ also shows that inclusion relations of the "subgraph" in $G$ has the same shape as that of $G/K$. In fact, the fifth statement justifies something even more that I didn't depict in the visual above: If an inclusion relation is that of "normality" ($A \triangleleft B$), in the lattice of $G$, it's corresponding inclusion relation in the lattice of $G/K$ is also that of "normality" ($A/K \triangleleft B/K$).

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

This visual intuition is certainly incredibly powerful. We see lattice diagrams in proofs with a fair amount of parts such as in [Lang's proof of the Butterfly Lemma](https://math.stackexchange.com/questions/3857104/understanding-the-proof-and-meaning-of-the-butterfly-lemma-zassenhaus-langs) as a way to understand how every part interacts together. However, I have some issues with this intuition as I found its predictive power quite limiting.

## Shortfalls with this visual intuition

<!--
- Unable to visualise quotients of quotients: E.g., Dummit Foote omited visualising the Third Isomorphism Theorem.
- Unable to nicely visualise operations on subgroups (intersect, product, etc)
- Unable to properly visualise normality of subgroups (and hence validity of taking quotients)
-->

To illustrate some of these shortfalls, lets try to use lattices to visualise the other isomorphism theorems:



# Abstracting the Lattice: Slicing a Shape

- Include normal pls
- ALso highlight how this intuition, while inspired by lattice, deviates significantly.
- Able to visualise quotients in quotients (because each slice of a rectangle is another rectangle)

# Applications

## Isomorphism Theorems Visualised

+ Butterfly Lemma

## Composition Series

### Jordan–Hölder Theorem

### Solvable Groups

### Nilpotent Groups

## Semidirect and Direct Products

## Abelian Groups and Other Abelian Things
