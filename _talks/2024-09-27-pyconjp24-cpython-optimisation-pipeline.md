---
layout: talks
author: Ken Jin & JuliaPoo

display-title: "PyCon JP 2024: An overview of the optimisation pipeline in CPython 3.13 and onwards"
tags:
    - cpython
    - jit

event: PyCon JP 2024
    
excerpt: |
    CPython 3.13 introduces a new experimental optimization pipeline that cumulates into a JIT. This talk gives an overview of the components of the optimization pipeline as of CPython 3.13 and plans for future versions of CPython.

    The talk will focus on the Trace Optimizer and briefly cover experiments the speaker is personally involved in before the final version currently in CPython 3.13 implemented by Ken Jin.
---

## Downloads 📄
- [PyCon JP 2024.pdf](/assets/talks/PyCon JP 2024.pdf)

## Slide Preview

<iframe src = "/assets/talks/PyCon JP 2024.pdf" width='100%' height='450' allowfullscreen webkitallowfullscreen id="meowmeow"></iframe>

<script>
let meowmeow = document.getElementById("meowmeow");
let kitty = () => {meowmeow.height = meowmeow.offsetWidth / (1.58)};
kitty();

window.onresize = kitty;
</script>