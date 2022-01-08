---
layout: generic
title: About
---

<style>
    #hewwo {
        image-rendering: -moz-crisp-edges;
        image-rendering: -webkit-crisp-edges;
        image-rendering: pixelated;
        image-rendering: crisp-edges;
        width: 90%;
    }
</style>
<center>
<div id="hewwo">
<script type="module">

import * as THREE from 'https://cdn.skypack.dev/three@0.135.0';
import { OrbitControls } from 'https://cdn.skypack.dev/three@0.135.0/examples/jsm/controls/OrbitControls.js';


const getCanvasSize = () => {
    const W = document.getElementById("hewwo").clientWidth;
    const H = document.getElementById("hewwo").clientHeight;
    const R = Math.min(400, W);
    return [W,R];
}

const LENGTH = 12;

const getRotXMat = (thetax) => {
    let c = Math.cos(thetax);
    let s = Math.sin(thetax);
    return [
        c, 0, 0, -s,
        0, 1, 0, 0,
        0, 0, 1, 0,
        s, 0, 0, c]
}
const getRotYMat = (thetay) => {
    let c = Math.cos(thetay);
    let s = Math.sin(thetay);
    return [
        1, 0, 0, 0,
        0, c, 0, -s,
        0, 0, 1, 0,
        0, s, 0, c]
}
const getRotZMat = (thetaz) => {
    let c = Math.cos(thetaz);
    let s = Math.sin(thetaz);
    return [
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, c, -s,
        0, 0, s, c]
}

function mul(matrix, point) {

    let c0r0 = matrix[ 0], c1r0 = matrix[ 1], c2r0 = matrix[ 2], c3r0 = matrix[ 3];
    let c0r1 = matrix[ 4], c1r1 = matrix[ 5], c2r1 = matrix[ 6], c3r1 = matrix[ 7];
    let c0r2 = matrix[ 8], c1r2 = matrix[ 9], c2r2 = matrix[10], c3r2 = matrix[11];
    let c0r3 = matrix[12], c1r3 = matrix[13], c2r3 = matrix[14], c3r3 = matrix[15];

    let x = point[0];
    let y = point[1];
    let z = point[2];
    let w = point[3];

    return [
        (x * c0r0) + (y * c0r1) + (z * c0r2) + (w * c0r3),
        (x * c1r0) + (y * c1r1) + (z * c1r2) + (w * c1r3),
        (x * c2r0) + (y * c2r1) + (z * c2r2) + (w * c2r3),
        (x * c3r0) + (y * c3r1) + (z * c3r2) + (w * c3r3)
    ]
}

const buildTesseract = (scale) => {

    const cube = [
    [
        [ 1,  1,  1],
        [-1,  1,  1],
        [-1, -1,  1],
        [ 1, -1,  1],
        [ 1,  1,  1],
        [ 1,  1, -1],
        [-1,  1, -1],
        [-1, -1, -1],
        [ 1, -1, -1],
        [ 1,  1, -1],
    ],
    [
        [-1, -1, -1],
        [-1, -1,  1]
    ],
    [
        [ 1, -1, -1],
        [ 1, -1,  1]
    ],
    [
        [-1,  1, -1],
        [-1,  1,  1]
    ],
    ]

    var tesseract = []
    for (let i = 0; i < 4; i++) {
        let ncube = [];
        for (let j = 0; j < cube.length; j++) {
            let seg = cube[j];
            let nseg = [];
            for (let k = 0; k < seg.length; k++) {
                let c = seg[k].slice(0);
                c.splice(i,0,3);
                c = c.map(x => x*scale);
                nseg.push(c);
            }
            ncube.push(nseg);
        }
        tesseract.push(ncube);
        ncube = [];
        for (let j = 0; j < cube.length; j++) {
            let seg = cube[j];
            let nseg = [];
            for (let k = 0; k < seg.length; k++) {
                let c = seg[k].slice(0);
                c.splice(i,0,-3);
                c = c.map(x => x*scale);
                nseg.push(c);
            }
            ncube.push(nseg);
        }
        tesseract.push(ncube);
    }
    return tesseract;
}

const baseTesseract = buildTesseract(LENGTH);

