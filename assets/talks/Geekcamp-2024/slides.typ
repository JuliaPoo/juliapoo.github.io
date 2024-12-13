#import "@preview/polylux:0.3.1": *
#import "theme.typ": *
#import "@preview/fletcher:0.5.2" as fletcher: diagram, node, edge

#enable-handout-mode(false)

#show: metropolis-theme.with(
  footer: none
)

#set text(font: "Fira Sans", weight: "light", size: 23pt)
#set strong(delta: 100)
#set par(justify: true, spacing:.7em)
#show raw.where(block: false): it => text(fill: rgb("#f50273"))[#it]
#show link: it => text(weight: "regular", fill: rgb("#4499ff"))[#it]

#let nonumeq = math.equation.with(block: true, numbering: none)
#let dm(x) = box[#nonumeq[#x]]
#let dfrac(x,y) = math.frac(dm(x),dm(y))
#let srm = h(-1pt)

#let emph(body) = {alert()[*#body*]}
#let meta(body) = text(fill: rgb("#f50273"))[*#body*]
#let meta2(body) = text(fill: rgb("#2233ff"))[*#body*]

#title-slide(
  author: [Jules Poon],
  title: "The Correspondence Between Proofs and Programs",
  subtitle: "And how Mathematics informs Programming Language Design",
  date: "2024 Dec"
)

#slide(title: [whoami])[
  - Jules
  - Undergrad
  - Interested in Programming Languages and Math
    - Currently interested in Algebra
    - Worked briefly on CPython's JIT #pause
  - *Will do SWE for money* { #emph()[available for summer intern 2025 hmu] }
    - #link("https://juliapoo.github.io/")[juliapoo.github.io] { #emph()[full of cool stuff] }

  #pause
  #linebreak()
  Special thanks to #meta[\@Patricia] { #link("https://sg.linkedin.com/in/patmloi")[linkedin.com/in/patmloi] } for her invaluable feedback, without which this would have been a completely different talk.
]

#let title = [Introduction]

// PAT [done]: Talk about brief history (before PL or computers), difficulties I had in crafting this presentation. Trying to bridge Computer Science and Mathematics.

#slide(title: title)[
  === Curry Howard Correspondence
  $
    "Mathematical Proofs" <==> "Programs"
  $

  - First noticed by Haskell Curry in 1934, #meta[before computers, or programming as we know today] #pause
  - { #emph[personal opinion] } One of the biggest bridge connecting #meta[Mathematics] and #meta[Computer Science] #pause
  - Majority of the writing on this is targeted at Mathematicians, not Computer People.
]

#slide(title: title)[
  === Curry Howard Correspondence
  $
    "Mathematical Proofs" <==> "Programs"
  $
  #pause

  === Uses of the Correspondence
  Powers #emph[Interactive Theorem Provers]
  - *For Mathematicians*: Verifies a mathematical argument is sound
  - *For Computer People*: #emph[Formal Verification] of software/hardware #pause
    - #meta[Proving] an implementation is #emph[correct] for all inputs
    - Used in safety critical software (like airbags to ensure compliance)
    - Intel uses it to verify microcode
]

#slide(title: title)[
  === Interactive Theorem Provers

  Questions:
  - What is a #emph[Mathematical Proof]? #pause
  - What does it mean for reasoning to be #emph[sound]? #pause
  - How to #highlight(fill: rgb("#448855"))[#text(weight:"bold", fill:white)[program a computer to verify a proof's correctness]]? #pause

  === Example of a Proposition
  How can we prove the following?
  $
    forall A,B "boolean": (A and B) -> (B and A)
  $
  #align(center)[
    ($A$ and $B$) is equivalent to ($B$ and $A$)
  ]
]

#slide(title: title)[
  === To Prove
  $
    forall A,B "boolean": (A and B) <-> (B and A)
  $
  #pause
  // PAT [done]: TO make the bruteforce more explicit
  === Attempt 1: Bruteforce (the usual way we test software)
  $A, B$ can either be `True` or `False`. We can try all $4$ possibilities and show that the expression is always `True`.
  #pause

  #align(center)[
    #set text(size: 1em)
    #table(
      columns: (4em, 4em, 4em, 4em, 2em),
      inset: .2em,
      align: center,
      table.header($A$, $B$, $A and B$, $B and A$),
      `False`, `False`, `False`, `False`, emoji.checkmark.heavy,
      `False`, `True`, `False`, `False`, emoji.checkmark.heavy,
      `True`, `False`, `False`, `False`, emoji.checkmark.heavy,
      `True`, `True`, `True`, `True`, emoji.checkmark.heavy,
    )
  ]
]

#slide(title: title)[
  #meta[Problem]: What if the domain is infinite?
  $
    forall x,y in ZZ_(>=0): x + y >= x
  $
  #align(center)[
    For any $x,y$ integers $>=0$, $x+y >= x$
  ]
  #linebreak()
  #pause

  - We can no longer try every possible value #pause
  - We #meta[need to program the computer to reason].
]

#slide(title: title)[
  === To Prove
  $
    forall x,y in ZZ_(>=0): x + y >= x
  $
  // PAT [done]: Make it clearer why we need to generalise to this approach
  #pause
  === Attempt 2: Define the constructs to the computer and compose theorems
  The computer needs to know 
  - What $ZZ_(>=0)$ is.
    - Understand all of its properties and statements you can say about it
  - What $forall$, $+$, $>=$ means
  - #emph[How to combine reasoning steps together in a sound way]

  #pause
  #meta[Very difficult problem!] Gives rise to the idea of a #emph[Proof System].
]

