---
layout: generic
title: Alulae | Blog of a gremlin
---

<center>
<div id="hewwo">
<script type="module">

import * as THREE from 'https://cdn.skypack.dev/three@0.135.0';
import { OrbitControls } from 'https://cdn.skypack.dev/three@0.135.0/examples/jsm/controls/OrbitControls.js';
import { EffectComposer } from 'https://cdn.skypack.dev/three@0.135.0/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from 'https://cdn.skypack.dev/three@0.135.0/examples/jsm/postprocessing/RenderPass.js';
import { FilmPass } from "https://cdn.skypack.dev/three@0.135.0/examples/jsm/postprocessing/FilmPass.js"

THREE.Cache.enabled = true;

const params = {
    bloomStrength: 2.7,
    bloomThreshold: 0.9,
    bloomRadius: 0.72,

    focus: 190,
    aperture: 3.5,
    maxblur: 0.004,
    
    noiseIntensity: 0.5, 
    scanlinesIntensity: 0.1, 
    scanlinesCount: 600
};

const getCanvasSize = () => {
    const W = document.getElementById("hewwo").clientWidth;
    const H = document.getElementById("hewwo").clientHeight;
    const R = Math.min(350, W);
    return [W,R];
}

const [W,H] = getCanvasSize();
    
const renderer = new THREE.WebGLRenderer({alpha: true});
renderer.setClearColor( 0xffffff, 0);
renderer.setSize( W,H );
renderer.antialias = true;
document.getElementById("hewwo").appendChild( renderer.domElement );

const camera = new THREE.PerspectiveCamera(23, W/H, 1, 1000000);
camera.position.set(0, 0, 500);

const scene = new THREE.Scene();

const loader = new THREE.CubeTextureLoader();
const texture = loader.load([
    '/assets/img/index-heart/texture.jpg',
    '/assets/img/index-heart/texture.jpg',
    '/assets/img/index-heart/texture.jpg',
    '/assets/img/index-heart/texture.jpg',
    '/assets/img/index-heart/texture.jpg',
    '/assets/img/index-heart/texture.jpg',
  ]);
texture.mapping = THREE.CubeRefractionMapping;
const materialr = new THREE.MeshBasicMaterial(
    {
        color: 0xbb0000,
        envMap: texture,
        opacity: 0.7,
        transparent: true, 
        refractionRatio: 0.9,
        blending: THREE.AdditiveBlending,
    });
const materialg = new THREE.MeshBasicMaterial(
    {
        color: 0x00ff00,
        envMap: texture,
        opacity: 0.7,
        transparent: true, 
        refractionRatio: 0.9-0.005,
        blending: THREE.AdditiveBlending,
    });
const materialb = new THREE.MeshBasicMaterial(
    {
        color: 0x0000ee,
        envMap: texture,
        opacity: 0.7,
        transparent: true, 
        refractionRatio: 0.9-0.01,
        blending: THREE.AdditiveBlending,
    });

const materialm = new THREE.MeshBasicMaterial(
    {
        color: 0xf70073,
        opacity: 0.3,
        transparent: true, 
        blending: THREE.AdditiveBlending,
    });

var heartShape = new THREE.Shape();
heartShape.moveTo( 25, 25 );
heartShape.bezierCurveTo( 25, 25, 20, 0, 0, 0);
heartShape.bezierCurveTo( - 30, 0, - 30, 35, - 30, 35 );
heartShape.bezierCurveTo( - 30, 55, - 10, 77, 25, 95 );
heartShape.bezierCurveTo( 60, 77, 80, 55, 80, 35 );
heartShape.bezierCurveTo( 80, 35, 80, 0, 50, 0 );
heartShape.bezierCurveTo( 35, 0, 25, 25, 25, 25 );

const geometry = new THREE.ExtrudeGeometry(heartShape, 
    {   
        depth: 0, 
        bevelEnabled: true, 
        bevelSegments: 3, 
        bevelOffset: -5,
        bevelSize: 20, 
        bevelThickness: 20,
        curveSegments: 3,
    });

geometry.center();
geometry.position = new THREE.Vector3(0,0,0);
geometry.rotateX(Math.PI);
const heartr = new THREE.Mesh(geometry, materialr);
const heartb = new THREE.Mesh(heartr.geometry, materialg);
const heartg = new THREE.Mesh(heartr.geometry, materialb);
const heartm = new THREE.Mesh(heartr.geometry, materialm);
const heart1 = new THREE.Group();
heart1.add(heartr); heart1.add(heartg); heart1.add(heartb); heart1.add(heartm);

scene.add(heart1);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableZoom = false;
controls.enablePan = false;

const renderScene = new RenderPass( scene, camera );

const filmPass = new FilmPass(params.noiseIntensity, params.scanlinesIntensity, params.scanlinesCount, false);

const composer = new EffectComposer( renderer );
composer.addPass( renderScene );
composer.addPass( filmPass );


