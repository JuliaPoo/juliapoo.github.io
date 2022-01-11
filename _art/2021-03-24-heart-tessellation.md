---
layout: art-writeup
author: JuliaPoo
category: Origami

display-title: Heart Tessellation
excerpt: |
    Heart Tessellation, designed by me. You can fold any number of these lotus on the same piece of paper without cuts or glue. Instructions are available.

preview-url: /assets/art/2021-03-24-heart-tessellation/1.jpg

gallery:

    - url: /assets/art/2021-03-24-heart-tessellation/1.jpg
      alt: A heart tessellation folded on a post-it.
      desc: |
        Very tiny heart tessellation. Designed and folded by me using a post-it.
        It's a pretty weird grid, 29x29, and its my first time folding a grid so small.

    - url: /assets/art/2021-03-24-heart-tessellation/instructions.svg
      alt: Instructions svg
      desc: Instructions svg

tags:
    - origami
    - tessellation
    - heart
    - original
---

## Meta

This is my first time diagramming and its so tedious

I think this might be one of the cleanest origami designs I made so far. The back side of the piece is super clean too.

## Links

* [Folding Instructions in PDF](/assets/art/2021-03-24-heart-tessellation/final.pdf)

### Instructions PDF

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

<iframe id="pdf-viewer" src="https://docs.google.com/viewer?url=https://juliapoo.github.io/assets/art/2021-03-24-heart-tessellation/final.pdf&embedded=true" height="800" style="width:100%;height:800;filter:sepia(0.3)" frameborder="0" scrolling="no"></iframe>
</center>

## Code

```python
# https://github.com/Kozea/CairoSVG/issues/200

import cairocffi
from cairosvg.parser import Tree
from cairosvg.surface import PDFSurface

class RecordingPDFSurface(PDFSurface):
    surface_class = cairocffi.RecordingSurface

    def _create_surface(self, width, height):
        cairo_surface = cairocffi.RecordingSurface(cairocffi.CONTENT_COLOR_ALPHA, (0, 0, width, height))
        return cairo_surface, width, height  

def convert_list(urls, write_to, dpi=72):
    surface = cairocffi.PDFSurface(write_to, 1, 1)
    context = cairocffi.Context(surface)
    for url in urls:
        image_surface = RecordingPDFSurface(Tree(url=url), None, dpi)
        surface.set_size(image_surface.width, image_surface.height)
        context.set_source_surface(image_surface.cairo, 0, 0)
        context.paint()
        surface.show_page()
    surface.finish()

convert_list(['full_diagram_inkscape.svg'], 'final.pdf')
```