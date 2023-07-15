---
layout: project-writeup
author: JuliaPoo

display-title: "Python Tier 2 Interpreter Experiment (PyLBBV + Copy and patch JIT)"
display-image: "/assets/projects/2023-04-01-pylbbv-cpython-tier-2/line6_color.png"
tags:
    - cpython
    - programming-language
    - just-in-time-compilation
    - type-propagation
    - lazy-basic-block-versioning

excerpt: "Experimenting with type propagation, Lazy Basic Block Versioning and finally a JIT in CPython"
---

## First Half: Type Propagation and Lazy Basic Block Versioning

The first half of this project is a joint work with [@Kenjin](https://discuss.python.org/u/kj0).

We attempted to remove the overhead associated with dynamic typing in CPython by experimenting with our variant of [Lazy Basic Block Versioning](https://arxiv.org/abs/1411.0352), and experimented with a (to our knowledge) novel type propagator for CPython bytecode.

I mostly worked on the type propagator and Kenjin worked on the codegen (this part required a lot of CPython knowledge).

### Links

* [Technical Report](/assets/projects/2023-04-01-pylbbv-cpython-tier-2/CPython_Tier_2_LBBV_Report_For_Repo.pdf)
* [discuss.python.org](https://discuss.python.org/t/preliminary-experiments-for-tier-2-interpreter-ideas-in-cpython/25874)
* [Repository](https://github.com/Fidget-Spinner/cpython/tree/tier2_interpreter_no_separate_eval_no_tracer_contiguous_bbs)

### First Half Report

<center>
<script>
// Bypass a bug from google returning 204
function reloadIFrame() {
var iframe = document.getElementById("pdf-viewer");
    if (iframe.contentDocument == null) return;
    console.log(iframe.contentDocument.URL); //work control
    if(iframe.contentDocument.URL == "about:blank"){
        iframe.src = iframe.src;
    }
}
var timerId = setInterval("reloadIFrame();", 2000);

document.addEventListener("DOMContentLoaded", (e) => {
    console.log("dom loaded")
    document.getElementById("pdf-viewer").addEventListener("load", (e) => {
        clearInterval(timerId);
        console.log("pdf Loaded"); //work control
    });
});
</script>

<iframe id="pdf-viewer" src="https://docs.google.com/viewer?url=https://juliapoo.github.io//assets/projects/2023-04-01-pylbbv-cpython-tier-2/CPython_Tier_2_LBBV_Report_For_Repo.pdf&embedded=true" height="800" style="width:100%;height:800;" frameborder="0" scrolling="no"></iframe>
</center>

## Second Half: Refining PyLBBV and integrating a JIT

The second half of this project is a joint work with [@Kenjin](https://discuss.python.org/u/kj0) again. We mostly fixed a ton of issues with our previous implementation of PyLBBV, and then we incorporated [@BrandtButcher](https://github.com/brandtbucher/)'s awesome CPython bytecode stencil compiler, which basically precompiles CPython's bytecode into machine code. Brandt's code presents majority of the work in integrating the jit into PyLBBV.

Me and Kenjin wanted to get some academic credits for work we are gonna do anyways, so we applied for a Year 1 software engineering credit bearing blah blah, so annoyingly we had to comply with a bunch of annoying deliverables like posters, videos, pitches, and ughhhhhhhhhhh. Kenjin did most of that though, I mostly just made pretty diagrams.

Also fun fact we got dropped to one of the lower "achievement" levels because of a lack of new features.

### Links

* [Repository](https://github.com/pylbbv/pylbbv)