function clamp(num, min, max) {return Math.min(Math.max(num, min), max);}
function frac(x) {return x - Math.floor(x);}
function rand(x, seed) {return frac(seed * Math.sin(Math.floor(x)))}
function spline(x) {return Math.pow((2*x + 1) * (1 - x) * (1 - x), 2);}
function bumps0(x, seed) {return rand(x, 29734492) * spline(frac(x)) + rand(x+1, 29734492) * spline(frac(-x-1));}
function bumps1(x) {return Math.pow(Math.min(1, 1.4*bumps0(x, 29734492)), 20);}
function bumps2(x, seed) {return Math.pow(clamp(1.3*(bumps0(x, seed) * Math.sin(x * Math.PI)), -1, 1), 3);}

const p1 = heart1.position.clone();

var x = 0;
function animate() {
    requestAnimationFrame(animate);

    x += 0.01;

    heart1.rotation.y  = bumps2(x*2, 9123482);

    var shake1 = new THREE.Vector3(
        bumps2(x*7+0.1, 1820), 
        bumps2(x*8+0.4, 12983), 
        bumps2(x*9+0.3, 10278));
    shake1.multiplyScalar(10);
    shake1.add(p1);
    heart1.position.copy(shake1);

    filmPass.uniforms.sCount.value = 600 + 200*bumps2(x*8, 12081);

    composer.render(scene, camera);
};

animate();
    
function onWindowResize() {
    const [W,H] = getCanvasSize();
    camera.aspect = W/H;
    camera.updateProjectionMatrix();
    renderer.setSize( W, H );
}
window.addEventListener( 'resize', onWindowResize );
window.onload = onWindowResize;

</script>
</div>
</center>

# Welcome to <span style="color:rgb(1, 253, 199)">_Alulae_</span>.

A place where I dump random things into and try my best to organise them.

## Why <span style="color:rgb(1, 253, 199)">_Alulae_</span>?

The _[Alula](https://en.wikipedia.org/wiki/Alula)_ is the "thumb" of the bird, and being a feather it kinda alludes to writing. **_Alulae_** is the plural of **_Alula_**, which alludes to a collection of writings.

## What's here then?

Currently, nothing much. But I plan to use this to consolidate all the stuff I did. So expect stuff in the categories (not exhaustive):

1. CTFs
2. Mathematics
3. Origami
4. Art
5. Software Projects

<style>

#sky-with-my-beloved {
    font-family: monospace;
    white-space: pre;
    line-height: 1.4em;
    font-size: calc(min(9px, 1vw));
    text-shadow: 
        0 0 0.60em rgba(245, 83, 237, 1.6), 
        0 0 1.20em rgba(245, 83, 237, 1.3), 
        0 0 1.80em rgba(245, 83, 237, 0.8), 
        0 0 2.30em rgba(245, 83, 237, 0.6), 
        0 0 2.90em rgba(245, 83, 237, 0.3), 
        0 0 3.50em rgba(245, 83, 237, 0.2); 
    overflow: auto;
}

