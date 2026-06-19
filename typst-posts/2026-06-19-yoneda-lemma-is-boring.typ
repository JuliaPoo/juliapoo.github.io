#import "shared/template.typ": *
// START METADATA //
#show: doc => template(
  layout: "post",
  author: "JuliaPoo",
  category: "Mathematics",
  display-title: "You Could've Discovered the Yoneda Lemma",
  tags: ("math", "category-theory", "yoneda-lemma",),
  excerpt: "An exposition on the Yoneda Lemma that's accessible to those without a math background. The Yoneda Lemma is a very useful statement in Category Theory which is usually communicated as 'you can completely understand something by observing how everything else relate to it'. It has been the subject of intense hype amongst pseudo-intellectual circles surrounding tech and AI, despite how, as we'll see in this post, the statement of the Yoneda Lemma is surprisingly dull.",
  doc
)
// END METADATA //

#outline(title: [Outline])

#figure(image("assets/posts/2026-06-19-yoneda-lemma-is-boring/seraph-moon.jpg"), caption: "Seraph and Seline's beautiful jessa")

= Header 1

#lorem(100)

== Header 2

#lorem(100)

== Test

This is some sample ballalayolehoooo.

$
  sum_(n=1)^infinity 1/n^2 = pi^2/6
$

Also maybe some inline equations hehe like $M$ and $lim_(n -> infinity) x_n = 0$ yippie. #lorem(100)

Also some more features:

+ List 1
+ List 2
  + List 2.1
  + List 2.2
+ List 3

- List 1
- List 2
  - List 2.1
  - List 2.2
- List 3


Code formatting like *bold*, _italics_, `raw`.

How about codeblocks?

```python
def map(xs, f):
  return [f(x) for x in xs]
```

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "@preview/xarrow:0.3.1": xarrow
#import fletcher: shapes
#import "@preview/theoretic:0.3.1"
#import "@preview/wrap-it:0.1.1": wrap-content
#import theoretic.presets.basic: *
#show ref: theoretic.show-ref

#let nonumeq = math.equation.with(block: true, numbering: none)
#let dm(x) = box[#nonumeq[#x]]
#let dfrac(x,y) = math.frac(dm(x),dm(y))
#let srm = h(-1pt)

#let emphh(body) = {alert()[*#body*]}
#let meta(body) = text(fill: rgb("#f50273"))[*#body*]
#let meta2(body) = text(fill: rgb("#2233ff"))[*#body*]

#let tensor = sym.times.o
#let Fst = math.op("Fst")
#let Snd = math.op("Snd")
#let Chu = math.op("Chu")
#let Mix = math.op("Mix")
#let inr = math.op("inr")
#let inl = math.op("inl")
#let prom = math.op("prom")
#let assoc = math.op("assoc")
#let coev = math.op("coev")
#let parr = math.op(sym.amp.inv)
#let loli = sym.multimap
#let ev = math.op("ev")
#let ofc = math.op("!")
#let why = math.op("?")
#let dplus = $plus.o$
#let with = math.op($amp$)
#let Kl = math.op("Kl")
#let coKl = math.op("coKl")
#let der = math.op("der")
#let colim = math.op("colim")
#let inj = sym.arrow.hook
#let op = math.op("op")
#let yo = math.op(box(height: 1em, inset: (left:-.2em, right: -.3em), text(baseline: .2em, size: 1.3em, "よ")))
#let Parr = math.class(
  "large",
  {
    set text(size: 1.4em)
    sym.amp.inv
  }
)

#let With = math.class(
  "large",
  {
    set text(size: 1.4em)
    sym.amp
  }
)
#let Tensor = tensor.big
#let bigdot = math.op($circle.filled.small$)
#let cut(a,b) = $lr(chevron.l #a mid(||) #b chevron.r)$
#let inner(a,b) = $lr(chevron.l #a, #b chevron.r)$
#let meow = it => box(width: 0em, text(size: 1em, box(width: 10em, {show math.equation: set text(size: 0.7em); it})))


#let debug = false

#let debug-section = if (debug) { section } else { it => [] }

#let bra(..b) = {
    let cnt = b.pos().join(", ")
    $chevron.l #cnt chevron.r$
}
#let ii(b) = $bracket.stroked.l #b bracket.stroked.r$
#let sslash = $#h(.2em) slash.double #h(.2em)$
#let cf(a,b, c:none) = context {
    let cnt = stack(spacing: 0.3em, a, b);
    let wd = measure(cnt).width; 
    let sza = measure(a)
    let szb = measure(b);
    stack(
      dir: ltr, {set align(center)
      stack(
          spacing: 0.3em,
          block(height: sza.height, {set align(bottom); a}, inset: (bottom: 0.1em)),
          line(length: wd + 0.5em, stroke: 0.6pt + white),
          block(height: szb.height, {set align(top); b})
      )},
      {set align(bottom); block(inset:(bottom: szb.height + 0em, left: 0.3em), c)}
    )
}

#let Chu = "Chu"
#let Mix = "Mix"
#let inr = "inr"

#let conjecture = theoretic.theorem.with(supplement: "Conjecture", variant: "plain")

#let approach = theoretic.theorem.with(supplement: "Approach", variant: "definition")

#let intuition = theoretic.theorem.with(supplement: "Intuition", variant: "definition")

