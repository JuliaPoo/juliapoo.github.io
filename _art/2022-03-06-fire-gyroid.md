---
layout: art-writeup
author: JuliaPoo
category: Shaders

display-title: Fire Gyroid
excerpt: Been a while since I wrote a raytracer. Played around with shadows and lighting and _glow_.

preview-url: /assets/art/2022-03-06-fire-gyroid/preview.png

gallery:

    - url: /assets/art/2022-03-06-fire-gyroid/1-c.mp4
      alt: The shader animated
      desc: The shader animated
      type: video/mp4
      preview-url: /assets/art/2022-03-06-fire-gyroid/1-preview.png

    - url: /assets/art/2022-03-06-fire-gyroid/2.png
      alt: One frame of the shader
      desc: One frame of the shader
        
tags:
    - shader
    - raytracing
    - ltc
---

## Shader

The shader is intensive and might crash mobile browsers. Click to see the shader at shadertoy:

<center>
<a href="https://www.shadertoy.com/view/NdSfRy"><img src="https://www.shadertoy.com/media/shaders/NdSfRy.jpg"></a>
</center>


## Code

```glsl
#define EP .001
#define SCENE_END 20.
#define TRACE_MAX_STEPS 200

#define PI 3.1415
#define sTime iTime*.1

#define SCENE_ID_DEFAULT 0
#define SCENE_ID_OBJECT 1
#define SCENE_ID_GROUND 2
#define SCENE_ID_LIGHT 3

struct Ray {
    vec3 origin;
    vec3 direction;
};

struct Camera {
    vec3 pos;
    vec3 lookat;
    float zoom;
    float fov;
};

struct LightBase {
    vec3 colour;
};

struct LightDirectional {
    vec3 direction;
    vec3 colour;
};

struct LightPoint {
    vec3 position;
    vec3 colour;
};

LightBase clightBase = LightBase(.7*vec3(1.000,0.510,0.302));

LightDirectional clightDirectional = \
    LightDirectional(normalize(vec3(1.)), .3*vec3(1., .2, .1));
    
LightPoint clightPoint = \
    LightPoint(vec3(0.), .9*vec3(1.8,1.2,1.));

mat2 rot(in float a) {
	float s = sin(a);
	float c = cos(a);
	return mat2(c, -s, s, c);
}

float Primitive_sdGyroid(in vec3 p, in float scale, in float thickness)
{
    p /= scale;
    float gyroid = dot(sin(p), cos(p.yzx));
    return .7*scale*(abs(gyroid) - thickness);
}

float Primitive_sdSphere(in vec3 p, in float radius)
{
    return length(p) - radius;
}

float Primitive_sdBox(in vec3 p, in vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float Primitive_smoothUnion(in float d1, in float d2, in float k)
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h); 
}

float Primitive_smoothIntersect(in float d1, in float d2, in float k)
{
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) + k*h*(1.0-h); 
}
    
float Primitive_smoothSubtract(in float d1, in float d2, in float k)
{
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return mix( d2, -d1, h ) + k*h*(1.0-h); 
}

float Object_sdBall(in vec3 p)
{
    float ball = Primitive_sdSphere(p, 1.);
    float gyroid = Primitive_sdGyroid(p, .2, .3);
    ball = Primitive_smoothIntersect(ball, gyroid, .05);
    ball = Primitive_smoothSubtract(Primitive_sdSphere(p, .9), ball, .05);
    return ball;
}

float Scene_sdf_Object(in vec3 p)
{
    // Optimization
    float dp = length(p);
    if (dp > 1.1) {return dp - 1.;}
    
    float sc; vec3 _p = p;

    _p.yz *= rot(sTime); _p.zx *= rot(sTime);
    float ball = Object_sdBall(_p);
    
    sc = .8;
    _p = p; 
    _p.yz *= rot(-sTime*.7 + .5); _p.zx *= rot(sTime);
    ball = min(ball, sc*Object_sdBall(_p/sc));
    return ball;
}

float Scene_sdf_Ground(in vec3 p)
{
    // Optimization
    float dp = p.y;
    if (dp > 1.2) {return dp + 1.;}
    
    float ground = p.y + 1.1;
    float l = length(p.xz);
    ground += sin(l*5. - sTime*4.) * .1*smoothstep(0.,2.,l);
    return ground;
}

float Scene_sdf_Light(in vec3 p)
{
    p -= clightPoint.position;
    return Primitive_sdSphere(p, .1);
}

float Scene_sdf(in vec3 p)
{
    float object = Scene_sdf_Object(p);
    float ground = Scene_sdf_Ground(p);
    float light = Scene_sdf_Light(p);
    
    float sdf = min(object, ground);
    sdf = min(sdf, light);
    return sdf;
}

vec3 Scene_normal(in vec3 p) {
	const vec2 e = vec2(EP, 0);
	return normalize(vec3(Scene_sdf(p + e.xyy)-Scene_sdf(p - e.xyy), 
                          Scene_sdf(p + e.yxy)-Scene_sdf(p - e.yxy),	
                          Scene_sdf(p + e.yyx)-Scene_sdf(p - e.yyx)));
}

float _Scene_sdf(in vec3 p, inout float d_light_min, inout float d_object_min)
{
    float object = Scene_sdf_Object(p);
    float ground = Scene_sdf_Ground(p);
    float light = Scene_sdf_Light(p);
    
    d_light_min = min(d_light_min, light);
    d_object_min = min(d_object_min, object);
    
    float sdf = min(object, ground);
    sdf = min(sdf, light);
    return sdf;
}

float Ray_trace(inout Ray ray, out float d_light_min, out float d_object_min, out int surface_id)
{
    vec3 p = ray.origin;
    vec3 d = ray.direction;
    float dist = 0.;
    d_light_min = SCENE_END;
    d_object_min = SCENE_END;
    
    for (int i = 0; i < TRACE_MAX_STEPS; ++i) {
        vec3 _p = p + dist*d;
        float _d = _Scene_sdf(_p, d_light_min, d_object_min);
        dist += _d;
        if (_d < EP) break;
        if (dist > SCENE_END) break;
    }
    ray.origin = p + dist*d;
    
    surface_id = SCENE_ID_DEFAULT;
    if (Scene_sdf_Object(ray.origin) < EP) surface_id = SCENE_ID_OBJECT;
    else if (Scene_sdf_Ground(ray.origin) < EP) surface_id = SCENE_ID_GROUND;
    else if (Scene_sdf_Light(ray.origin) < EP) surface_id = SCENE_ID_LIGHT;
    
    return dist;
}

vec3 LightBase_computeLighting(in LightBase light)
{
    return light.colour;
}

vec3 LightDirectional_computeLighting(in LightDirectional light, in vec3 normal)
{
    float weight = dot(normal, light.direction);
    return light.colour * clamp(weight, 0., 1.);
}

vec3 LightPoint_computeLighting(in LightPoint light, in vec3 position, in vec3 normal)
{
    float weight = dot(normal, normalize(light.position - position));
    return light.colour * clamp(weight, 0., 1.);
}

vec3 LightPoint_computeShadow(in LightPoint light, in vec3 position, in vec3 normal)
{
    vec3 v = light.position - position;
    vec3 rd = normalize(v);
    float d_light_min, d_object_min;
    int surface_id;
    Ray ray = Ray(position + rd*3.*EP/dot(rd, normal), rd);
    float dist = Ray_trace(ray, d_light_min, d_object_min, surface_id);
    
    // Compute soft shadows uwu
    float w = 3. * pow(length(v) / SCENE_END, 2.);
    float w2 = smoothstep(0., w, d_object_min);
    return vec3(w2);
}

vec3 LightPoint_computeBleed(in LightPoint light, in vec3 position, in vec3 direction, in vec3 normal) 
{
    float x = -dot(normal, light.position - position);
        
    // Compute cheap bleed
    float w1 = .8;
    float w2 = .7;
    float bleed = w1 - clamp(x+(1.-w1), 0., 1.);
    vec3 col = w2 * bleed * light.colour;

    // Compute cheap subscattering
    w1 = 1.;
    w2 = 4.;
    bleed = w1 - clamp(x+(1.-w1), .7, 1.);
    col += w2 * bleed*bleed*bleed * vec3(1.,.1,.3);

    // Compute glare
    w1 = 1.;
    w2 = 10.;
    bleed = w1 - clamp(x+(1.-w1), 0., 1.);
    bleed *= 1.-smoothstep(0.,1.,
        length(
            dot(direction, light.position - position)*direction + position-light.position
        )
    );
    col += w2 * bleed*bleed*bleed * clightPoint.colour;
    
    return col;
}

vec3 Ray_lighting(in Ray ray)
{
    float t = sTime*2.;
    clightPoint.position = vec3(0.) + \
        .2*vec3(sin(t*10.), sin(t*13.+5.), sin(t*17.+2.)) + \
        .02*vec3(sin(t*50.), cos(t*57.+5.), sin(t*47.+2.));
    
    float d_light_min, d_object_min;
    int surface_id;
    float d = Ray_trace(ray, d_light_min, d_object_min, surface_id);
    
    vec3 col = vec3(0);
    
    if (surface_id == SCENE_ID_LIGHT) {
        col = clightPoint.colour;
        return col;
    }
    else {
    
        vec3 normal = Scene_normal(ray.origin);
    
        col += LightPoint_computeLighting(clightPoint, ray.origin, normal);
        col *= LightPoint_computeShadow(clightPoint, ray.origin, normal);
        
        col += LightBase_computeLighting(clightBase);
        col += LightDirectional_computeLighting(clightDirectional, normal);
        
        col += LightPoint_computeBleed(clightPoint, ray.origin, ray.direction, normal); 
    }
    
    // Compute cheap distance fog
    float fog = 1. - smoothstep(1., 4., d);
    col *= fog*fog;
    col = clamp(col, 0., 1.);
    
    // Compute cheap light fog
    fog = clamp(.03/(d_light_min+.01), 0.,1.);
    col += fog * clightPoint.colour;
    
    return col;
}

void Camera_init(inout Camera cam) 
{
    cam.pos = vec3(0,0,-3.);
    cam.lookat = vec3(0);
    cam.zoom = 1.;
    cam.fov = 1.;
}

void Camera_mouse(inout Camera cam)
{
    vec2 m = (iMouse.xy / iResolution.xy -.5 )* PI;
    cam.pos.xz *= rot(m.x);
    cam.pos.zy *= rot(m.y);
    cam.pos.y = max(cam.pos.y, -1.);
}

Ray Camera_projectRay(in Camera cam, in vec2 uv)
{
    vec3 front = normalize(cam.lookat - cam.pos);
    vec3 screen_origin = cam.pos + front * cam.zoom;
    vec3 vert = vec3(0,1.,0);
    vec3 up = normalize(vert-front*dot(vert, front));
    vec3 right = cross(front, up);
    
    uv *= cam.fov;
    vec3 ro = screen_origin + uv.x * right + uv.y * up;
    vec3 rd = normalize(ro - cam.pos);
    return Ray(ro, rd);
}

void Image_postProcessing(inout vec3 col)
{
    // Contrast!
    col *= col;
    // Cinematic
    col += 2.*vec3(.01,.05,.07);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord/iResolution.xy - .5;
    uv.x *= iResolution.x/iResolution.y;
    
    Camera cam; Camera_init(cam);
    Camera_mouse(cam);
    Ray ray = Camera_projectRay(cam, uv);
    
    vec3 col = Ray_lighting(ray);
    Image_postProcessing(col);
    
    fragColor = vec4(col, 1.);
}
```