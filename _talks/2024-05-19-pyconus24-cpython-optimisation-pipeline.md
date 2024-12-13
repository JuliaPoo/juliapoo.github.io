---
layout: talks
author: Ken Jin & JuliaPoo

display-title: "PyCon US 2024: How two undergrads from the other side of the planet are speeding up your future code"
tags:
    - cpython
    - jit

event: PyCon US 2024
    
excerpt: |
    CPython 3.13 is planned to get cool new performance features. One of them is an experimental runtime bytecode optimizer, which will optimize bytecode on the fly using compiler optimizations. It aims to do fancy-sounding things like type propagation, guard elimination, constant promotion and more!

    What’s less known - this optimizer is currently being built by a university undergraduate 😲, with earlier iterations contributed by another undergrad. We’re also receiving course credit for it! One of us had no prior experience contributing to CPython.

    In this talk, we’ll split our time 60-40, with some time for the performance enthusiasts out there, and the remaining time on our experience contributing to CPython as an (in our opinion) underrepresented group, and how you can contribute to CPython as a university student as well.
---

## Downloads 📄
- [PyCon US 2024.pdf](/assets/talks/PyCon US 2024.pdf)

## Slide Preview

<iframe src = "/assets/talks/PyCon US 2024.pdf" width='100%' height='450' allowfullscreen webkitallowfullscreen id="meowmeow"></iframe>

<script>
let meowmeow = document.getElementById("meowmeow");
let kitty = () => {meowmeow.height = meowmeow.offsetWidth / (1.58)};
kitty();

window.onresize = kitty;
</script>