#let proof-sketch = theoretic.theorem.with(supplement: "Proof Sketch", variant: "proof", number:none, suffix: "∎")

#let convention = theoretic.theorem.with(supplement: "Convention", variant: "definition")

#pagebreak()

= LK and LJ Calculi

For the LK calculus, we follow the presentation in @DOWNEN_ARIOLA_2018 but make a small adjustment. We define $not A := A -> bot$ where $bot$ is the unit of $and$. This allows the $not$-intro rules to be subsumed by $->$-intro rules, and later, to be able to define the LJ calculus as a restriction of LK where each sequent has _exactly_ one formula on the right (as opposed to _at least one_ in Gentzen's original presentation).

Further, while $->$ can defined as $A -> B := not A or B$ in LK, I'll state the $->$ rules explicitly as $A -> B := not A or B$ does not hold in LJ. This'll allow us to realise LJ as a restriction of LK as mentioned above. To keep LK symmetrical, I'll also state rules for $-$ (co-implication/subtraction).

== LK Calculus Formulation of Classical Logic

A sequent in LK calculus is $Gamma tack Delta$ where both $Gamma$ and $Delta$ represent multi-sets of formulas. The derivation rules are as follows:


$
 #[*Core Rules*] \ 
 #cf($$, $A tack A$, c:"Ax")
 quad quad
 #cf($Gamma tack A, Delta quad Gamma', A tack Delta'$, $Gamma, Gamma' tack Delta, Delta'$, c:"Cut")
$

$
 #[*Structural Rules*] \ 
 #cf($Gamma tack Delta$, $Gamma tack A, Delta$, c: "WR")
 quad quad
 #cf($Gamma tack Delta$, $Gamma, A tack Delta$, c:"WL")
 quad quad
 #cf($Gamma tack A, A, Delta$, $Gamma tack A, Delta$, c:"CR")
 quad quad
 #cf($Gamma, A, A tack Delta$, $Gamma, A tack Delta$, c:"CL") \
 #cf($Gamma tack Delta$, $sigma(Gamma) tack sigma'(Delta)$, c:"Exch")
$

$
 #[*Logical Rules*] \
 #cf($$, $Gamma tack top, Delta$, c:[$top$R])
 quad quad
 #[no $top$L rule]
 quad quad
 #[no $bot$R rule]
 quad quad
 #cf($$, $Gamma, bot tack Delta$, c:[$bot$L]) \

 #cf($Gamma tack A, Delta quad Gamma tack B, Delta$, $Gamma tack A and B, Delta$, c:[$and$R])
 quad quad
 #cf($Gamma, A tack Delta$, $Gamma, A and B tack Delta$, c:[$and$L1])
 quad quad
 #cf($Gamma, B tack Delta$, $Gamma, A and B tack Delta$, c:[$and$L2]) \

 #cf($Gamma tack A, Delta$, $Gamma tack A or B, Delta$, c:[$or$R1])
 quad   
 #cf($Gamma tack B, Delta$, $Gamma tack A or B, Delta$, c:[$or$R2])
 quad quad
 #cf($Gamma, A tack Delta quad Gamma, B tack Delta$, $Gamma, A or B tack Delta$, c:[$or$L]) \

 #cf($Gamma tack A, Delta quad X "free in" {Gamma, Delta}$, $Gamma tack forall X.A, Delta$, c:[$forall$R])
 quad quad
 #cf($Gamma, A[X := B] tack Delta$, $Gamma, forall X. A tack Delta$, c:[$forall$L]) \
 
 #cf($Gamma tack A[X := B], Delta$, $Gamma tack exists X. A, Delta$, c:[$exists$R])
 quad quad
 #cf($Gamma, A tack Delta quad X "free in" {Gamma, Delta}$, $Gamma, exists X. A tack Delta$, c:[$exists$L])
$

$
 #[*Derived Rules*] \
 #cf($Gamma, A tack B, Delta$, $Gamma tack A -> B, Delta$, c:[$->$R])
 quad quad
 #cf($Gamma tack A, Delta quad Gamma', B tack Delta'$, $Gamma, Gamma', A -> B tack Delta, Delta'$, c:[$->$L]) \

 #cf($Gamma tack A, Delta quad Gamma', B tack Delta'$, $Gamma, Gamma' tack A - B, Delta, Delta'$, c:[$-$R])
 quad quad
 #cf($Gamma, A tack B, Delta$, $Gamma, A - B tack Delta$, c:[$-$L]) \

 #cf($Gamma, A tack Delta$, $Gamma tack not A, Delta$, c:[$not$R])
 quad quad
 #cf($Gamma tack A, Delta$, $Gamma, not A tack Delta$, c:[$not$L])
$

#note()[
Due to the left and right structural rules, the following two cut rules are equivalent:

$
  #cf($Gamma tack A, Delta quad Gamma', A tack Delta'$, $Gamma, Gamma' tack Delta, Delta'$, c:"Cut")
  quad quad
  #cf($Gamma tack A, Delta quad Gamma, A tack Delta$, $Gamma tack Delta$, c:"Cut")
$

The former is used to better connect LK and LJ calculus, as LJ calculus has restricted structural rules. This choice affects the $->$L and $-$R rules.
]

== LJ Calculus Formulation of Intuitionistic Logic

