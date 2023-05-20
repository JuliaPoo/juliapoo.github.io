---
layout: project-writeup
author: JuliaPoo

display-title: "Python Tier 2 Interpreter Experiment (PyLBBV)"
display-image: "/assets/projects/2023-04-01-pylbbv-cpython-tier-2/line6_color.png"
tags:
    - cpython
    - programming-language
    - 

excerpt: "Experimenting with type propagation and Lazy Basic Block Versioning in CPython"
---

## Metadata

This project is a joint work with [@Kenjin](https://discuss.python.org/u/kj0) who's experience with CPython is crucial to this project.

We attempted to remove the overhead associated with dynamic typing in CPython by experimenting with our variant of [Lazy Basic Block Versioning](https://arxiv.org/abs/1411.0352), and experimented with a (to our knowledge) novel type propagator for CPython bytecode.

I mostly worked on the type propagator and Kenjin worked on the codegen (this part required a lot of CPython knowledge).

## Links

* [Technical Report](/assets/projects/2023-04-01-pylbbv-cpython-tier-2/CPython_Tier_2_LBBV_Report_For_Repo.pdf)
* [discuss.python.org](https://discuss.python.org/t/preliminary-experiments-for-tier-2-interpreter-ideas-in-cpython/25874)
* [Repository](https://github.com/Fidget-Spinner/cpython/tree/tier2_interpreter_no_separate_eval_no_tracer_contiguous_bbs)

## Report

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

<iframe id="pdf-viewer" src="https://docs.google.com/viewer?url=https://juliapoo.github.io//assets/projects/2023-04-01-pylbbv-cpython-tier-2/CPython_Tier_2_LBBV_Report_For_Repo.pdf&embedded=true" height="800" style="width:100%;height:800;filter:sepia(0.3)" frameborder="0" scrolling="no"></iframe>
</center>