</style>
<center>
<div id="sky-with-my-beloved">
<!--googleoff: index-->
<pre>
{% raw %}
                                              V                 _L                          |       |               |  | __                                               )      )                           L                                      
                                              K                 M                           [       [               |  | ~/   /                                            M      (                          V                                      
                                             )                  /                          _L       /               |  |     /_                                            V^~/`  ]                          '                                      
                                   ___/`,    /                  (                          ]        | _,_          _|  |      [                                            [      [                           M                                     
                                  !__L__\~L _(                 _                           |        [ N&gt;~y       ,^)[  [ -,   [                                            |  _                               \                                     
                                            )                  /                           [        [ \~r'          {  L "`   [                                            ] `"    (                           L                                    
                                            /                  |                           V        [               |  L  _.  |                                             M      V                           V                                    
                                           _L                 _[                          _"        [               |  L]\    \                                             \      |                           )                                MFFp
                               _y`\        V                  M                           J        _`               [  L `    ]                                             ]       L                           K                                   
                               (  'L       }                  [                           ]        {                L  L      _                                              L   ___[                           \                                   
                               `~---f'     `                  |                           H        [                L _Lw                                                    ``7``                              J           fj7~v_                  
                                          V                  _L                }          V        ]     =-{^     (`v  L\L     L                                                                              &gt;-*              j^`                  
                                          k                  M                 [          /        )     ``        'L  L       L                                                                                                                    
                                                             /                J           {        |                L  L       [                                                                                                                    
                                         V                   (                n           [        (                L J        L                                                                                                                    
                                         [           _k`&gt;   _L                /           L        \               J  J        y     _,L~--                                                                                                         
                                        J`         ,/_&gt;"    O                 \          J          [              ]  J     _v{  __k"     (_                  -/```\~_                                                                              
                                        V          `(`      ]                _`          ]          [                 J__,r`  {C~H~L,__    `\                 `~_    /                                                                              
                                        {                   (                J           |          L              ]        CLLL,_    "\_    \                   ^-([_,,_                                 _-L                                       
                                       J`                  _L                          __/         j               ]    w*`(      `*._  ~[ _./                 _~``      `P                                ``                                       
                                       V                   U                 |`,~7jD7[7`6\_        |               ]   J`             `x,{*L                   ",   __L,_LL[                                                                        
                                       $                   ]                 _f  _/.^      \       [               |   'L u-X   _       [                        `^``                                                                     ___       
                                                           |                 /   7_\  , w^x \      [               |     ~`{ p )`M     _[                                                                                               .(  `\,     
                                      U                   _L                 L  Y3` &gt;(/L) V/`     .2_              |      M _V V  ^\  _/_ .                                                                                              `'(```     
                                      $                   ]                  \    /.M `    K2-H-~k"\~\             [      ^%`[_f`{CQ-,C  \\x                                                                                                        
                                     _`                   M      _@(j``      &gt;*`r."`"=.LL       `` |               /        ` _~(     `\_ "+\L                                                                                                      
                                     G                    |     .(/ `*~-H^7`(     (`,Y~_\          |               \         /`         \L  \,\_                                                                                                    
                                     /                    [     ``        _`         ` `&gt;_         (               /        _`           '.  `\`,                                                                                                   
                                     [                    (              _/               `~_ _    [               h        /             ',  _) `&gt;,_                                                                                               
                                    )                    _L            __/                   `MC2~~L               V      y/                \ \_,-_ )             __        _,  _.                                                                  
                        2&gt;          [                    M            _/y                        ``~FCl"(`Q.             _`\                 \    `; `&lt;_    JM   / `\     ,v` V |)L                                                                 
  _                @\ ,  __\;`7F~-=Hh                    [            y7                     _     .~,L,/C,f             /$                   \L   `x  \C   ]_L J` _/    ]  _,/ }O[                                                                 
  j` _."~}   |%    "(Dy  -/ "*xs~.                       D           /_\                     ^D~,,=-* _,k`               `\                    `\    `,__\.      ^M`      `^`                                                                       
_     `  L__ \\     K\        yn(`:~L                    [_         _(y                _     {__,x~-^`                  /G /                     \_   `jX`'x                                                                                        
^ /\     ~--`  "~@\  \\        `"  f_\L_                {` )        y_          \*_.~*"_)                              _\(/                       `o-~_  ^-/`                                                                                       
  ""   _  _~  .-, `    ;        '%_'j,\(&gt;-_             j  )       .\(wL    _,vP"    _"                                ///`      __v~eeee.  _ __ Yx \jj`                                                                                            
     ~&lt;`C .[  `*F ( H          \&\P  `y-s&lt;j7,_          |  (       /{/_\_c``___      V                                _L7`_.~^j``         , M \~' ^` )`6`                                                                                           
     `` `_(` 7      `   _=       __  '/`CJ;`_)\_ __e-=~r(l(___     *-(      Y   `j`77}     _L                         H/                   \                   _L_                __,,_                                                             
     ,-LX)\          ,,      __~7``~x   ^\/(}   `             ``````'7F~~~. `    ____ __v=,"{_ 7``\~                       \L             _/       =._=.q   _z"   (^L            y`    `.             _,-,L                                 _=-=_   
      `*           (M_.  _   y       `, (7`'\,_                          _[]     ('"x/('HCj^7"~-ffX;gC;)c)yz 2w7    vJH  _F-`  ]` ""`     'H.      `` ```   [        {          J       [            /`    \                    __   _,_   3`    ``\
\         "7  (O t  (M\  ~?? L        \ (Sv_  )                     %7cC CC     ~{\t~,         _,,e,7~-`^~-^`M=~r~=~.,~=-( `=,,__    __v~*=--~===~~~---rHH~"        `7````jjj`"`       `jjjjjjjjjj`(       ``777````HHHHHH~H^^'  \-P` `~~/       7"
-^'*)j&gt;~,/J,f~-*\M'``"\,_ ''`          ^`'\a~'`'6H-~~Lu___L   __  _ \      [  _vH/: };P```&gt;,~```  `'      ____k*~_=-*`''j`````(   (````{                                                                                        __LLL_,,LL--HH==--HH
~L  )'``~_vM``^[ \_"P[`*(&gt;([7~-._    W\~\  /)% _/(C`'~:[_)`() U [` ``      _L {    Hz("  "`/_&gt;~v^~~_   w`*`  `   `            \   V     /                                                 ______L__,,,ee--v==~~--H7``jj*~*C``""`                    
 \~~`           "` ~v'  `k_ ]    `&gt;,/  ]_ /`\_7` '`           `( /L_,^~=~r~"   *--M```~-~~fFH~--,,-(OOL\~H{j`"`*~,,,____,,,,,,_\  )__   (---HH~===~----HHHHHHHH666``````'''''`jj``````````                                                          
                          `C`           ``        _L____LLLLL_____L_,,__,,__       `--~-=~~---=-H~-~------==-^6H--HFHHH66666`-\,L-__,LL/                                                                                                            
                                                                            `````                __,eev==~v==.v~~-^^^,----L,,                                                                                                                       
{% endraw %}
</pre>
<!--googleon: index-->
</div>
</center>