As mentioned previously, the LJ calculus is a restriction of LK calculus such that all sequences have exactly one formula on the right $Gamma tack A$. This prohibits all right-structural rules and the $-$R rule (hence I omit all $-$ rules in LJ). Further, the $->$ rule is no longer 'derived' and has to be asserted explicitly as the LK theorem $not A or B tack.l tack.r A -> B$ no longer holds in LJ. Explicitly, the derivation rules of LJ calculus is as follows:

$
 #[*Core Rules*] \ 
 #cf($$, $A tack A$, c:"Ax")
 quad quad
 #cf($Gamma tack A quad Gamma', A tack B$, $Gamma, Gamma' tack B$, c:"Cut")
$

$
 #[*Structural Rules*] \ 
 #cf($Gamma tack B$, $Gamma, A tack B$, c:"WL")
 quad quad
 #cf($Gamma, A, A tack B$, $Gamma, A tack B$, c:"CL")
 quad quad
 #cf($Gamma tack A$, $sigma(Gamma) tack A$, c:"Exch")
$

$
 #[*Logical Rules*] \
 #cf($$, $Gamma tack top$, c:[$top$R])
 quad quad
 #[no $top$L rule]
 quad quad
 #[no $bot$R rule]
 quad quad
 #cf($$, $Gamma, bot tack A$, c:[$bot$L]) \

 #cf($Gamma tack A quad Gamma tack B$, $Gamma tack A and B$, c:[$and$R])
 quad quad
 #cf($Gamma, A tack C$, $Gamma, A and B tack C$, c:[$and$L1])
 quad quad
 #cf($Gamma, B tack C$, $Gamma, A and B tack C$, c:[$and$L2]) \

 #cf($Gamma tack A$, $Gamma tack A or B$, c:[$or$R1])
 quad   
 #cf($Gamma tack B$, $Gamma tack A or B$, c:[$or$R2])
 quad quad
 #cf($Gamma, A tack C quad Gamma, B tack C$, $Gamma, A or B tack C$, c:[$or$L]) \

 #cf($Gamma tack A quad X "free in" Gamma$, $Gamma tack forall X.A$, c:[$forall$R])
 quad quad
 #cf($Gamma, A[X := B] tack C$, $Gamma, forall X. A tack C$, c:[$forall$L]) \
 
 #cf($Gamma tack A[X := B]$, $Gamma tack exists X. A$, c:[$exists$R])
 quad quad
 #cf($Gamma, A tack B quad X "free in" Gamma$, $Gamma, exists X. A tack B$, c:[$exists$L]) \

 
 #cf($Gamma, A tack B$, $Gamma tack A -> B$, c:[$->$R])
 quad quad
 #cf($Gamma tack A quad Gamma', B tack C$, $Gamma, Gamma', A -> B tack C$, c:[$->$L]) \
$

$
 #[*Derived Rules*] \

 #cf($Gamma, A tack bot$, $Gamma tack not A$, c:[$not$R])
 quad quad
 #cf($Gamma tack A$, $Gamma, not A tack bot$, c:[$not$L])
$

== Proof Normalisation of LK and LJ Calculus

#meta[$beta$ and $eta$ reduction, and cut-free proofs]

== Computational Content

The computational interpretation of a sequent $Gamma tack Delta$ is a set of _producers_ $Gamma$ and a set of _consumers_ $Delta$. Since $Gamma$ is conjunctive and $Delta$ is disjunctive, a program of type $Gamma tack Delta$ can be interpreted as a set of resources $Gamma$ that fulfills some subset of obligations $Delta$.


=== Computational Content of LJ Calculus

*Note*: This entire section is just my intuition, it could be wrong in subtle ways

Since LJ calculus contain exactly one formula on the right, the unique _consumer_ can be thought of as the 'goal' of the computation (or return value). Further, the producers can be interpreted as typed holes.

Since the consumer/goal is unique, we can build the proof-term (program) by annotating the goal. The 'initialising' of the holes can be done via a `let` statement. I'll expound on this interpretation to establish a better connection between LJ and lambda calculus. Later, System L for LK calculus will be introduced as an extension of this idea.

Concretely, the computational interpretation is as follows:

#let llet = "let"
#let iin = "in"
#let ccase = "case"
#let oof = "of"
#let vvoid = "void"
#let iinr = "inr"
#let iinl = "inl"
#let rr = it => text(fill: rgb("#ff1122"), it)

#block(breakable: false, width: 100%)[
$
  #[*Syntax*]
$
#v(-.7em)
$
  A, B in "Types" &:= &&top | bot | A times B | A + B | A -> B | forall X. A | exists X. A \
  N, M, P in "Terms" &:= &&x | () | llet x = N iin M | (N, M) | pi_1 N | pi_2 N | iinr N | iinl N \
  &&&| ccase N oof {iinr x => M | iinl y => P} | lambda x. N | N M | Lambda A. N \
  &&&| N A | A @ M | ccase N oof {A @ x => N}
$
]

$
 #[*Core Rules*] \ 
 #cf($$, $x:A tack rr(x): A$, c:"Ax")
 quad quad
 #cf($Gamma tack rr(t):A quad Gamma', x:A tack rr(t'):B$, $Gamma, Gamma' tack rr(llet x = t iin t'): B$, c:"Cut")
