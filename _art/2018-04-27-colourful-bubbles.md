---
layout: art-writeup
author: JuliaPoo
category: Shaders

display-title: Colourful Bubbles
excerpt: Like, my first shader I think. A bunch of blinking circles.

preview-url: /assets/art/2018-04-27-colourful-bubbles/preview.jpg

gallery:

    - url: /assets/art/2018-04-27-colourful-bubbles/1-c.mp4
      alt: Colourful blinking circles
      desc: Colourful blinking circles
      type: video/mp4
      preview-url: /assets/art/2018-04-27-colourful-bubbles/1-preview.jpg
        
tags:
    - shader
    - bubbles
---

## Meta

_**2022 note**_: The code below is _**prettified**_. Click the original shadertoy link to see true horror.

## Shader

<center>
<iframe class="shader-container" frameborder="0" src="https://www.shadertoy.com/embed/4d3BWH?gui=true&t=10&paused=false&muted=false" allowfullscreen></iframe>
</center>

## Code

```hlsl
//Noice function [0,1]
vec2 T = vec2(0.);
float No(float x)
{
    return fract(9667.5 * sin(7983.75 * (x + T.x) + 297. + T.y));
}

vec4 Rancol(vec2 x)
{
    return vec4(No(x.x + x.y), No(x.x * x.x + x.y), No(x.x * x.x + x.y * x.y), 1.);
}

//bubbles!!
vec4 grid(vec2 uv, float t)
{
    vec4 C1, C2;
    uv *= 20.;
    vec2 id = vec2(int(uv.x), int(uv.y));
    uv.y += (5. * No(id.x * id.x) + 1.) * t * .4;
    uv.y += No(id.x);
    id = vec2(int(uv.x), int(uv.y));
    uv = fract(uv) - .5;

    //if (id == vec2(1,10)){C1 = vec4(1.);}

    float d = length(uv);
    t *= 10. * No(id.x + id.y);
    //uv.x += No(id.x);
    //if (uv.x > .46 || uv.y > .46){C1 = vec4(1.);}

    float r = .1 * sin(t + sin(t) * .5) + .3;
    float r1 = .07 * sin(2. * t + sin(2. * t) * .5) + .1 * No(id.x + id.y);
    if (d < r && d > r - .1)
    {
        C2 = .5 * Rancol(id + vec2(1.)) + vec4(.5);
        C2 *= smoothstep(r - .12, r, d);
        C2 *= 1. - smoothstep(r - .05, r + .12, d);
    }

    if (d < r1)
    {
        C2 = .5 * Rancol(id + vec2(1.)) + vec4(.5);
    }

    return C2 + C1;
}
void mainImage(out vec4 C, in vec2 U)
{
    vec2 uv = U / iResolution.xy;
    uv.y *= iResolution.y / iResolution.x;
    float t = iTime;
    T = iMouse.xy;
    C = vec4(grid(uv, t));
}
```