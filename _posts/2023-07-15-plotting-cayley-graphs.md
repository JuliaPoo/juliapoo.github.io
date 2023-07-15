---
layout: post
author: JuliaPoo
category: Mathematics

display-title: "Cayley Graphs and Why They Are Pretty"
tags:
    - group-theory
    - rotation-groups
    - direct-products
    - semidirect-products

# nav: |
#     * TODO
    
excerpt: "A fun little approachable introduction to Cayley Graphs (and a little bit of group theory), and a writeup to [this little web widget I made](https://juliapoo.github.io/Cayley-Graph-Plotting/)"
---

<script type="importmap" async>
{
    "imports": { "three": "https://unpkg.com/three/build/three.module.js" }
}
</script>
<script type="text/javascript" src="//unpkg.com/dat.gui@0.7.6/build/dat.gui.js" async></script>
<script src="//unpkg.com/3d-force-graph" async></script>
<style>
.cayley-uwu {
  border: 2px solid rgb(1, 253, 198);
  box-sizing: border-box;
}
.cayley-container {
  padding-top: 1em;
  padding-bottom: 1em;
  display: flex;
  align-items: center;
  justify-content: center;
}
.graph-info-msg {
  top: 0.5em !important;
  color: white !important;
  opacity: 1 !important;
  font-family: victormono !important;
  font-size: 1.1em !important;
}
</style>
<script type="module">

import { Group, Matrix, Rational } from "https://juliapoo.github.io/Cayley-Graph-Plotting/ts/cayley.js";

const DATAURL = [
  fetch("https://juliapoo.github.io/Cayley-Graph-Plotting/rsrc/grouplisting.json"),
  fetch("https://juliapoo.github.io/Cayley-Graph-Plotting/rsrc/matrep.json")
];

function init_plot(dom) {

  const plt = ForceGraph3D({ antialias: true, alpha: true })
    (dom)
    .showNavInfo(false)
    .width(dom.clientWidth)
    .height(dom.clientHeight)
    .linkAutoColorBy(d => d.group)
    .linkWidth(2)
    .linkOpacity(1)
    .nodeColor((n) => "rgb(255,255,255)")
    .nodeOpacity(1)
    .d3AlphaDecay(0.005)
    .backgroundColor('rgba(0,0,0,0)');

  const scene = plt.scene();

  new ResizeObserver(() => {
    plt.width(dom.clientWidth)
      .height(dom.clientHeight);
  }).observe(dom);

  return [plt, scene];
}

function create_group(gmat, fp) {
  return new Group(
    gmat.map((m) => new Matrix(fp === "Q" ? m.map(Rational.new) : m, fp))
  )
}

function plot_group(plt, G) {
  const graph_data = {
    nodes: G.cayley.map((_, idx) => ({id: idx})),
    links: G.cayley.map((n, idx) => n[1].map((m, jdx) => (
      {
        source: idx,
        target: m,
        group: jdx
      }
    ))).reduce((a,b) => a.concat(b))
  };

  plt  
    .linkDirectionalArrowLength(d => {
      const g = G.gens[d.group];
      return g.mul(g) == G.id
        ? 0
        : 15
    })
    .graphData(graph_data);
}

window.addEventListener("load", () =>
  Promise.all(DATAURL)
    .then((vs) =>
      Promise.all(vs.map((r) => r.json())).then((vs) => {

        const [group_listing, matrep] = vs;
        const plot = (dom, gid) => {
            const [gmat, fp] = matrep[gid];
            const ginfo = group_listing.filter((g) => g[5] == gid)[0]
            const [_1, _2, name, desc, _3, _4] = ginfo;
            const [plt, scene] = init_plot(dom);
            const G = create_group(gmat, fp);
            plot_group(plt, G);

            dom.querySelector('.graph-info-msg').innerHTML = "Graph of " + name;
        };

        plot(document.getElementById("plot1"), "60_5")
      })
    )
);

</script>


I recently made a little [web-widget](https://juliapoo.github.io/Cayley-Graph-Plotting/) to plot Cayley Graphs of over 6000 finite groups because I had a feeling they would look pretty.

<div class="cayley-container">
<div id="plot1" class="cayley-uwu" style="width:calc(100% - 2em); height: 500px;"></div>
</div>

And they are right? Above is the plot of the cayley graph of a very well-known group $A_5$. For all diagrams in this post, feel free to zoom, pan and rotate the plots.

## Wait what are Cayley Graphs?

In short, Cayley Graphs are [graphs](https://en.wikipedia.org/wiki/Graph_(discrete_mathematics)) (and by that I mean a bunch of nodes connected by lines) that encode, rather inefficiently, the abstract structure of a [_Group_](https://en.wikipedia.org/wiki/Group_(mathematics)).

A Group on the other hand is, informally, a non-empty set whose elements are '_symmetrically related_' to each other. Groups are very fundamental objects in Mathematics and appear everywhere in Mathematics. The symmetries of a particular group are somewhat reflected in the symmetries of its cayley graph.

While a group's cayley graph encodes the entire structure of a group, it does so rather inefficiently and it's often easier to study groups abstractly. However, I think they are pretty, and there are a few group-theoretic concepts that present themselves naturally in cayley graphs.

This post will cover the bare minimum about Groups to appreciate cayley graphs, and you can also try plotting other groups in my [web-widget](https://juliapoo.github.io/Cayley-Graph-Plotting/). If you're interested in more useful ways to visualise groups, do take a look at my post on [Visualising Homomorphisms](/mathematics/2022/12/15/homomorphism-illustrated.html) which gives an intuition for the isomorphism theorems.

## So why can Groups be considered "symmetrical"



<!-- 
1. Intro
2. What are groups and how are they symmetrical
2. What are Cayley Graphs and how do they showcase this symmetry
3. Rotation Groups
4. Direct Products
5. Semi-direct products
-->