$

$
 #[*Structural Rules*] \ 
 #cf($Gamma tack rr(t): B$, $Gamma, x: A tack rr(t): B$, c:"WL")
 quad quad
 #cf($Gamma, x:A, x':A tack rr(t): B$, $Gamma, x:A tack rr(t[x' := x]): B$, c:"CL")
 quad quad
 #cf($Gamma tack rr(t):A$, $sigma(Gamma) tack rr(t):A$, c:"Exch")
$

$
 #[*Logical Rules*] \
 #cf($$, $Gamma tack rr(()) :top$, c:[$top$R])
 quad quad
 #[no $top$L rule]
 quad quad
 #[no $bot$R rule]
 quad quad
 #cf($$, $Gamma, x: bot tack rr("absurd"(x)):A$, c:[$bot$L]) \

 #cf($Gamma tack rr(t):A quad Gamma tack rr(t'):B$, $Gamma tack rr((t, t')): A and B$, c:[$and$R]) \
 #cf($Gamma, x:A tack rr(t):C$, $Gamma, p: A and B tack rr(llet x = pi_1 p iin t):C$, c:[$and$L1])
 quad quad
 #cf($Gamma, y:B tack rr(t):C$, $Gamma, p:A and B tack rr(llet y = pi_2 p iin t):C$, c:[$and$L2]) \

 #cf($Gamma tack rr(t):A$, $Gamma tack rr(iinl t):A or B$, c:[$or$R1])
 quad quad
 #cf($Gamma tack rr(t):B$, $Gamma tack rr(iinr t):A or B$, c:[$or$R2])
 \
 #cf($Gamma, x:A tack rr(t):C quad Gamma, y:B tack rr(t'):C$, $Gamma, s:A or B tack rr(ccase s oof {iinr x => t | iinl y => t'}):C$, c:[$or$L]) \
 
 #cf($Gamma, x:A tack rr(t):B$, $Gamma tack rr(lambda x.t): A -> B$, c:[$->$R])
 quad quad
 #cf($Gamma tack rr(t):A quad Gamma', x:B tack rr(t'):C$, $Gamma, Gamma', f:A -> B tack rr(llet x = f t iin t'):C$, c:[$->$L]) \

 #cf($Gamma tack rr(t):A quad X "free in" Gamma$, $Gamma tack rr(Lambda X. t): forall X.A$, c:[$forall$R])
 quad quad
 #cf($Gamma, x:A[X := B] tack rr(t):C$, $Gamma, e:forall X. A tack rr(llet x = e B iin t):C$, c:[$forall$L]) \
 
 #cf($Gamma tack rr(t):A[X := B]$, $Gamma tack rr(B @ t): exists X. A$, c:[$exists$R])
 quad quad
 #cf($Gamma, x:A tack rr(t):B quad X "free in" Gamma$, $Gamma, e: exists X. A tack rr(ccase e oof {B @ x => t}):B$, c:[$exists$L]) \
$

$
 #[*Derived Rules*] \

 #cf($Gamma, x:A tack rr(t): bot$, $Gamma tack rr(lambda x. t):not A$, c:[$not$R])
 quad quad
 #cf($Gamma tack rr(t):A$, $Gamma, f:not A tack rr(f t): bot$, c:[$not$L])
$

#block(breakable: false, width: 100%)[
$
  #[*$beta$-Reduction*]
$
#v(-.7em)
$
  beta_(times 1)&: llet p = (t, t') iin llet x = pi_1 p iin t'' &&arrow.squiggly llet x = t iin t'' \
  beta_(times 2)&: llet p = (t, t') iin llet y = pi_2 p iin t'' &&arrow.squiggly llet y = t' iin t'' \
  beta_(+ 1)&: llet s = iinr t iin ccase s oof {iinr x => t' | iinl y => t''} &&arrow.squiggly llet x = t iin t' \
  beta_(+ 2)&: llet s = iinl t iin ccase s oof {iinr x => t' | iinl y => t''} &&arrow.squiggly llet y = t iin t'' \
  beta_(->)&: llet f = lambda x.t iin llet y = f t' iin t'' &&arrow.squiggly llet y = t[x := t'] iin t'' \
  beta_(forall)&: llet e = Lambda X.t iin llet x = e B iin t' &&arrow.squiggly llet x = t[X := B] iin t' \
  beta_(exists)&: llet e=B@t iin ccase e oof {B @ x => t'} &&arrow.squiggly llet x = t iin t'
$
]

Left-intro rules instantiate existing holes by destructing fresh holes while the right-intro rules construct terms. This is exactly the usual intro-elim rules in lambda calculus (or Gentzen's NJ calculus). Hence, the LJ calculus can be seen as a type system for (polymorphic) lambda calculus.

In particular, each elimination rule can be derived by pairing a left-intro rule with a cut and eliminating the superfluous `let` statements:

#block()[
  #set align(bottom)
  #stack(
    dir: ltr,
    cf(
      stack(
        dir: rtl,
        cf(cf($$, $x:A tack rr(x):A$, c:"Ax"), $p: A and B tack rr(llet x = pi_1 p iin x):C$, c:[$and$L1]),
        $quad$,
        $overbrace(Gamma tack rr(p): A and B, pi)$
      ),
      $Gamma tack rr(llet p = p iin llet x = pi_1 p iin x): C$,
      c:"Cut"
    ),
    block(height: 2em, inset: 1em)[
      #set align(horizon)
      $==>$
    ],
    cf($overbrace(Gamma tack rr(p): A times B, pi)$, $Gamma tack rr(pi_1 p): A$, c:[$and$-elim1])
  )
]

