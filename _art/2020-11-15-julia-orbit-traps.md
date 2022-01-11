---
layout: art-writeup
author: JuliaPoo
category: Shaders

display-title: Julia Orbit Traps
excerpt: Rendering the Julia Fractal but via orbit traps.

preview-url: /assets/art/2020-11-15-julia-orbit-traps/preview.png

gallery:

    - url: /assets/art/2020-11-15-julia-orbit-traps/1.jpg
      alt: Julia fractal with orbit traps
      desc: Julia fractal with orbit traps

        
tags:
    - generative
    - julia
    - orbit-traps
---

## Meta

_**2022 note**_: I've changed the colour scheme of the shader.

## Shader

<center>
<iframe class="shader-container" frameborder="0" src="https://www.shadertoy.com/embed/WdtBRS?gui=true&t=10&paused=false&muted=false" allowfullscreen></iframe>
</center>

## Code

```hlsl
#define MAX_ITER 500
#define INF 100.

#define col1 vec3(1., .3, .4)
#define col2 vec3(.4, 1., .2)
#define col3 vec3(.3, .4, 1.)

float trap(in vec2 uv, in vec2 p) {
    float txt = texture(iChannel0, uv).x;
    return distance(uv, p) * (txt + 1.);
}

float shake(float off)
{
    return sin(iTime*.5 + off) + .2*sin(iTime*.7+.5 + off*.3) + .1*sin(iTime+.3 + off*.7);
}

vec3 render(in vec2 uv)
{
    float s = .13*sin(iTime*.3);
    vec2 c = vec2(-0.77568377,0.134646737) + s*s;
    int i = 0;
    
    float mdist1 = INF; float mdist2 = INF; float mdist3 = INF;
    float dist1, dist2, dist3; 
    for (i=0; i<MAX_ITER; ++i)
    {
        if (uv.x*uv.x + uv.y*uv.y > 4.) break;
        
        uv = vec2(uv.x*uv.x - uv.y*uv.y, 2.*uv.x*uv.y) + c;
        
        dist1 = trap(uv, vec2(0.,0.));
        dist2 = trap(uv, vec2(0.,.5));
        dist3 = trap(uv, vec2(.5,0.));
        
        if (mdist1 > dist1) mdist1 = dist1;
        if (mdist2 > dist2) mdist2 = dist2;
        if (mdist3 > dist3) mdist3 = dist3;
    }
    
    // Compute smooth iteration:
    // https://www.iquilezles.org/www/articles/mset_smooth/mset_smooth.htm
    float iter = float(i) - log2(log2(dot(uv,uv))) + 4.0;
    iter /= float(MAX_ITER);
    
    vec3 col = mdist1*col1 + mdist2*col2 + mdist3*col3;
    col *= (cos(iter*1.57)+.6)/2.;
    col *= col;
    col = 1.-col;
    
    return clamp(vec3(col), 0.,1.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float s1, s2;
    s1 = shake(0.); s2 = shake(1.5);
    
    vec2 uv = (1.7 + .1*s1)*(fragCoord/iResolution.xy - .5);
    uv.x *= iResolution.x/iResolution.y;
    
    vec3 col = render(uv);
    vec3 w = vec3(2.,.2,.5);
    col += vec3(.1,-.3,.2)*(length(w) - dot(col, w));
    col = pow(col, vec3(1., 1.5, 1.9));
    
    fragColor = vec4(col, 1.);
}
```