---
layout: art-writeup
author: JuliaPoo
category: Shaders

display-title: Linearly Transformed Cosines with Textures
excerpt: Experimenting with real-time lighting from textures. This uses Linearly Transformed Cosines for the lighting. Custom raytracer.

preview-url: /assets/art/2020-03-07-ltc-with-textures/preview.jpg

gallery:

    - url: /assets/art/2020-03-07-ltc-with-textures/1-c.mp4
      alt: The shader animated
      desc: The shader animated
      type: video/mp4
      preview-url: /assets/art/2020-03-07-ltc-with-textures/1-preview.jpg
        
tags:
    - shader
    - raytracing
    - ltc
---

## Meta

This was done with reference to the paper Real-Time Polygonal-Light Shading with Linearly Transformed Cosines, which is a pretty fast way to handle lighting accurately. Also with referene to the amazing [demo](https://blog.selfshadow.com/sandbox/ltc.html) the authors provided.

I implemented lighting from a texture, though I did modify the processing of the texture part for shadertoy.

## Shader

<!--
<center>
<iframe class="shader-container" frameborder="0" src="https://www.shadertoy.com/embed/wlGSDK?gui=true&t=10&paused=false&muted=false" allowfullscreen></iframe>
</center>
-->

The shader is intensive and might crash mobile browsers. Click to see the shader at shadertoy:

<center>
<a href="https://www.shadertoy.com/view/wlGSDK"><img src="https://www.shadertoy.com/media/shaders/wlGSDK.jpg"></a>
</center>

## Code

Very long, refer to the shadertoy link.