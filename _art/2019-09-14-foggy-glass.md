---
layout: art-writeup
author: JuliaPoo
category: Shaders

display-title: Foggy Glass
excerpt: Custom raytracer rendering some glass and fog

preview-url: /assets/art/2019-09-14-foggy-glass/preview.jpg

gallery:

    - url: /assets/art/2019-09-14-foggy-glass/2.mp4
      alt: Glass cube spinning in fog 2
      desc: Glass cube spinning in fog 2
      type: video/mp4
      preview-url: /assets/art/2019-09-14-foggy-glass/2-preview.png
      
    - url: /assets/art/2019-09-14-foggy-glass/1.mp4
      alt: Glass cube spinning in fog 1
      desc: Glass cube spinning in fog 1
      type: video/mp4
      preview-url: /assets/art/2019-09-14-foggy-glass/1-preview.png

tags:
    - shader
    - raytracer
    - glass
---

## Meta

_**2022 note**_: Added some cool effects to the shader. Also there was a bug with shadertoy's embedded so I had to create a new (unlisted) post.

## Shader

The shader is intensive and might crash mobile browsers. Click to see the shader at shadertoy:

<center>
<!--<iframe class="shader-container" frameborder="0" src="https://www.shadertoy.com/embed/fdfyWn?gui=true&t=10&paused=false&muted=false" allowfullscreen></iframe>-->
<a href="https://www.shadertoy.com/view/WdcGD4"><img src="https://www.shadertoy.com/media/shaders/WdcGD4.jpg"></a>
</center>

## Code

