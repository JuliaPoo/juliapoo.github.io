---
layout: talks
author: JuliaPoo

display-title: "Geekcamp 2024: The Correspondence Between Proofs and Programs"
tags:
    - curry-howard-correspondence
    - lambda-calculus
    - proof-systems

event: Geekcamp 2024
    
excerpt: |
    The Curry Howard Correspondence states a surprising link between two worlds: The Mathematical world of proofs and the world of programs. First noticed in the 1930s, it is the core insight that drives Interactive Theorem Provers that formally encode and verify complex mathematical arguments, and powers applications such as Formal Verification.

    But what does this correspondence mean?

    This talk aims to illustrate in detail one of the first examples discovered of such a correspondence, loosely based on observations Haskell Curry first noticed in the 1960s.

    We construct a toy mathematical universe and a simple programming language, and illustrate exactly how each theorem in the toy universe corresponds to a type in the programming language, where a program satisfying said type can be ran to produce a proof of the theorem.

    This talk is catered for programmers with some idea of what types are, but otherwise will be accessible for beginners as the content will be self contained.
---

## Downloads 📄
- [slides.pdf](/assets/talks/Geekcamp-2024/slides.pdf)
- [slides.typ](/assets/talks/Geekcamp-2024/slides.typ)
- [theme.typ](/assets/talks/Geekcamp-2024/theme.typ)

## Slide Preview

<iframe src = "/assets/talks/Geekcamp-2024/slides.pdf" width='100%' height='450' allowfullscreen webkitallowfullscreen id="meowmeow"></iframe>

<script>
let meowmeow = document.getElementById("meowmeow");
let kitty = () => {meowmeow.height = meowmeow.offsetWidth / (1.58)};
kitty();

window.onresize = kitty;
</script>