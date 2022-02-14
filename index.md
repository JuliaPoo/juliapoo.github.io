---
layout: generic
title: Alulae
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
<pre>
{% raw %}
                                              V                 _L                          |       |               [  [ __                                               '      V                          "L                                      
                                              K                 O                           [       f               [  [^~'   (                                            [      M                          C                                      
                                             )                  /                          UL       /               [  [     /_                                            U^L/`  )                          '                                      
                                   ___/`(    )                  (                          j        | ___          _[  [      [                                            j      \                           [                                     
                                  !_____"~, _^                 _`                          |        [ N&gt;~)       ,^)j  [ y?   j                                            |  _   "r                          \                                     
                                            )                  (                           (        [ \~P`          [  L "`   j                                            ]_``    [                          dL                                    
                                            /                  |                           |        [               [  L  _   |                                             [      )                           V                                    
                                           _h                  [                          q"        [               [  L]@    \                                             \      %                           '                                "FFp
                               _/"(        V                  M                           d        _"               [  L `    ]                                             ]      "L                           N                                   
                               [  '_       |                  /                           ]        f                L  L      d                                              [   ___[                           \                                   
                               `~---='    ]`                  |                           |        [                L _Lw     dL                                             ```"                               d          "~Q`~L_                  
                                          V                  _L                |          V        ]     ~-(W     C`, dL\h     L                                                                              --`              `^"                  
                                          K                  M                 [          /        )     ``        ^L  L       [                                                                                                                    
                                         d                   %                d           {        |                L  L       [                                                                                                                    
                                         V                   (                |           [        (                L d       /L                                                                                                                    
                                         [           _0CN   _h                )           L        h               d  d        }     __L~-~                                                                                                         
                                        J`         ,/_&gt;"    W                 [          d          [              ]  d     _-/  __/C     (_                 q-/```\~_                                                                              
                                        V          `C`      )                q`          ]          [              j  d__,r`  CC-~~LL__    `\                 `~_    /                                                                              
                                        {                   (                d           |         dL              ]        C,LL__     \_    \                   ^z(]____                                 _-L                                       
                                       J`                  _L                J_        __)         j               ]    ,^`C      `^(_  ~j _./                 _z``      `\/                               ``                                       
                                       V                   |                 |`_~``C~C7`*\_        |               ]   J`             `~,C*,                   "k   __LL___[                                                                        
                                       K                   /                 _/  _/.(      \       [               |   'C |vX   _       [                        ^j``                                                                     ___       
                                      d                    |                 /   y.[  , ,^\ \      [               |    "&lt;`[ Y )`\     _[                                                                                               .(  "\,     
                                      U                   _L                 L  Y/) .(/,) V/"     _2_              |      7 _V V "^o  _/_\.                                                                                              `j````     
                                      /                   j                  \    PyM `    OZ-^~e&lt;`F~"             j      ^0`j_%`CCQ-L"  \}\                                                                                                        
                                     q`                   M      _^Cj``      )^`~."`"=.__       `` |               j        ` .z"     `\_ `s\,                                                                                                      
                                     |                    |     )(/ `^~-j``Q"      `,Y~_(          |               (         /`         \,  \,\_                                                                                                    
                                     /                    /     ``        _"         ` `P_         (               )        )`           `,  "\`k                                                                                                   
                                     [                    '              _/               `~___    [               |        /             ^(  _) `~L_                                                                                               
                                    d                    _L            __/                   `MCC~~[               |      (/                \ \_.-_ )             __        _.  _,                                                                  
                        &lt;L          )                    M            _/y                        ``~FCjj``]L             J [                 \    "( `L_    dX   / `U     _v` \ |)                                                                  
  __               L\ =  __\j``F~-=~'                    J            }7                     _     .~__.^`,/             )@                   \_   `\  \C   ]/L J` ,/    ]  __/ VU"                                                                 
  T` _L"~}   |%    "(Cy J-"  }xs~.                       |           /_'                     ^)~_,~-* _.0`              J\/                    `(    `(   (      ^r`      `j`                                                                       
_     `  ___ \)     O\        &lt;nQ`&lt;~L                    [_         _{y         W_     _     (___-~-^`                  )G /                     \_    `Z`"x                                                                                        
P (\    /~--`  "~Q\  \\        `"  %_[L_                f` )        y_`         \*__~^`_J                              J (/                       `L-~_  ^-&lt;`                                                                                       
  ""   _  _~  ,~. `   Jj        '@_`j(\]\-_             j  )       )\'w     __&gt;P`    _"                                Y//`      __x~LLLL.  _  _ Rs \``}[                                                                                           
     ~&lt;`C_,[  ``F SLH          ]&FP  `)ys&lt;j7__          |  (       /{/_'CC``___      V                                _h)`_L~'```        ^( F "~' `` ``^`                                                                                           
     `` "_]`"?L         _~       __  '/`C"j"_)[_ __,-=~rCjC___     "-"      y   `j```%     )L                         H/  j                \                   ___                _____                                                             
     ,-,X)"          .,      __~`'`~~_  `\&lt;[|   `               ````j`F~H~.#`    ____ __&gt;=,"{_ r``YF                       \_             _/       =._=.T    y"   `^(            y`    `(             _,-L_                                 _=-~C   
      `*           ()__  _   /       ?, S%``\L_                          _[]     @jOx/`'HC/^`"~~*=ZC2CC2cLc&gt; Jkz    tQH  _F-`  ]` ``      'H.      `` ``    C        [          j`      J            /`    \                    __   ___   )`    ``\
S         "/  (O (L @S"  ~Q@dL        \ (}~_  ]                     r`QCz]CC    _rO\t~,         __.L.r~z`^~-j`\=er~=~.,~=~Q `~____     _,F"~--~===eee---rjjj"        ``````jjj```       `jjjjjjjjjj``       `````````6jjjjjFj`^'  "-P` "~e"       `"
-FjSW[&gt;~,/JLf~-^\&lt;j`j"\L )Oj`          ^`^~C+j`'^F-~LLL___L   __  _ %      \  _&lt;F@I }CP```\,=```  `'      ____0*~_=-*`jj```` `[   @````(                                                                                         _______LL--~~==--FF
~_  Q^`j~_vM``^\ }_"P``*(&gt;(]\~~._    W^~\  /C/ _/CC`*e&lt;/_)`C&lt; U ][ ``      _L (    Hz``  ``[_.~v^~~_   )`^`  `   `            \   U     %                                                 ___________LLL---==~e--F```jjF~*`````                     
 ^~&lt;`           j`"~-'  'k_ )    `kL/  ]_ /`\_c` j`           `` /C_,^~=~F~"   `--*```~-~~=F~~--L,-bQQL"~F`````*~LLL____LLLLLL_[  )__   {---~~~===~----FFFFFFFF^^^``````jjjjjj``````````                                                            
                          ```           ``        _________________._____.__       `--~-=~~---=-FH-H------==-F^F--FFFFF^^^^^`-SLLeC_.LL/                                                                                                            
                                                                            `````                ___LL-==~-~~L.~~-`^\,----L_,                                                                                                                       
{% endraw %}
</pre>
</div>
</center>