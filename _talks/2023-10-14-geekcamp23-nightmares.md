---
layout: talks
author: JuliaPoo

display-title: "Geekcamp 2023: Giving nightmares to reverse engineers"
tags:
    - artfuscator
    - elvm
    - c-compiler

event: Geekcamp 2023
    
excerpt: |
    How [Artfuscator](https://github.com/JuliaPoo/artfuscator), a project written in 24 hours while having a high fever with covid, works, and the motivations behind it.

    Disclaimer: This project looks like a monumental achievement in compiler technology and it is but most of the work wasnt by me: I built Artfuscator on ELVM.
---

## Downloads 📄
- [Geekcamp-2023.pdf](/assets/talks/Geekcamp-2023.pdf)

## Slide Preview

<iframe src = "/assets/talks/Geekcamp-2023.pdf" width='100%' height='450' allowfullscreen webkitallowfullscreen id="meowmeow"></iframe>

<script>
let meowmeow = document.getElementById("meowmeow");
let kitty = () => {meowmeow.height = meowmeow.offsetWidth / (1.58)};
kitty();

window.onresize = kitty;
</script>