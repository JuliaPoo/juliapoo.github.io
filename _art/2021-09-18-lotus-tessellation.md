---
layout: art-writeup
author: JuliaPoo
category: Origami

display-title: Lotus Tessellation
excerpt: |
    Lotus Tessellation, designed by me. You can fold any number of these lotus on the same piece of paper without cuts or glue. Instructions are available.

preview-url: /assets/art/2021-09-18-lotus-tessellation/lotus-tessellation-preview.jpg

gallery:

    - url: /assets/art/2021-09-18-lotus-tessellation/lotus-tessellation-preview.jpg
      alt: A lotus tessellation folded in foolscape paper.
      desc: |
        Prototype lotus tessellation folded on notebook paper.
        Kinda like this design, might document it.
        Also the lotus itself eats up 10x10 amount of paper, and the lotus is only 2x2, meaning there's an average of 25 layers of paper stacked up on the lotus.

    - url: /assets/art/2021-09-18-lotus-tessellation/final-page1.svg
      alt: Page 1 of the folding instructions
      desc: Page 1 of the folding instructions

    - url: /assets/art/2021-09-18-lotus-tessellation/final-page2.svg
      alt: Page 2 of the folding instructions
      desc: Page 2 of the folding instructions

tags:
    - origami
    - tessellation
    - lotus
    - original
---

## Metadata

This was something I wanted to design for a while. I didn't use any origami design techniques to design this (I really wanna learn tho), this design mostly popped out through trial and error.

## Links

* [Folding Instructions in PDF](/assets/art/2021-09-18-lotus-tessellation/final.pdf)

### Instructions PDF

<center>
<!--<iframe style="filter: invert(1) hue-rotate(100deg)" src="/assets/art/2021-09-18-lotus-tessellation/final.pdf#view=fit" width="100%" height="1960"></iframe>-->

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

<iframe id="pdf-viewer" src="https://docs.google.com/viewer?url=https://juliapoo.github.io/assets/art/2021-09-18-lotus-tessellation/final.pdf&embedded=true" height="800" style="width:100%;height:800;filter:sepia(0.3)" frameborder="0" scrolling="no"></iframe>
</center>