More concretely, the NJ calculus can be described as follows:

TODO

NJ and LJ have equivalent proving power. I.e., a proof of NJ can be translated into LJ and vice-versa.

The difference between LJ calculus and NJ calculus is that LJ is explicit about the typed holes while NJ keeps the holes implicit. More concretely, using the substitution-based Krivine-style machine, NJ calculus has the following CBN operational semantics, which can be translated into an LJ proof-term, making the evaluation context explicit (only $->$ rules are shown):

$
  cut(v v', E) & arrow.squiggly cut(v, E[square v']) &&==> &ii(v v') &arrow.squiggly llet f = ii(v) iin f v' \
  cut(lambda x. v, E[square v']) & arrow.squiggly cut(v[x := v'], E) && ==> &llet f = ii(lambda x.v) iin f v'  &arrow.squiggly ii(v[x := v'])
$

The first rule splits the term $v v'$ into a term and a context. The second rule is equivalent to $beta_(->)$ written above.

In particular, we could transform an NJ proof term by applying the translation above. The process is KINDA like a translation of NJ into LJ and _then_ evaluating the LJ term via CBN semantics. Just that the two steps are interweaved. I don't know what I'm talking about.

This seems similar to the vibe of @10.1145-3022670.2951931 where perhaps LJ can be seen as a more explicit 'intermediate language'.

=== Enforcing CBV evaluation strategy via CPS

== coLJ Calculus Formulation of co-Intuitionistic Logic

=== Enforcing CBN evaluation strategy via co-CPS

=== Computational Content of coLJ Calculus

== Wadler's Duality

= Gentzen's LJ and Closed Cartesian Categories

We'll focus on the propositional fragment of the LJ calculus.

#meta[TODO: Expound on LJ without negation, BCC semantics, and then the problem of adding negation to motivate Pointed LJ]

For non-trivial computational semantics, we'll be using a slightly modified definition of negation from the LJ calculus. In particular, we'll define negation $not_r A := A -> r$ where $r$ is a distinguished type that's generally not equal to $bot$. The modified calculus, which we denote as pointed-LJ calculus, is concretely as follows:

#definition([Pointed-LJ])[
$
 #[*Formulas*] \ 
 A, B ::= p | r | bot | top | A or B | A and B | A -> B
$
$
 #[*Core Rules*] \ 
 #cf($$, $A tack A$, c:"Ax")
 quad quad
 #cf($Gamma tack A quad Gamma', A tack B$, $Gamma, Gamma' tack B$, c:"Cut")
$

$
 #[*Structural Rules*] \ 
 #cf($Gamma tack B$, $Gamma, A tack B$, c:"WL")
 quad quad
 #cf($Gamma, A, A tack B$, $Gamma, A tack B$, c:"CL")
 quad quad
 #cf($Gamma tack A$, $sigma(Gamma) tack A$, c:"Exch")
$

$
 #[*Logical Rules*] \
 #cf($$, $Gamma tack top$, c:[$top$R])
 quad quad
 #[no $top$L rule]
 quad quad
 #[no $bot$R rule]
 quad quad
 #cf($$, $Gamma, bot tack A$, c:[$bot$L]) \

 #cf($Gamma tack A quad Gamma tack B$, $Gamma tack A and B$, c:[$and$R])
 quad quad
 #cf($Gamma, A tack C$, $Gamma, A and B tack C$, c:[$and$L1])
 quad quad
 #cf($Gamma, B tack C$, $Gamma, A and B tack C$, c:[$and$L2]) \

 #cf($Gamma tack A$, $Gamma tack A or B$, c:[$or$R1])
 quad   
 #cf($Gamma tack B$, $Gamma tack A or B$, c:[$or$R2])
 quad quad
 #cf($Gamma, A tack C quad Gamma, B tack C$, $Gamma, A or B tack C$, c:[$or$L]) \

 
 #cf($Gamma, A tack B$, $Gamma tack A -> B$, c:[$->$R])
 quad quad
 #cf($Gamma tack A quad Gamma', B tack C$, $Gamma, Gamma', A -> B tack C$, c:[$->$L]) \
$

$
  #[*Derived Rules*] \
  #cf($Gamma, A tack r$, $Gamma tack not_r A$, c:[$not_r$R])
  quad quad
  #cf($Gamma tack A$, $Gamma, not_r A tack r$, c:[$not_r$L])
$ 
]


Where $p$ is a ground-type and $r$ is the distinguished object representing a result type. Pointed-LJ can be seen as an extension of propositional LJ with a distinguished type $r$ (hence the name 'pointed-LJ', a reference to pointed-sets). LJ can be recovered from a pointed-LJ by setting $r = bot$. Hence, as will be later expounded, the usual soundness proof for LJ wrt a BCC is directly applicable for the soundness proof for LJ wrt a _pointed BCC_ (A BCC $cal(C)$ with a distinguished object $R in "obj"(cal(C))$).