```glsl
const float END = 20.;
const float ep = 0.001;

mat2 rot(float a){
	return mat2(cos(a), -sin(a), sin(a), cos(a));
}

float cube(vec3 p, float b, float r){
    vec3 d = abs(p) - b;
    return length(max(d,0.0)) - r + min(max(d.x,max(d.y,d.z)),0.0);
}

float sphere(vec3 p, float r){
 	return length(p) - r;  
}

float plane( vec3 p, vec4 n )
{
  	return dot(p,n.xyz) + n.w;
}

float light(vec3 p){
    vec3 move = 1.5*vec3(cos(iTime)*sin(iTime), sin(iTime)*sin(iTime), cos(iTime));
    vec3 p_ = p - move; p_.xy *= rot(iTime * 3.); p_.zy *= rot(iTime * 2.);
	return min(cube(p_, .17, 0.), sphere(p + move, .2)); 
}

float obj(vec3 p){
    p.xy *= rot(iTime * .3);
    float cube = cube(p, .5, .5);
    vec3 shook = .4*vec3(sin(iTime*3.), cos(iTime*4.), sin(iTime*2.));
    float sphere = sphere(p + shook, .4);
	return max(cube, -sphere);   
}

float mirror(vec3 p){
    float ripples = 0.1*sin(3.*length(p.xz) - iTime*pow(abs(sin(iTime*0.1)*0.5), 4.));
    //return plane(p, vec4(0.,1.,0., 1.1)) + ripples;
    return cube(p + vec3(0., 3., 0.), 1.7, 0.3) + ripples;
}

float SDscene(vec3 p){
   
	float obj = obj(p);
    float mirror = mirror(p);
    float light = light(p);
    float d = min(min(obj, mirror), light);
    
    return d;
}

vec3 SDnormal(vec3 p){
    
    //Calculates the normal vector of SDscene
    
    return normalize(vec3(
    SDscene(vec3(p.x+ep,p.y,p.z))-SDscene(vec3(p.x-ep,p.y,p.z)),
    SDscene(vec3(p.x,p.y+ep,p.z))-SDscene(vec3(p.x,p.y-ep,p.z)),
    SDscene(vec3(p.x,p.y,p.z+ep))-SDscene(vec3(p.x,p.y,p.z-ep))
    ));
}

float depth(vec3 ro, vec3 rd, float sig, inout float min_l){
    
    //Returns depth from ro given raydirection
    
    int max=300;
    vec3 p;
    
    float dist=0., d;
    for (int i=0; i<max; i++){
        p = ro + dist*rd;
    	d = SDscene(p)*sig;
        if (light(p) < min_l){ min_l = light(p);}
    if (abs(d)<ep){
        return dist;
    }
    dist += d;
    if (dist > END){
        return END;
    }
  }
}

void ray_mirror(inout vec3 ro, inout vec3 rd, inout float d, inout float min_l){
    
    int Nmax = 15, count = 0;
    while (count < Nmax){
        
        ro -= rd*ep*5.;
        rd = normalize(reflect(rd, SDnormal(ro)));
        d = depth(ro, rd, 1., min_l);
        ro += d*rd;
       
        if (mirror(ro) > ep){break;}
        
        count += 1;
    }
}

void ray_obj(inout vec3 ro, inout vec3 rd, inout float Dglass, inout float d, inout float min_l){
    
    int Nmax = 15, count = 0, count2 = 0;
    vec3 p, rd_;
    while (count < Nmax){
        
        //Go into glass
        ro += rd * ep*50.;
        rd = normalize(refract(rd, SDnormal(ro), 0.6));
        d = depth(ro, rd, -1., min_l);
        ro += rd * d;
    	Dglass += d;
        
        //internal refraction
    	rd_ = refract(rd, -SDnormal(ro), 1.5);
       	while (length(rd_) < 0.0001 && count2 < Nmax){
            
            rd = normalize(reflect(rd, -SDnormal(ro)));
            d = depth(ro, rd, -1., min_l);
            ro += d*rd;
            
            Dglass += d;
            rd_ = refract(rd, -SDnormal(ro), 1.5);
            count2 += 1;
        }
  
        if (length(rd_) > 0.0001){rd = normalize(rd_);}
        ro += rd * ep*10.;
        d = depth(ro, rd, 1., min_l);
        ro += rd * d;
        
        if (obj(ro) > ep){break;}
        
        //if (mirror(ro) > ep){ break;}
      	
		count += 1;
    }
}


void fresnel(vec3 ro, vec3 rd, inout float refl, inout float refr){
 	   
   	float b = ((1. - 1.5)/(1. + 1.5));
    float r0 = b*b;
    refl = r0 + (1. - r0)*pow((1. - abs(dot(SDnormal(ro), normalize(rd)))), 5.);
    refr = 1.-refl;
    //refl = .5; refr = .5;
}

vec3 render(vec2 uv){
    vec3 col;
    
    //Camera
    float ScreenSize = 4.;
    float shake = 0.3*sin(.3*iTime);
    
    float zoom = 2.5;
    float k = 0.4;
    float osc = sin(iTime*.3); //3.5 + 2.*osc*osc
  	vec3 ro = 6.*vec3(sin(k*iTime), shake, cos(k*iTime)) + vec3(0.,2.,0.);
  	vec3 lookat = vec3(0,0,0);
    
    
  	vec3 fw = normalize(lookat - ro);
  	vec3 r = normalize(cross(vec3(0,1.,0), fw));
  	vec3 up = normalize(cross(fw,r));
  	vec3 scrC = ro + (zoom)*fw;
  	vec3 scrP = scrC + (uv.x*r + uv.y*up) * ScreenSize;
  	vec3 rd = normalize(scrP - ro);
    
    float Dglass, min_l = END;
    float d = depth(ro, rd, 1., min_l);
    ro += d*rd;
    
    vec3 ro_, rd_;
    float refl, refr;
    int Nmax = 15, count;
    while (count < Nmax){
        //hits background
        if (d > END - ep){
            //col += texture(iChannel0, ro).xyz;
            vec3 tint = vec3(exp(Dglass*-0.05),exp(Dglass*-0.3),exp(Dglass*-0.7));
            col *= tint;
            col += pow(clamp(abs(1./min_l)*0.1, 0., 1.), .7);
            break;
        }
        
        //hit light
        else if (light(ro) < ep){
        	col += vec3(1.);
            break;
        }

        //hit obj
        else if (obj(ro) < ep){
            ro_ = ro; rd_ = rd;
            ray_obj(ro, rd, Dglass, d, min_l);
            ray_mirror(ro_, rd_, d, min_l);
        }

        //hit mirror
        else if (mirror(ro) < ep){
            ray_mirror(ro, rd, d, min_l);
        }
        
        else{d = END;}
        
        count += 1;
    }
    return col;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    float degree = .35*pow(0.538502*(sin(3.*iTime) + sin(iTime * 1.8)),8.) + .1;
    
    //Shader setup
    vec2 R = iResolution.xy;
    vec2 uv2 = (fragCoord - 0.5*R)/R.x;
    float aberr = length(uv2);
    vec2 uv_off = uv2 * vec2(aberr,aberr*aberr)*degree;
    fragColor = vec4(1);
    for(int i = 0; i < 3; i++) {
        vec2 uv = uv2 + uv_off*float(1-2*i);
        vec3 col = render(uv);
        fragColor[i] = col[i];
    }
    
}
```