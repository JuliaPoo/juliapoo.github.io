#import "shared/template.typ": *
// START METADATA //
#show: doc => template(
  layout: "post",
  author: "JuliaPoo",
  category: "Mathematics",
  display-title: "You Could've Discovered the Yoneda Lemma",
  tags: ("math", "category-theory", "yoneda-lemma",),
  excerpt: "An exposition on the Yoneda Lemma that's accessible to those without a math background. The Yoneda Lemma is a very useful statement in Category Theory which is usually communicated as ''you can completely understand something by observing how everything else relate to it''. It has been the subject of intense hype amongst pseudo-intellectual circles surrounding tech and AI, despite how, as we'll see in this post, the statement of the Yoneda Lemma is surprisingly dull.",
  doc
)
// END METADATA //

#outline(title: [Outline])
#set heading(numbering: "1.")

#import "@preview/theoretic:0.3.1"
#import theoretic.presets.corners: *
#show ref: theoretic.show-ref

#let theorem = theoretic.theorem.with(
  show-theorem: it => {
    show quote: set pad(0em) // Trick to get it to work in pdf
    quote(block: true, show-theorem(it))
  }
)

#let lemma = theoretic.theorem.with(
  supplement: "Lemma", kind: "lemma",
  show-theorem: it => {
    show quote: set pad(0em) // Trick to get it to work in pdf
    quote(block: true, show-theorem(it))
  }
)

#let Nat = "Nat"
#let Set = "Set"
#let Hom = "Hom"


= Introduction

The Yoneda Lemma has gained quite an aura of mystic recently (recently?) as a statement with deep philosophical intent. It's usually phrased in a somewhat abstracted way like "to know thine own self, an individual needeth but seek to comprehend those who surrounds them." or some other vague aphorism. While there is indeed some value to overly abstracted explanations of the Yoneda Lemma, however mystified (or mythified) they are, amongst certain spheres in the vibrant tapestry of human expression lies a group of pseudo-intellectuals who elevate the lemma to, perhaps, a level of divinity? As if the lemma speaks to some sort of spiritual truth.

Take for instance the following examples:
- #link("https://www.essentiafoundation.org/relational-quantum-dynamics-and-indras-net-a-non-dual-understanding-of-quantum-reality/reading/")[Relational Quantum Dynamics]: A "theory" of um... I don't actually know. Mahayana Buddhism gets mentioned somewhere. Indra's Net seems to be a common theme in these sorts of articles.
- #link("https://yon-lang.org/")[Yon-lang]: A.... topos-oriented programming language? What? It mentions the Mathieu group $M_24$ and related concepts several times.
- #link("https://www.relateful.com/blog/Theyonedalemma")[The Relateful Company]: A self-help company which has this to say about the Yoneda Lemma.

I want to clarify though, the Yoneda slogan _is legitimate in mathematics_ and is beloved by mathematicians. The crackpottery is treating it as a foundational truth of _reality_. 

Perhaps this isn't too surprising. Mathematics itself is often mythologised as the Purest of Truth, and those who pursue it as The Intelligents of the Intelligent (I have an upcoming post about this). Category theory, in which the Yoneda Lemma is foundational in, is justly referred to as _the language of mathematics_, and is hence subject to the same mythologising. Afterall, part of the vast utility of the Yoneda Lemma is because it is an 'obvious' statement in a language with vast applicability in mathematics.

And obvious it is, as I'll posit in this post. With the right pictures in your head, the Yoneda Lemma will seem more akin to a tautology (like _it is what it is_). And this is what I'll be trying to achieve in this article: To put the right pictures in your head so that the Yoneda Lemma seems almost boring. This is, in my opinion, the first step to understanding the applicability and genius of the Yoneda Lemma, as the magic lies not in the statement itself, but in the _language_ that makes the statement even possible to state.

This article is written to be understandable even to people who do not have much of a background in mathematics (headingowever, some familiarity with concepts like "sets" and "functions" are required). Hence, I'll be expositing informally, but in great detail, the basic language of Category Theory, but will not elaborate on its vast applicability to mathematics. This is, perhaps, a shame, as the language of category theory cannot be properly appreciated without sufficient mathematical maturity. For the unlikely few who have read this far and are interested in such an exposition, I highly recommend Emily Riehl's Category Theory in Context. Otherwise, this article will not help in a greater appreciation of the Yoneda Lemma for mathematics itself.

= Basic Definitions

The precise statement of the Yoneda Lemma requires constructions from Category Theory to understand, which I'd be unpacking later in this post. For now, as a bird's eye view, I'll first state the precise statement as typically presented, and summarise at a high level what its saying before diving into the details. So first, the Yoneda Lemma:

#lemma([Yoneda], label: "yoneda-orig")[
  Let $cal(C)$ be a locally small category. For any functor $F: cal(C) -> Set$,
  $
    Nat(Hom(A, -), F) tilde.equiv F A
  $
  naturally in $A in cal(C)$ and in $F in [cal(C), Set]$
]

At a high level, the Yoneda Lemma asserts the existence of a certain _bijection_ between two sets $Nat(Hom(A, -), F)$ and $F A$, which I'd be describing shortly. This _bijection_ is _structure preserving_ in some sense, and a consequence of this allows one to capture the "properties" of $A$ as the "set of functions" going out of $A$, written $Hom(A, -)$. As Tom Leinster puts it in @leinster2014basic, $Hom(A, -)$ can be thought of as "how $A$ sees the world".

Regretfully, for illustration purposes, I'd only be expositing on a weaker version of the lemma. In particular, I'll simply be illustrating the _bijection_, and disregarding the _structure preservation_. I've also replaced _locally small_ with _small_ so I can avoid certain technical issues in the later discussions.

#lemma([Yoneda Modified], label: "yoneda-mod")[
  Let $cal(C)$ be a small category. For any functor $F: cal(C) -> Set$, there is a bijection:
  $
    Nat(Hom(A, -), F) tilde.equiv F A
  $
]


== Categories

== Functors

== Natural Transforms

== Hom-Functors

= The Yoneda Lemma

== The Yoneda Slogan

== The Yoneda Slogan

#bibliography("shared/everything.bib")