Since an LJ sequent can be embedded directly into pointed-LJ ($not_bot A$ embeds as $A -> bot$ and not $A -> r := not_r A$), we've not lost any proving power by moving to pointed-LJ. However, since taking negation to be $not_r$ instead of $not_bot$ is intended to preserve non-degenerate computational semantics, a natural question is to ask if every LJ sequent admits a non-degenerate computational semantics as a pointed-LJ sequent. This question is intentionally left vague as the author does not have a good idea of what she's writing about, but there's a decently precise way to describe the negative result.

// LJ proofs enjoy the subformula property. I.e., every proof of a sequent $Gamma tack A$ has a cut-free normal form $pi$ by $beta slash eta$-reduction, and every formula occuring in $pi$ is a subformula of one of the formulas in $Gamma union {A}$. Hence, if $Gamma tack A$ requires the $bot$L rule in its proof, $bot$ 

// #lemma()[
//   Define $(-)^dagger$ transforming an LJ sequent into a pointed-LJ sequent such that:
//   - It fixes $top$ and $bot$
//   - It translates LJ negation by $(not A)^dagger := not_r A^dagger$.
//   Then, $(-)^dagger$ preserves derivability iff $r tack.l tack bot$.
// ]

// #proof()[
//   The direction assuming $r tack.l tack bot$ is trivial. Conversely, lets assume $forall s$ provable in LJ, $s^dagger$ provable in pointed-LJ. Consider the following LJ sequent $s := [not top tack bot]$. This is provable in LJ:
 
//  #cf(
//   stack(dir:ltr,
//     cf($$, $tack top$, c:[$top$R]),
//     $quad$,
//     cf($$,$bot tack bot$, c:[Ax])
//   ),
//   $not top tack bot$,
//   c:[$->$L]
//  )

//  Then, $s^dagger = [top -> r tack bot]$ for every $B$. Since $top -> r tack.l tack r$, if $T(s)$ is provable in pointed-LJ, so is $r tack bot$. Since $bot tack r$ by $bot$L, we conclude $r tack.l tack bot$.
// ]

#lemma()[
  Define $(-)^dagger$ transforming an LJ sequent into a pointed-LJ sequent such that it replaces all instances of $bot$ with $r$. Then, $(-)^dagger$ preserves derivability iff forall LJ formulas $A$, $r tack A^dagger$ is derivable.
]

#proof()[
  Assume $forall A, r tack A^dagger$ is derivable. Given a derivable LJ sequent $s$ with proof $pi$, we can show that $s^dagger$ is derivable if for all sequents $t in pi$, $t^dagger$ is provable in pointed-LJ. The only rule that's changed by $(-)^dagger$ is the $bot L$ rule. I.e.,
  $
    (#cf($$, $Gamma, bot tack A$, c:[$bot$L]))^dagger = #cf($$, $Gamma^dagger, r tack A^dagger$, c:[$bot$L])
  $
  The RHS is derivable by assumption that $forall A, r tack A^dagger$ is derivable.
  
  Conversely, lets assume $forall s$ provable in LJ, $s^dagger$ provable in pointed-LJ. Consider the provable LJ sequent $s := [ bot tack A]$ via explosion ($bot$L rule). Then $s^dagger = [r tack A^dagger]$ is derivable.
]

#note()[
  This is insufficient to conclude that $r tack.l tack bot$ since any cut-free proof of $r tack bot$ satisfies the subformula property, and going through every possible structural and introduction rules, none of the rules can produce the sequent $r tack bot$.
]

By the above lemma, the condition $forall A, r tack A^dagger$ is too strict for an atomic $r$ for non-trivial computational semantics. In particular, we encounter the same problem as before with regards to CPS translation, since $r$ behaves like $bot$ for formulas in the image of $(-)^dagger$.

#meta[TODO: Expound on the exact problem lmao]

Hence, we reject the assumption $forall A, r tack A^dagger$. As a consequence, for an LJ proof $pi$, $pi^dagger$ is a valid proof in pointed-LJ iff $pi$ does not use $bot L$ rule. One way to think of this is that, if our LJ program contains the $"absurd"$ construct, it has degenerate semantics in pointed-LJ, which is totally expected.

In order to highlight this distinction, we'll change the notation of pointed-LJ slightly by denoting $r$ as $bot_r$,  $bot$ as $0$ and $top$ as $1$ to highlight that $bot$ no longer plays the role of `false` but rather, the unit of $and$:

#definition([Pointed-LJ])[
$
 #[*Formulas*] \ 
 A, B ::= p | bot_r | 0 | 1 | A or B | A and B | A -> B
$
$
 #[*Core Rules*] \ 
 #cf($$, $A tack A$, c:"Ax")
 quad quad
 #cf($Gamma tack A quad Gamma', A tack B$, $Gamma, Gamma' tack B$, c:"Cut")
$

$
 #[*Structural Rules*] \ 
 #cf($Gamma tack B$, $Gamma, A tack B$, c:"WL")
 quad quad
 #cf($Gamma, A, A tack B$, $Gamma, A tack B$, c:"CL")
 quad quad
 #cf($Gamma tack A$, $sigma(Gamma) tack A$, c:"Exch")
$

