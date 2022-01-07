---
layout: generic # art
author: JuliaPoo
category: Origami

display-title: Lotus Tessellation
preview-url: /assets/art/2021-09-18-lotus-tessellation/lotus-tessellation-preview.jpg
---

# Placeholder formatting

## Gallery

[TODO: Fold the actual tessellation sometime]
<center>
<img src="/assets/art/2021-09-18-lotus-tessellation/lotus-tessellation-preview.jpg" alt="Lotus tessellation prototype">
</center>


## Links

* [Folding Instructions PDF](https://juliapoo.github.io/assets/art/2021-09-18-lotus-tessellation/final.pdf)

<details>
<summary><strong>See Instructions</strong></summary>

<center>
<!--<iframe style="filter: invert(1) hue-rotate(100deg)" src="/assets/art/2021-09-18-lotus-tessellation/final.pdf#view=fit" width="100%" height="1960"></iframe>-->

<script>
// Bypass a bug from google returning 204
function reloadIFrame() {
var iframe = document.getElementById("pdf-viewer");
  console.log(iframe.contentDocument.URL); //work control
  if (!iframe.contentDocument) return;
  if(iframe.contentDocument.URL == "about:blank"){
    iframe.src =  iframe.src;
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

<iframe id="pdf-viewer" src="http://docs.google.com/viewer?url=https://juliapoo.github.io/assets/art/2021-09-18-lotus-tessellation/final.pdf&embedded=true" height="800" style="width:100%;height:800;filter:sepia(0.3)" frameborder="0" scrolling="no"></iframe>
</center>

</details>