#slide(title: title)[
  === Proof System
  A framework which one can #emph[prove statements].
  
  #linebreak()
  #pause

  Consists of:
  + #meta[Formal Language]: A language to write formulas in.
  + #meta[Rules of Inference]: How to reason to prove statements.
  + #meta[Axioms]: Assumptions, statements assumed true.
]


#slide(title: title)[
  === Example of a (non-trivial but easy) Mathematical Proof
  // PAT [done]:
  // 1. Split proof up into more understandable steps
  // 2. Highlight terms intuitive to humans, and show what a computer needs to do to understand the concept
  // 
  // PAT2: Emphasise the proof by ontradiction
  #meta[Proposition]: $sqrt(2)$ is irrational (cannot be a fraction) #pause

  #meta[Proof]:
  #set text(.9em)
  + Suppose $sqrt(2) = a/b$ in simplified form.
  + Then $2 b^2 = a^2$.
  + Since $2 b^2$ is even, $a^2$ is even, so $a$ is even.
  + Since $a^2$ is even, $2 b^2$ is divisible by $4$, so $b^2$ is even, and $b$ has to be even. 
  + Hence both $a$ and $b$ are even.
  + But $a/b$ is supposed to be simplified form, a contradiction!
  + Hence our assumption that $sqrt(2) = a/b$ is not true!
]

#slide(title:title)[
  === Reflection Questions:
  - Can you figure out what you #meta[need to define] to a computer to understand this proof?
  - Can you figure how to encode ways one can #meta[compose reasoning]?
]

#slide(title:title)[
  // PAT2: Mention that this applies to EVERYTHING infinite rabbit holes
  === Taster in what a Computer needs: { #emph[a rabbithole everywhere] }
  #set text(size: .9em)
  - What is a natural number?
  #text(size: .87em)[
    $
      &"Peano's 6 Axioms:" \
      &" "1." "forall x, 0 != S(x) \
      &" "2." "forall x,y (S(x) = S(y) => x = y) \
      &" "3." "forall x (x + 0 = x) \
      &" "...
    $
  ]
  - What is an integer?
  $
    ZZ tilde.equiv NN^2 slash tilde, "where" (a,b) tilde (c,d) "iff" a + d = b + c
  $
  - What is a fraction?
  $
    QQ tilde.equiv ZZ^2 slash tilde, "where" (a,b) tilde (c,d) "iff" a d = b c
  $
]

#slide(title: title)[
  // PAT2: Weird jump
  #align(center)[
    === Work not in Proof Systems but in Programs
  ]
  #pause
  #grid(
    columns: (50%, 50%),
    inset: (x: .7em, y:0em),
    stroke: (x, y) => if x == 0 {
      (right: (
        paint: luma(180),
        thickness: 1.5pt,
        dash: "solid"
      ))
    },
    [
        #align(right)[
          === Proof System Side
          Formula \
          Proof \
          Formula #meta[has a Proof] \
          #meta[Simplification] of Proof \
        ]
    ],
    [
        #align(left)[
          === Programming Side
          Type \
          Term { #emph[valid program] } \
          Type #meta[has a Term] \
          #meta[Running] of Term
        ]
    ]
  )
  #pause
  #v(.5em)
  #align(left)[
    If we want to verify the #meta[Proof] of a #meta[Formula], \
    + Convert #meta[Formula] to a #meta[Type] in the programming language.
    + Convert #meta[Proof] to a #meta[Term] in the programming language.
    + Computer verifies the #meta[Term] has the correct #meta[Type] in the language.
  ]
]

#focus-slide()[
  For every #emph[Proof System], \
  we can define a #emph[Programming Language] where \
  finding a #emph[Proof] \
  $<==>$ \
  finding a #emph[Term] with the correct #emph[Type] 
]

#slide(title: "Table of contents")[
  === Demonstrate the correspondence between #meta[Proofs] and #meta[Programs]:

  We'll be constructing the #emph[most basic] Programming Language and Proof System, and demonstrate a clear linkage between the two.
  #pause
  #linebreak()
  #linebreak()

  #metropolis-outline
]

#let title = [Untyped Lambda Calculus { #emph()[programming language] }]

#new-section-slide(title)