$
 #[*Logical Rules*] \
 #cf($$, $Gamma tack 1$, c:[$1$R])
 quad quad
 #[no $1$L rule]
 quad quad
 #[no $0$R rule]
 quad quad
 #cf($$, $Gamma, 0 tack A$, c:[$0$L]) \

 #cf($Gamma tack A quad Gamma tack B$, $Gamma tack A and B$, c:[$and$R])
 quad quad
 #cf($Gamma, A tack C$, $Gamma, A and B tack C$, c:[$and$L1])
 quad quad
 #cf($Gamma, B tack C$, $Gamma, A and B tack C$, c:[$and$L2]) \

 #cf($Gamma tack A$, $Gamma tack A or B$, c:[$or$R1])
 quad   
 #cf($Gamma tack B$, $Gamma tack A or B$, c:[$or$R2])
 quad quad
 #cf($Gamma, A tack C quad Gamma, B tack C$, $Gamma, A or B tack C$, c:[$or$L]) \

 
 #cf($Gamma, A tack B$, $Gamma tack A -> B$, c:[$->$R])
 quad quad
 #cf($Gamma tack A quad Gamma', B tack C$, $Gamma, Gamma', A -> B tack C$, c:[$->$L]) \
$

$
  #[*Derived Rules*] \
  #cf($Gamma, A tack bot_r$, $Gamma tack not_r A$, c:[$not_r$R])
  quad quad
  #cf($Gamma tack A$, $Gamma, not_r A tack bot_r$, c:[$not_r$L])
$ 
]


#meta[TODO: Bridge gap to denotational semantics]

#definition([Bicartesian Closed Category])[
  A bicartesian closed category (BCC) is a category $cal(C)$ possessing the following adjoints:
  $
    sum_(i=1)^n (-_i) tack.l Delta_n tack.l product_(i=1)^n (-_i) " "forall n in ZZ_(>=0) quad quad (-) times A tack.l (-)^A " "forall A in "obj"(cal(C))
  $
  Where $Delta_n: cal(C) -> cal(C)^n$ is the diagonal functor $A |-> (A,...,A)_"Cat"$, where $(...)_"Cat"$ is the pairing in $"Cat"$ and $Pi_i$ the corresponding projections.

  The usual canonical maps typical in presentations of BCCs can be constructed from the above datum as follows:
  $
    (f, g) &: A -> X times Y &&:= (f times g) compose eta_(times, A) &&" for" f: A -> X, g: A -> Y \
    pi_1 &: X times Y -> X &&:= Pi_i compose epsilon_(times, X times Y) \
    pi_2 &: X times Y -> Y &&:= Pi_2 compose epsilon_(times, X times Y) \
    
    [f, g] &: X+Y -> A &&:= epsilon_(plus, A) compose (f + g) && " for" f: X -> A, g: Y -> A \
    inl &: X -> X+Y &&:= Pi_1 compose eta_(plus, X+Y) \
    inr &: Y -> X+Y &&:= Pi_2 compose eta_(plus, X+Y) \

    lambda(f) &: X -> Y^A &&:= f^A compose eta_(->, A, X)  && " for" f: X times A -> Y \
    ev_(A,X) &: X^A times A -> X &&:= epsilon_(->, A, X) \
  $

  Where
  - $eta_times$ and $epsilon_times$ are the unit and counit of the adjunction $Delta_2 tack.l (-) times (-)$.
  - $eta_+$ and $epsilon_+$ are the unit and counit of the adjunction $(-) + (-) tack.l Delta_2$.
  - $eta_(->, A)$ and $epsilon_(->, A)$ are the unit and counit of the adjunction $(-) times A tack.l (-)^A$.

  To define the units $0$ and $1$, denote functors $F, G$ such that $F tack.l Delta_0 tack.l G$. Since $"dom"(G) = "dom"(F)$ is the terminal category $bb(1)$ with unique object $star in "obj" bb(1)$, we can define $1 := G(star)$ and $0 := F(star)$.

  // 1 = C(A, 1)
  
  // C(X+Y, A) = (C x C)((X,Y), (A,A))
  // Unit: id_(X+Y) -> (X->X+Y, Y->X+Y)
  // Counit: id_(A,A) -> (A+A -> A)

  // (C x C) ((A,A), (X,Y)) = C(A, X x Y)
  // Unit: id_(A,A) -> C(A, A x A)
  // Counit: id_(X x Y) -> (X x Y -> X, X x Y -> Y)

  // Hom(X x A, Y) = Hom(X, Y^A)
  // Unit: (X x A => X x A) -> (X => (X x A)^A)
  // Counit: (X^A => X^A) -> (X^A x A -> X)
]


A pointed-LJ formula $A$ embeds into into a pointed BCC $(cal(C), R)$ as follows:
- Ground type $A$ assigned an object $ii(A) in cal(C)$.
- $ii(bot) = 0, ii(top) = 1, ii(r) = R$
- $ii(A and B) := ii(A) times ii(B)$
- $ii(A or B) := ii(A) or ii(B)$
- $ii(A -> B) := ii(B)^ii(A)$

Where $R in "obj"(cal(C))$ is a distinguished object representing the 'result type'. For non-trivial computational semantics of the embedding, $R$ is taken to be non-trivial ($R != 0$). If $R = 0$, as used in the embedding $ii(not A) := ii(A -> bot)$, the continuation monad (discussed later) collapses into a monad mapping all morphisms $A -> B$ into $ofc: A -> 0^0^B tilde.equiv 1$.

