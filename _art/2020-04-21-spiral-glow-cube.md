---
layout: art-writeup
author: JuliaPoo
category: Shaders

display-title: Spiral Glow Cube
excerpt: Custom raytracer and geometry. This uses Linearly Transformed Cosines for the lighting.

preview-url: /assets/art/2020-04-21-spiral-glow-cube/1.jpg

gallery:

    - url: /assets/art/2020-04-21-spiral-glow-cube/1-c.mp4
      alt: The shader animated
      desc: The shader animated
      type: video/mp4
      preview-url: /assets/art/2020-04-21-spiral-glow-cube/1-preview.jpg

    - url: /assets/art/2020-04-21-spiral-glow-cube/1.jpg
      alt: One frame of the shader
      desc: One frame of the shader

    - url: /assets/art/2020-04-21-spiral-glow-cube/2.jpg
      alt: One frame of the shader
      desc: One frame of the shader

    - url: /assets/art/2020-04-21-spiral-glow-cube/3-c.mp4
      alt: Showing off my VSCode workflow
      desc: Showing off my VSCode workflow
      type: video/mp4
      preview-url: /assets/art/2020-04-21-spiral-glow-cube/3-preview.jpg
        
tags:
    - shader
    - raytracing
    - ltc
---

## Meta

This was done with reference to the paper Real-Time Polygonal-Light Shading with Linearly Transformed Cosines, which is a pretty fast way to handle lighting accurately. Also with referene to the amazing [demo](https://blog.selfshadow.com/sandbox/ltc.html) the authors provided.

_**2022 note**_: Twas overkill? Probably.

## Shader

<!--
<center>
<iframe class="shader-container" frameborder="0" src="https://www.shadertoy.com/embed/tsjyDG?gui=true&t=10&paused=false&muted=false" allowfullscreen></iframe>
</center>
-->

The shader is intensive and might crash mobile browsers. Click to see the shader at shadertoy:

<center>
<a href="https://www.shadertoy.com/view/tsjyDG"><img src="https://www.shadertoy.com/media/shaders/tsjyDG.jpg"></a>
</center>


## Code

Very long, refer to the shadertoy link.