const transformTesseract = (tx,ty,tz) => {
    let mx = getRotXMat(tx), my = getRotYMat(ty), mz = getRotZMat(tz);
    var tesseract = [];
    for (let i = 0; i < baseTesseract.length; ++i) {
        let cube = baseTesseract[i].slice(0);
        let ncube = [];
        for (let j = 0; j < cube.length; ++j) {
            let seg = cube[j].slice(0);
            let nseg = [];
            for (let k = 0; k < seg.length; ++k) {
                let p = mul(mz, mul(my, mul(mx, seg[k])));
                //seg[k] = [p[0], p[1], p[2]];
                //nseg.push(new THREE.Vector3(p[0], p[1], p[2]));
                nseg.push(p[0], p[1], p[2])
            }
            ncube.push(new Float32Array(nseg));
        }
        tesseract.push(ncube);
    }
    return tesseract;
}

var colors = [
    0xed6a5a,
	0x9bc1bc,
	0x5ca4a9,
	0xe6ebe0,
	0xf0b67f,
	0xfe5f55,
	0xd6d1b1,
	0xc7efcf,
	0xeef5db,
	0x50514f,
	0xf25f5c,
	0xffe066,
	0x247ba0,
	0x70c1b3
];

var [W,H] = getCanvasSize();
const renderer = new THREE.WebGLRenderer({alpha: true});

renderer.setPixelRatio(0.5); // window.devicePixelRatio
renderer.setClearColor( 0xffffff, 0);
renderer.setSize(W,H ,false);
renderer.antialias = false;
document.getElementById("hewwo").appendChild( renderer.domElement );

const camera = new THREE.PerspectiveCamera(75, W/H, 0.1, 1000);
camera.position.set(40, 40, 40);

const scene = new THREE.Scene();

var tesseract = transformTesseract(0,0,0);

var segs = [];
for (let i=0; i<tesseract.length; ++i) {

    const lmat = new THREE.LineBasicMaterial(
        {
            color: colors[ i % colors.length ],
        }
    );

    let seg = tesseract[i];
    
    for (let j = 0; j < seg.length; ++j) {

        const geo = new THREE.BufferGeometry();
        geo.setAttribute( 'position', new THREE.Float32BufferAttribute( seg[j], 3 ) );

        const line = new THREE.Line( geo, lmat );
        line.computeLineDistances();
        segs.push( line );
        scene.add( line );
    }
}

const controls = new OrbitControls(camera, renderer.domElement);
//controls.enableZoom = false;
controls.enablePan = false;

var x = 0;
function animate() {

    requestAnimationFrame(animate);
    
    var tesseract = transformTesseract(x,x,x);
    let c = 0;
    for (let i=0; i<tesseract.length; ++i) {
        let s = tesseract[i];
        for (let j=0; j<s.length; ++j) {
            let arr = segs[c].geometry.attributes.position.array;
            for (let k=0; k<arr.length; ++k) {
                arr[k] = s[j][k];
            }
            segs[c].geometry.attributes.position.needsUpdate = true;
            //segs[c].geometry.process();
            //segs[c].geometry.advance(s[j]);
            c++;
        }
    }

    x += 0.002;

    controls.update();
	renderer.render( scene, camera );
};
    
function onWindowResize() {
    console.log("laod")
    var [W,H] = getCanvasSize();
    camera.aspect = W/H;
    camera.updateProjectionMatrix();
    renderer.setSize( W, H );

    for (let i=0; i<segs.length; ++i)
        segs[i].material.resolution = new THREE.Vector2(W,H);
}

animate();
window.addEventListener( 'resize', onWindowResize );
window.onload = onWindowResize;
</script>
</div>
</center>


# $$\displaystyle \forall a \in A: 1 \times a = a$$

Hi! I'm J̷̨̡͚̝͔̜̋̎̄̉͌͛͘ũ̷̺̯̊͘l̶̛̥̻̠͔̠̃͗͒̕̚͜͠͠è̷̱ṡ̶̨͓̜͖̗̤̞͠, still a student and unsure what to work on.

I've gained interest in many areas, which will probably be reflected in the messiness of this site in time to come. I've particular interest in Mathematics, Cryptography and Low level programming. Occasionally I do generative art and origami, and sometimes pursue cursed ideas.

If you find anything interesting and wanna tell me, or just wanna talk to me, I'm reachable at:

* [Twitter](https://twitter.com/FreeFooooooood)
* [Github](https://github.com/JuliaPoo)
* [Instagram](https://www.instagram.com/julia.poo.poo/)