#slide(title: title)[
  === Lambda Expressions #text(weight:"light")[{ #emph()[in Python] }]
  #grid(
      columns: (50%, 50%),
      [
          ```python
          f = lambda x: x
          ```
      ],
      [
          ```python
          def f(x): return x
          ```
      ]
    )
     === Lambda Expressions #text(weight:"light")[{ #emph()[in Untyped Lambda Calculus] }]

    $lambda x f. f(x)$ is a #emph()[Term] corresponding to #box()[```python
    lambda x: lambda f: f(x)```] #pause

    $
      lambda underbrace(x f, "arguments"). underbrace(f(x), "operation")
    $
    #pause
    - Arguments are #emph()[Curried]: $lambda x f. #meta[op] tilde.equiv lambda x. (lambda f. #meta[op])$
      - Python: #box()[```python
    lambda x,f: <op>
    ```] $->$ #box()[```python
    lambda x: lambda f: <op>
    ```]
      - Every "function" has $1$ argument and $1$ return value
]

#slide(title: title)[
  === Two Concepts of Untyped Lambda Calculus
  $
    underbrace(lambda x f, "abstraction").underbrace(f(x), "application")
  $
  1. #emph()[Abstraction] aka function definition { #meta()[Introduction] of abstraction }
  2. #emph()[Application] aka function calling { #meta()[Elimination] of abstraction }
  #pause
  #linebreak()
  #emph()[Language Features should come in pairs] of #meta()[Introduction] and #meta()[Elimination].
  - #meta()[Introduction]: Definition
  - #meta()[Elimination]: Consequences of Definition

  Gives a language some nice properties. // in the Proof side, it allows a normalised proof of a statement to not include any "concepts" that the statement does not use, preventing "roundabout" proofs.
  // PAT [done]: Make it very clear what is being introduced and eliminated
  // PAT [done]: Explain briefly why we need to come in pairs.

]

#slide(title: title)[
  === Eliminating Brackets
  - Brackets `()` are used to indicate #emph()[Order of Operations]
  - Impose rules to avoid writing extra brackets for clarity
  #pause
  === Rules of Order of Operation
  - #emph()[Application] is #meta[left-associative]
    - $M N P$ is  $(M (N))(P)$ #pause
  - #emph()[Application] has #meta()[higher precedence] than #emph()[Abstraction] { like $times$ vs $+$ }
    - $lambda x. M N$ is $lambda x. (M N)$ and *not* $(lambda x. M) N$ #pause
  $
    lambda x. x z (lambda y.x y) <==> lambda x. (x(z) (lambda y. x(y))) 
  $
  // PAT [done]: Talk abt x and + having different precedence
]

#slide(title: title)[
  // PAT: Simplify example
  // PAT: Colour code execution steps
  // === Executing an example program
  //+ $(lambda x y z. x z (y z))(lambda x y. x)(lambda x y. x)$ #pause
  //+ $(lambda y z. (lambda x y. x) z (y z))(lambda x y. x)$ #pause
  //+ $(lambda y z. (lambda y. z) (y z))(lambda x y. x)$ #pause
  //+ $(lambda y z. z)(lambda x y. x)$ #pause
  //+ $lambda z. z$ { stop when we can't perform #emph[Application] }
  
  //#pause

  // #linebreak()
  // When we can't reduce a term anymore, we call the term #emph[normal].
  // - We write $M ->> N$ if we can reduce a term $M$ to a term $N$.
  //   - $(lambda x y z. x z (y z))(lambda x y. x)(lambda x. x) ->> lambda z.z$
  
  === Executing an example program
    // PAT2: Explain with the python code, map to the original notation.
    #alternatives[
      #set align(top)
      + $(lambda x y. y)(lambda x.x)(lambda x.x)$
    ][
      #set align(top)
      + $(lambda #block(height: .8em, width: .1em)[#set align(center)
      #meta2[$underbrace(x, "variable")$]] y. y)#meta[$underbrace((lambda x.x), "argument")$] (lambda x.x)$ \

      #linebreak()
      - We replace #meta2[variable $x$] in the body of $(lambda x y.y)$ with the #meta[argument $(lambda x.x)$].
        - Since the body of $(lambda x y.y)$ is $lambda y.y$, which does not contain #meta2[$x$]
        - We simply return the body $lambda y.y$.
        - $(lambda x y. y)(lambda x.x) -> (lambda y.y)$
      - In Python: #box[
        ```python
        (lambda x: lambda y: y)(lambda x: x) -> (lambda y: y)
        ```
      ]
    ][
      #set align(top)
      + $(lambda x y. y)(lambda x.x)(lambda x.x)$
      + $(lambda y.y)(lambda x.x)$
    ][
      #set align(top)
      + $(lambda x y. y)(lambda x.x)(lambda x.x)$
      + $(lambda #block(height: .8em, width: .1em)[#set align(center)
      #meta2[$underbrace(y, "variable")$]] .#meta2[$y$])#meta[$underbrace((lambda x.x), "argument")$]$

      #linebreak()
      - We replace #meta2[variable $y$] in the body of $(lambda y.y)$ with the #meta[argument $(lambda x.x)$].
        - Since the body of $(lambda y.y)$ is $y$,
        - We replace the body $y -> lambda x.x$ and return it.
        - $(lambda y. y)(lambda x.x) -> (lambda x.x)$
      - In Python: #box[
        ```python
        (lambda y: y)(lambda x: x) -> (lambda x: x)
        ```
      ]
    ][
      #set align(top)
      + $(lambda x y. y)(lambda x.x)(lambda x.x)$
      + $(lambda y.y)(lambda x.x)$
      + $lambda x. x$
    ][
      #set align(top)
      + $(lambda x y. y)(lambda x.x)(lambda x.x)$
      + $(lambda y.y)(lambda x.x)$
      + $lambda x. x$ { stop when we can't perform #emph[Application] }

      #linebreak()
      When we can't reduce a term anymore, we call the term #emph[normal].
      - We write $M ->> N$ if we can reduce a term $M$ to a term $N$.
      - $(lambda x y. y)(lambda x.x)(lambda x.x) ->> lambda x.x$
    ]
]

#slide(title: title)[
  === Executing an example program
  + $(lambda x. x x)(lambda x. x x)$ #pause
  + $(lambda x. x x)(lambda x. x x)$
  + ...
  #pause
  
  #linebreak()
  Program above #meta[does not converge]. It has no #emph[normal form].
  - Later, we'll see that #emph[Types] avoid such #emph[Terms] that do not converge.
  // PAT: Tell the audience why this property matters
]

#let title = [Simply Typed Lambda Calculus { #emph()[programming language] }]

#new-section-slide(title)

#slide(title: title)[

  === Simply Typed Lambda Calculus
  Lambda Calculus but every #emph[Term] is #emph[Typed]
    - Term $t$ has a #emph[Type] $T$, written as $t: T$. { like Python's Type Annotations }
    - Later, we'll map every #emph[Type] into a #emph[Formula].

  #pause
  === Types
  - #emph[Atomic Types] $A, B, ...$. Basic building blocks for #emph[Types].
  - #emph[Composite Types]. #emph[Types] built-upon other #emph[Types].
    - { we'll see them later } $A -> B, A times B$ 
  // PAT: Forgo this notation entirely
  // PAT: Introduce the notation better
  // === Typing Rules
  // #set math.mat(delim: none)
  // #let nonumeq = math.equation.with(block: true, numbering: none)
  // #let dm(x) = box[#nonumeq[#x]]
  // #let dfrac(x,y) = math.frac(dm(x),dm(y))
  // $
  //   dfrac(mat([x: A]^x; dots.v; M\:B), lambda x.M: A->B) lambda I^x &"    "& (L: A->B "  " M: A)/(L M: B) lambda E
  // $
  // $
  //   (overbrace(y\: B, #meta[if $y:B$]))/(underbrace(lambda x^A. y: A -> B, #meta[then $lambda x^A.y: A->B$])) underbrace(lambda I, #meta[name of \ rule]) &"  "& (f: A->B "  " x: A)/(f x: B) lambda E 
  // $
  // - $lambda I$ is rule for #emph[Abstraction] ($I$ for #meta[Introduction])
  //   - $x^A$ states $x$ variable is of type $A$.
  // - $lambda E$ is rule for #emph[Application] ($E$ for #meta[Elimination])
]

#slide(title: title)[
  === Typing Rules

  #meta[Rule $lambda I$]: If $y: #meta2[$B$]$, then $lambda x^A. y: #meta2[$A -> B$]$
    - $x^A$ states $x$ variable is of type $A$.
    - $lambda I$ is rule for #emph[Abstraction] ($I$ for #meta[Introduction])
  
  #alternatives[
    #set align(top)
    #linebreak()
    #meta[Rule $lambda E$]: If $f: #meta2[$A->B$]$ and $x: #meta2[$A$]$, then $f x: #meta2[B]$
      - $lambda E$ is rule for #emph[Application] ($E$ for #meta[Elimination])
  ][
    #set align(top)
    === Notation
    // PAT2: State on slides that this isnt a fraction
    #set text(size: .96em)
    $
      #meta[Premises]/#meta[Conclusion] #meta2[Name-of-rule] "  " ==> "  " ([x:A]^x #box(width: 0em, height: 0em, inset: (y:-.6em))[#align(left)[#text(size:.8em)[#meta[#box(width: 15em)[if we can assume that $x:A$,]]]]] \ dots.v \ y: B #box(width: 0em, height: 0em, inset: (y:-.9em))[#align(left)[#text(size:.8em)[#meta[#box(width: 10em)[we'll get $y:B$,]]]]])/(underbrace(lambda x^A. y: A -> B, #meta[then $lambda x^A.y: A->B$])) underbrace(lambda I^x, #meta2[name of \ rule])
    $
  ]
]

#slide(title: title)[
  === Typing Rules
  $
    ([x:A]^x \ dots.v \ y: B)/(lambda x^A. y: A -> B) lambda I^x "      " (f: A->B "  " x: A)/(f x: B) lambda E
  $
]

#slide(title: title)[
  #set line(stroke: .5pt + luma(160), length: 95%)
  === Examples
  $
    lambda x^A f^(A -> B). f x " " : " " A ->((A->B)->B)
  $
  #alternatives[
    #set align(top)
    We take $->$ to be #meta[right-associative]:
    - $A -> ((A->B) -> B)$ is written as $A -> (A-> B) -> B$
    - Functional programmers might recognise this notation for typing functions
  ][
    #set align(top)
    We can form a #emph[Justification Tree] for the #emph[Type] by composing #emph[typing rules].
  ][
    #set align(top)
    #line()
    $
      [f: A->B]^#meta[f] "  " [x: A]^#meta2[x]
    $
    #line()
    - We first try to type the body $f x$
    - We know we can assume $f: A->B$ and $x: A$.
    - We'll track these assumptions as $#meta[f]$ and $#meta2[x]$.
  ][
    #set align(top)
    #line()
    $
      dfrac([f: A->B]^#meta[f] "  " [x: A]^#meta2[x], f x: B) lambda E
    $
    #line()
    - Next we can apply rule $lambda E$ to type $f x: B$
  ][
    #set align(top)
    #line()
    $
      dfrac(dfrac([f: A->B]^#meta[f] "  " [x: A]^#meta2[x] , f x: B)lambda E, lambda f^(A->B).f x: (A->B) -> B)lambda I^#meta[f]
    $
    #line()
    - Next we can apply rule $lambda I^#meta[f]$ to #emph[consume] the assumption $[f: A->B]^#meta[f]$.
  ][
    #set align(top)
    #line()
    $
      dfrac(dfrac(dfrac([f: A->B]^#meta[f] "  " [x: A]^#meta2[x] , f x: B)lambda E, lambda f^(A->B).f x: (A->B) -> B)lambda I^#meta[f],lambda x^A f^(A->B). f x: A->(A->B)->B) lambda I^#meta2[x]
    $
    #line()
    - Next we can apply rule $lambda I^#meta2[x]$ to #emph[consume] the assumption $[x: A]^#meta2[x]$.
  ][
    #set align(top)
    #line()
    $
      dfrac(dfrac(dfrac([f: A->B]^#meta[f] "  " [x: A]^#meta2[x] , f x: B)lambda E, lambda f^(A->B).f x: (A->B) -> B)lambda I^#meta[f],lambda x^A f^(A->B). f x: A->(A->B)->B) lambda I^#meta2[x]
    $
    #line()
    - $[f: A->B]^#meta[f]$ #emph[must accompany] a $lambda I^#meta[f]$ rule.
    - $[x: A]^#meta2[x]$ #emph[must accompany] a $lambda I^#meta2[x]$ rule.
  ]
]

#slide(title: title)[
  // PAT: Motivate the introduction of Pairs
  It'll be nice if our langauge can return more than $1$ value. #pause

  === Adding #emph[Pairs] in the Language

  - $angle.l x, y angle.r$ #meta[introduces] a #emph[Pair]
  - $pi_1$ and $pi_2$ #meta[eliminates] a #emph[Pair]:
    - $pi_1(angle.l x, y angle.r) = x$, $pi_2(angle.l x, y angle.r) = y$

  #pause
  === Typing Rules for #emph[Pairs]: #meta[Product Types]
  $
    (X:A "  " Y:B)/(angle.l X, Y angle.r: underbrace(#meta[$A times B$], #meta[product type])) pi I "  " (L:A times B)/(pi_1 L: A) pi_1 E "  " (L:A times B)/(pi_2 L: B) pi_2 E
  $
]

#slide(title: title)[
  === Example with Product Types
  // PAT: Come back to this
  Function that reverses the order of a #emph[Pair]:
  $
    lambda x^(A times B). angle.l pi_2 x, pi_1 x angle.r " " : " " A times B -> B times A
  $
  #pause
  #linebreak()
  $
    dfrac(dfrac(dfrac([x\: A times B]^#meta[x], pi_2 x: B) pi_2 E "  " dfrac([x\: A times B]^#meta[x], pi_1 x: A) pi_1 E, angle.l pi_2 x\, pi_1 x angle.r: B times A) pi I, lambda x^(A times B). angle.l pi_2 x\, pi_1 x angle.r " " : " " A times B -> B times A) lambda I^#meta[x]
  $
]

#slide(title: title)[
  === Typing terms
  Given an #meta[untyped term], we can assign #emph[Types] to make the program valid in the #emph[Simply Typed Lambda Calculus]
  - E.g., Function is #emph[applied] with the correct #emph[types]. #pause
  - $(lambda x^(#meta[A]).x)underbrace((lambda x^A .x), #meta[Type $A->A$])$ is not correctly typed. (`TypeError`) #pause
  // PAT2 [done]: Label lambda x.x as type A->A.
  // PAT2 [done]: Add the correct example
  - $(lambda x^(A -> A).x)(lambda x^A.x)$ is correctly typed.
  #pause

  #linebreak()
  Our example program
  $
  // (lambda x y z. x y (y z))(lambda x y. x)(lambda x y. x)
  (lambda x y. y)(lambda x.x)(lambda x.x)$
  can be typed as such:
  $
  // (lambda x^(A->(A->A)->A) y^(A->A->A) z^A. x z (y z)) (lambda x^A y^(A->A). x) (lambda x^A y^A.x)
  (lambda x^(A->A) y^(A->A). y)(lambda x^A.x)(lambda x^A.x)
  $
]


#slide(title: title)[
  === Are all Untyped Lambda terms #emph[Typeable] (in our language)?
  #highlight(fill:red, text(fill:white)[*No*]). $(lambda x.x x) (lambda x. x x)$ is not typeable.
  - #meta[Intuition]: It runs forever, we need a #emph[recursive type] to represent such terms. This feature does not exist in our very simple language.
  #linebreak()
  
  #pause
  Types #meta[restricts] what are considered programs.
  - Intended. Gives our language some nice properties.
]

#slide(title: title)[
  === Simply Typed Lambda Calculus is #emph[Strongly Normalising]
  - #meta[Informal]: All programs finish evaluating in finite steps. #pause

  === Simply Typed Lambda Calculus has the #emph[Church-Rosser property]
  - #meta[Informal]: No matter how we evaluate, we'll get the same normal form.
  - If $N ->> M_1$ and $N ->> M_2$, then there exists an $X$ with $M_1 ->> X$ and $M_2 ->> X$.

  #align(center)[
    #diagram(cell-size: 0em, spacing: (1em, .5em), //node-inset: 0.1em,
    
      node((0,0), $N$),
      node((-1,1), $M_1$),
      node((1,1), $M_2$),
      node((0,2), $"exists" X$),
  
      edge((0,0), (-1,1), "->>"),
      edge((0,0), (1,1), "->>"),
      edge((-1,1), (0,2), "->>"),
      edge((1,1), (0,2), "->>"),
    )
  ]
]

#focus-slide[
  All programs in \ #emph[Simply Typed Lambda Calculus] \ evaluate in finite steps to a \ #emph[unique normal form]
]

#slide(title: title)[
  === Determine if two programs are equivalent:
  + Evaluate both programs (finishes in finite steps)
  + Compare results (equal up to variable renaming)
  #pause
  === Example:
  // PAT [done]: Simple example
  $
  //&(lambda x^(A->(A->A)->A) y^(A->A->A) z^A. x z (y z)) (lambda x^A y^(A->A). x) (lambda x^A y^A.x) &->> lambda z^A.z \
  //&(lambda x^(A->A->A) y^A.y)(lambda x^A y^A. x) &->> lambda y^A.y
  &(lambda x^(A->A) y^(A->A). y)(lambda x^A.x)(lambda x^A.x) &->> lambda x^A.x \
  &(lambda x^(A->A). x)(lambda z^A. z) &->> lambda z^A.z
  $
  Since $lambda x^A.x$ and $lambda z^A.z$ are equal up to variable renaming, #emph[both programs are equivalent].
]

#let title = [Proof System ($and$ and $->$) { #emph()[proof system] }]

#new-section-slide(title)

#let title = [Proof System ($and$ and $->$) { #emph()[proof system] }]

#slide(title: title)[
  === Language for Formulas
  - Consists of #emph[atomic (hypothesis)] represented as letters $A,B,C,...$
    - #emph[atomics] can either be `True` or `False`
  - #emph[Logical connectors] $underbrace(and, "and")$ and $underbrace(->, "implies")$, and $()$ to indicate order of operations
  
  #linebreak()

  E.g., $A -> B -> (B and A)$ is a Formula:
  - If we assume $A$, and we assume $B$, then $(B and A)$.
]

#slide(title: title)[
  === Rules of Inference
  // PAT2: Go through properly the inference rules

  For $and$ connective:
  $
    dfrac(A "  " B, A and B) and srm I "  " dfrac(A and B, A) and_1 srm E "  " dfrac(A and B, B) and_2 srm E
  $
  #pause
  #linebreak()

  // PAT2 [done]: Annotate the hypothesis with words

  #let sidebox(body) = box(width: 0em, height: 0em, inset: (y:-.6em))[#align(right)[#text(size:.7em)[#meta[#box(width: 30em)[#body]]]]]

  For $->$ connective:
  $
    dfrac(#sidebox[if by assuming $A$ #h(1em) \ (track hypothesis with #meta2[$x$]) #h(1em)] [A]^#meta2[x] \ dots.v \  #sidebox[we can conclude $B$ #h(2em)] B, #sidebox[then, $A->B$ via rule $I^#meta2[x]$] A -> B) -> srm I^#meta2[x] "  " dfrac(A->B "  " A, B) -> srm E
  $
]

#slide(title: title)[
  === Example: Prove that $(A and B) -> (B and A)$
  #linebreak()
  #alternatives[
    
  ][
    #set align(top)
    $
      dfrac([A and B]^#meta2[x], B) and_2 srm E "  " dfrac([A and B]^#meta2[x], A) and_1 srm E
    $
    #linebreak()
    - Lets assume $(A and B)$ is `true` (we'll track this hypothesis with #meta2[$x$]).
    - From inference rules $and_2 srm E$ and $and_1 srm E$, we'll obtain $B$ and $A$ is `true`.
  ][
    #set align(top)
    $
    dfrac(
      dfrac([A and B]^#meta2[x], B) and_2 srm E "  " dfrac([A and B]^#meta2[x], A) and_1 srm E,
      B and A
    ) and srm I
    $
    #linebreak()
    - From $and srm I$, we can conclude $B and A$ is `true`
  ][
    #set align(top)
    $
    dfrac(
      dfrac(
        dfrac([A and B]^#meta2[x], B) and_2 srm E "  " dfrac([A and B]^#meta2[x], A) and_1 srm E,
        B and A
      ) and srm I,
      #meta[$(A and B) -> (B and A)$]
    ) -> srm I^#meta2[x]
    $
    #linebreak()
    - Finally, with rule, $-> srm I^#meta2[x]$ we #emph[consume] the hypothesis $[A and B]^#meta2[x]$.
  ]
]

#let title = [Curry Howard Correspondence { #emph()[proof $<->$ programs] }]

#new-section-slide(title)


#slide(title: title)[
  // PAT2 [done]: Add colours to show correspondence clearer
  #align(center)[
    = Correspondence
  ]

  #grid(
    columns: (50%, 50%),
    inset: (x: .6em, y:0em),
    stroke: (x, y) => if x == 0 {
      (right: (
        paint: luma(180),
        thickness: 1.5pt,
        dash: "solid"
      ))
    },
    [
      #align(center)[
        === Proof that $(A and B) -> (B and A)$
        #linebreak()
        #set text(size: .8em)
        $
        dfrac(
          dfrac(
            dfrac([A and B]^#meta[x], B) and_2 srm E "  " dfrac([A and B]^#meta[x], A) and_1 srm E,
            B and A
          ) and srm I,
          (A and B) -> (B and A)
        ) -> srm I^#meta[x]
        $
      ]
    ],
    [
      #align(center)[
        === Type of $lambda x^(A times B). angle.l pi_2 x, pi_1 x angle.r$
        #linebreak()
        #set text(size: .8em)
        $
          dfrac(dfrac(dfrac([x\: A times B]^#meta[x], pi_2 x: B) pi_2 E "  " dfrac([x\: A times B]^#meta[x], pi_1 x: A) pi_1 E, angle.l pi_2 x\, pi_1 x angle.r: B times A) pi I, lambda x^(A times B). angle.l pi_2 x\, pi_1 x angle.r " " : " " A times B -> B times A) lambda I^#meta[x]
        $
      ]
    ]
  )
]


#slide(title: title)[
  #let hgl(body) = text(fill: rgb("#ff6333"))[#body]
  #align(center)[
    = Correspondence
  ]

  #grid(
    columns: (50%, 50%),
    inset: (x: .6em, y:0em),
    stroke: (x, y) => if x == 0 {
      (right: (
        paint: luma(180),
        thickness: 1.5pt,
        dash: "solid"
      ))
    },
    [
      #align(center)[
        === Proof that $(A and B) -> (B and A)$
        #linebreak()
        #set text(size: .8em)
        $
        dfrac(
          dfrac(
            dfrac([#hgl[$A and B$]]^#meta[x], #hgl[$B$]) and_2 srm E "  " dfrac([#hgl[$A and B$]]^#meta[x], #hgl[$A$]) and_1 srm E,
            #hgl[$B and A$]
          ) and srm I,
          #hgl[$(A and B) -> (B and A)$]
        ) -> srm I^#meta[x]
        $
      ]
    ],
    [
      #align(center)[
        === Type of $lambda x^(A times B). angle.l pi_2 x, pi_1 x angle.r$
        #linebreak()
        #set text(size: .8em)
        $
          dfrac(
            dfrac(
              dfrac(
                [x\: #hgl[$A times B$]]^#meta[x],
                pi_2 x: #hgl[$B$]
              ) pi_2 E 
              "  " 
              dfrac(
                [x\: #hgl[$A times B$]]^#meta[x], 
                pi_1 x: #hgl[$A$]
              ) pi_1 E, 
              angle.l pi_2 x\, pi_1 x angle.r: #hgl[$B times A$]
            ) pi I, 
            lambda x^(A times B). angle.l pi_2 x\, pi_1 x angle.r " " : " " #hgl[$A times B -> B times A$]
          ) lambda I^#meta[x]
        $
      ]
    ]
  )
]

#slide(title: title)[
  #align(center)[
    = Correspondence
  ]

  #let hgl(body) = text(fill: rgb("#ff6333"))[#body]
  #grid(
    columns: (50%, 50%),
    inset: (x: .6em, y:0em),
    stroke: (x, y) => if x == 0 {
      (right: (
        paint: luma(180),
        thickness: 1.5pt,
        dash: "solid"
      ))
    },
    [
      #align(center)[
        === Proof that $(A and B) -> (B and A)$
        #linebreak()
        #set text(size: .8em)
        $
        dfrac(
          dfrac(
            dfrac([A and B]^#meta[x], B) #hgl[$and_2 srm E$] "  " dfrac([A and B]^#meta[x], A) #hgl[$and_1 srm E$],
            B and A
          ) #hgl[$and srm I$],
          (A and B) -> (B and A)
        ) -> #hgl[$srm I^#meta[x]$]
        $
      ]
    ],
    [
      #align(center)[
        === Type of $lambda x^(A times B). angle.l pi_2 x, pi_1 x angle.r$
        #linebreak()
        #set text(size: .8em)
        $
          dfrac(dfrac(dfrac([x\: A times B]^#meta[x], pi_2 x: B) #hgl[$pi_2 E$] "  " dfrac([x\: A times B]^#meta[x], pi_1 x: A) #hgl[$pi_1 E$], angle.l pi_2 x\, pi_1 x angle.r: B times A) #hgl[$pi I$], lambda x^(A times B). angle.l pi_2 x\, pi_1 x angle.r " " : " " A times B -> B times A) #hgl[$lambda I^#meta[x]$]
        $
      ]
    ]
  )
]

#slide(title: title)[

  #align(center)[
    = Correspondence
  ]

  #grid(
    columns: (50%, 50%),
    inset: (x: .6em, y:0em),
    stroke: (x, y) => if x == 0 {
      (right: (
        paint: luma(180),
        thickness: 1.5pt,
        dash: "solid"
      ))
    },
    [
      #align(right)[
        === Formulae
        Atomic hypothesis $A,B,...$ \
        Logical connector $->$ \
        Logical connector $and$ \

      ]
    ],
    [
      #align(left)[
        === Types
        Atomic types $A,B,...$ \
        Function type $->$ \
        Product Type $times$ \
      ]
    ]
  )
]

#slide(title: title)[

  #align(center)[
    = Correspondence
  ]

  #grid(
    columns: (50%, 50%),
    inset: (x: .6em, y:0em),
    stroke: (x, y) => if x == 0 {
      (right: (
        paint: luma(180),
        thickness: 1.5pt,
        dash: "solid"
      ))
    },
    [
      #align(right)[
        === Proofs

        #set align(center)
        #alternatives[
          #set align(top + center)
          Inference for $-> srm I^x$ and $-> srm E$
          
          #linebreak()
          #text(size: .85em)[
            $
              dfrac([A]^x \ dots.v \  B, A -> B) -> srm I^x "  " dfrac(A->B "  " A, B) -> srm E
            $
          ]
        ][
          #set align(top + center)
          Inference for $and srm I$ and $and_1 srm E$ and $and_2 srm E$
          
          #linebreak()
          #text(size: .85em)[
            $
              dfrac(A "  " B, A and B) and srm I \ dfrac(A and B, A) and_1 srm E "  " dfrac(A and B, B) and_2 srm E
            $
          ]
        ]
      ]
    ],
    [
      #align(left)[
        === Programs
       
        #alternatives[
          #set align(top + center)
          Types for $lambda I^x$ and $lambda E$
          
          #linebreak()
          #text(size: .85em)[
            $
              ([x:A]^x \ dots.v \ y: B)/(lambda x^A. y: A -> B) lambda I^x "  " (f: A->B "  " x: A)/(f x: B) lambda E
            $
          ]
        ][
          #set align(top + center)
          Types for $and srm I$ and $and_1 srm E$ and $and_2 srm E$
          
          #linebreak()
          #text(size: .86em)[
            $
              (X:A "  " Y:B)/(angle.l X, Y angle.r: A times B) pi I \ (L:A times B)/(pi_1 L: A) pi_1 E "  " (L:A times B)/(pi_2 L: B) pi_2 E
            $
          ]
        ]
      ]
    ]
  )
]

#slide(title: title)[

  #align(center)[
    = Correspondence
  ]

  #grid(
    columns: (50%, 50%),
    inset: (x: .6em, y:0em),
    stroke: (x, y) => if x == 0 {
      (right: (
        paint: luma(180),
        thickness: 1.5pt,
        dash: "solid"
      ))
    },
    [
      #align(right)[
        === Proofs

        #emph[Normalising] (simplifying) of Proof

        \
        There's a finite algorithm that says if two proofs are equivalent.
      ]
    ],
    [
      #align(left)[
        === Programs

        #emph[Normalising] (running) of Program

        \
        #emph[Simply Typed Lambda Calculus] is #meta[Strongly Normalising] and has the #meta[Church Rossier Property].
        \
        So, there's a finite algorithm that can determine if two #emph[Terms] are equivalent.
      ]
    ]
  )
]

#slide(title: title)[

  #align(center)[
    = Correspondence
  ]

  #grid(
    columns: (50%, 50%),
    inset: (x: .6em, y:0em),
    stroke: (x, y) => if x == 0 {
      (right: (
        paint: luma(180),
        thickness: 1.5pt,
        dash: "solid"
      ))
    },
    [
      #align(right)[
        === Proofs

        #emph[Normalised proofs] of a formula only uses "concepts" present in the formula.
        
        E.g., Proof of $A->(A->B)->B$ does not need $and$.
      ]
    ],
    [
      #align(left)[
        === Programs

        Language features comes in pairs of #meta[Introduction] and #meta[Elimination]
      ]
    ]
  )
]



#slide(title: title)[
  === Proving that $A->(A->B)->B$ #pause

  + Convert #emph[formula] $A->(A->B)->B$ into the #emph[type] $A->(A->B)->B$ #pause
  + Find a #emph[term] (program) that has the #emph[type]: $lambda x^A f^(A->B). f x$ #pause
  + Convert the #emph[justification tree] for the #emph[type] of the #emph[term] into a #emph[proof].
  #linebreak()
  $
    dfrac(dfrac(dfrac([f: A->B]^#meta[f] "  " [x: A]^#meta2[x] , f x: B)lambda E, lambda f^(A->B).f x: (A->B) -> B)lambda I^#meta[f],lambda x^A f^(A->B). f x: A->(A->B)->B) lambda I^#meta2[x] ==> dfrac(dfrac(dfrac([A->B]^#meta[f] "  " [A]^#meta2[x], B)-> srm E, (A->B) -> B)-> srm I^#meta[f],A->(A->B)->B) -> srm I^#meta2[x]
  $
]

#slide(title: title)[
  === Simplifying a proof that $A->B->B and A$ #pause

  #meta[Roundabout proof]:
  + Assume $A$ and $B$, we have $A and B$ { #emph[by rule $and srm I$] }.
  + Since we've previously shown that $A and B -> B and A$, the result holds. #pause

  #linebreak()
  #meta[Proof corresponds to program]: $lambda x^A y^B. underbrace((lambda x^(A times B). angle.l pi_2 x, pi_1 x angle.r), #meta[proof that $A and B -> B and A$]) angle.l x, y angle.r$
  #pause

  #meta[Normalised program]: $lambda x^A y^B. angle.l y,x angle.r$ #pause

  #meta[Normalised proof]:  Assume $A$ and $B$, we have $B and A$ { #emph[by rule $and srm I$] }.
]


// #new-section-slide([Hilbert System ($->$) { #emph()[proof system] }])
// 
// #new-section-slide([SK Calculus { #emph()[programming language] }])
// 
// #new-section-slide([Proving with Axioms in SK-Calculus { #emph()[proofs $<->$ programs] }])

#let title = [What now?]

#new-section-slide(title)


#slide(title: title)[
  #set line(stroke: 1.5pt + luma(180), length: 20em)
  #grid(
    columns: (50%, 50%),
    inset: (x: .6em, y:0em),
    stroke: (x, y) => if x == 0 {
      (right: (
        paint: luma(180),
        thickness: 1.5pt,
        dash: "solid"
      ))
    },
    [
      #align(right)[
        === Proofs
        #set text(size: .73em)
        Logical connector $->$ (implication) \
        \
        #line()
        Logical connector $and$ (and) \
        #line()
        Logical connector $or$ (or) \
        #line()
        Quantifiers $forall$ (for all) and $exists$ (exists) \
        \
        \
        #line()
        Second-order intuitionistic predicate logic \
        \
        #line()
        Intuitionist $->$ Classical Logic
      ]
    ],
    [
      #align(left)[
        === Programs
        #set text(size: .73em)
        Function definition & application \
        { #emph[Haskell Curry, 1934] } \
        #line()
        Product Types { #emph[William Howard, 1969] } \
        #line()
        Sum Types/Enums { #emph[William Howard, 1969] } \
        #line()
        Dependent Types/Types depend on values
        - E.g., Array type paired with its length `int[5]` \
        { #emph[William Howard, 1969] } \
        #line()
        Polymorphism/Generic Programming \
        { #emph[Girard & Reynolds, 1972/1974] } \
        #line()
        Continuous Passing { #emph[Tim Griffin, 1990] }
      ]
    ]
  )
]

#focus-slide()[
  #emph[Programming Language Design] \
  is often seen as #emph[ad-hoc].
  \
  \
  #emph[Curry-Howard Correspondence] \
  gives us a #emph[solid theory] \ of certain language features
]


// PAT: Thank the audience for listening through this very difficult presentation.

#slide(title: [Thank you!])[
== Summary
  #metropolis-outline
]