A pointed-LJ sequent $Gamma tack A$ embeds into $(cal(C), R)$ as a morphism $ii(Gamma tack A) : product_(B in Gamma) ii(B) -> ii(A)$ as follows:
#[
#set text(size:.9em)
$
  ii(A tack A) &:= id_A = lambda x. x \
  ii(Gamma\, Gamma' tack B) &:= ii(Gamma) times ii(Gamma') xarrow(ii(Gamma tack A) times id) ii(A) times ii(Gamma') xarrow(ii(Gamma'\, A tack B)) ii(B) = lambda gamma' gamma. h'(h(gamma), gamma') tilde lambda gamma. h'(h gamma) \
  ii(Gamma\, A tack B) &:= ii(Gamma) times ii(A) -->^pi ii(Gamma) xarrow(ii(Gamma tack B)) ii(B) = lambda gamma a. h gamma ~ lambda a. h \
  ii(Gamma\, A tack B) &:= ii(Gamma) times ii(A) xarrow(Delta) ii(Gamma) times ii(A) times ii(A) xarrow(ii(Gamma\, A\, A tack B)) ii(B) = lambda gamma a. h(a, a, gamma) ~ lambda a. h a a \
  ii(sigma(Gamma) tack A) &:= ii(sigma(Gamma)) xarrow(sigma) ii(Gamma) xarrow(ii(Gamma tack A)) ii(A) = lambda sigma(gamma). h(gamma) \
  ii(Gamma tack top) &:= ii(Gamma) xarrow(ofc) 1 = lambda gamma. () \
  ii(Gamma\, bot tack A) &:= ii(Gamma) times 0 xarrow(pi) 0 xarrow(ofc) A = lambda gamma b. "absurd"(b)  \
  ii(Gamma tack A and B) &:= ii(Gamma) xarrow((ii(Gamma tack A), ii(Gamma tack B))) ii(A) times ii(B) = lambda gamma. inner(h gamma, h' gamma') \
  ii(Gamma\, A and B tack C) &:= ii(Gamma) times (ii(A) times ii(B)) xarrow(pi) ii(Gamma) times ii(A) xarrow(ii(Gamma\,A tack C)) ii(C) = lambda gamma a b.  h(a, gamma) tilde lambda a b. h a \
  ii(Gamma\, A and B tack C) &:= ii(Gamma) times (ii(A) times ii(B)) xarrow(pi) ii(Gamma) times ii(B) xarrow(ii(Gamma\,B tack C)) ii(C) = lambda gamma a b.  h(b, gamma) tilde lambda a b. h b\
  ii(Gamma tack A or B) &:= ii(Gamma) xarrow(ii(Gamma tack A)) ii(A) xarrow(inl) ii(A) + ii(B) = lambda gamma. inl(h(gamma)) \
  ii(Gamma tack A or B) &:= ii(Gamma) xarrow(ii(Gamma tack B)) ii(B) xarrow(inr) ii(A) + ii(B) = lambda gamma. inr(h(gamma)) \
  ii(Gamma\, A or B tack C) &:= ii(Gamma) times (ii(A) + ii(B)) tilde.equiv (ii(Gamma) times ii(A) ) + (ii(Gamma) times ii(B)) xarrow([ii(Gamma\, A tack C), ii(Gamma\, B tack C)]) ii(C) \
  &= lambda gamma s. ccase s oof {inl(a) => h a gamma | inr(b) => h' b gamma} \
  ii(Gamma tack A -> B) &:= ii(Gamma) xarrow(lambda(ii(Gamma \, A tack B))) ii(B)^ii(A) = lambda gamma. lambda a. h(a, gamma) tilde h \
  ii(Gamma\, Gamma'\, A -> B tack C) &:= ii(Gamma) times ii(Gamma') times ii(B)^ii(A) xarrow(ii(Gamma tack A) times id) ii(Gamma') times ii(A) times ii(B)^ii(A) xarrow(ev) ii(Gamma') times ii(B') xarrow(ii(Gamma'\, B tack C)) ii(C) \
  &= lambda gamma' gamma f. h'(f (h gamma), gamma') tilde lambda gamma f. h' (f (h gamma))

$
]

Where
- $Delta: A -> A times A$ is the diagonal endofunctor,
- $sigma$ is the braiding isomorphism for $times$,
- $ofc$ denotes the unique morphism $A -> 1$ or $0 -> A$,


#note()[
  Via cut elimination over proofs in LJ, the cut formula is actually not needed in the definition of the embedding. The above embedding being well-defined over proof reduction is the concern of the soundness theorem that'll be discussed below.
]

#meta[TODO: Talk about internal language, canonicity, (LJ, NJ), and present the lambda calculi thingy]

#meta[TODO: We can't talk about embedding a sequent. This is ill-defined for a pointed-LJ. We can only talk about embedding a _proof_ and it being well-defined over $beta$/$eta$ reduction.]

= Gentzen's LK and the Continuation Monad


#meta[TODO: Pointed LJ avoids the collapse of CBV semantics of $and$]

= CLL and LPC Models

== Comonad $ofc$

KabazAAM

== Monad $why$

= The Chu Construction

#bibliography("shared/everything.bib")