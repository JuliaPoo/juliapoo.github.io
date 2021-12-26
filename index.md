---
layout: generic
title: Alulae
---

# Welcome to <span style="color:rgb(1, 253, 199)">_Alulae_</span>.

<div id="hewwo...">
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

const W = document.getElementById("hewwo...").clientWidth;
const R = 0.2;
const H = Math.max(W * R, 200);
    
const renderer = new THREE.WebGLRenderer({alpha: true});
renderer.setClearColor( 0xffffff, 0);
renderer.setSize( W,H );
renderer.antialias = true;
if (W < 1080) {renderer.setPixelRatio(Math.floor(1080/W)+1);}
document.getElementById("hewwo...").appendChild( renderer.domElement );

const camera = new THREE.PerspectiveCamera(20, W/H, 1, 1000000);
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
    let W = document.getElementById("hewwo...").clientWidth;
	let H = Math.max(W * R, 200);
    camera.aspect = W/H;
    camera.updateProjectionMatrix();
    renderer.setSize( W, H );
    if (W < 1080) {renderer.setPixelRatio(Math.floor(1080/W)+1);}
}
window.addEventListener( 'resize', onWindowResize );
document.onload = onWindowResize;

</script>
</div>

A place where I dump random things into and try my best to organise them.

## Why <span style="color:rgb(1, 253, 199)">_Alulae_</span>?

The **_[Alula](https://en.wikipedia.org/wiki/Alula)_** is the "thumb" of the bird, and being a feather it kinda alludes to writing. **_Alulae_** is the plural of **_Alula_**, which alludes to a collection of writings.

## What's here then?

Currently, nothing much. But I plan to use this to consolidate all the stuff I did. So expect stuff in the categories (not exhaustive):

1. CTFs
2. Mathematics
3. Origami
4. Art
5. Software Projects
