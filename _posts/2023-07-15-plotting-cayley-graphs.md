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
    
excerpt: "A fun approachable introduction to Cayley Graphs (and a little bit of group theory), and a writeup to [this little web widget I made](https://juliapoo.github.io/Cayley-Graph-Plotting/)"
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
  const controls = plt.controls();
  controls.noPan = false;

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

function isElementInViewport(el) {
  const rect = el.getBoundingClientRect();
  return (
    rect.bottom >= 0 &&
    rect.right >= 0 &&
    rect.top <= (window.innerHeight || document.documentElement.clientHeight) &&
    rect.left <= (window.innerWidth || document.documentElement.clientWidth)
  );
}

function onVisibilityChange(el, callback) {
  let uwu = false;
  return () => {
    if (isElementInViewport(el)) {
      if (!uwu) {
        callback();
      }
      uwu = true;
    }
  }
}

function attach(handler) {
  window.addEventListener('DOMContentLoaded', () => handler(), false);
  window.addEventListener('load', () => handler(), false);
  window.addEventListener('scroll', () => {handler()}, false);
  window.addEventListener('resize', () => handler(), false);
  handler();
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
          return plt;
        };
        const plot2 = (dom, G, gid) => {
          const [gmat, fp] = matrep[gid];
          const ginfo = group_listing.filter((g) => g[5] == gid)[0]
          const [_1, _2, name, desc, _3, _4] = ginfo;
          const [plt, scene] = init_plot(dom);
          plot_group(plt, G);

          dom.querySelector('.graph-info-msg').innerHTML = "Graph of " + name;
          return plt;
        }

        let plt, linkforcectx, _gmat, _fp, _G, _Ggens, handler;
        
        const dom1 = document.getElementById("plot1")
        attach(onVisibilityChange(dom1, function() {
          plot(dom1, "60_5")
        }));

        const dom2 = document.getElementById("plot2")
        attach(onVisibilityChange(dom2, function() {
          plot(dom2, "5_1")
        }));

        const dom3 = document.getElementById("plot3")
        attach(onVisibilityChange(dom3, function() {
          plot(dom3, "12_4")
        }));

        const dom4 = document.getElementById("plot4")
        attach(onVisibilityChange(dom4, function() {
          plt = plot(dom4, "12_1")
          linkforcectx = plt.d3Force('link');
          linkforcectx.distance(d => [50, 150][d.group]);
        }))

        const dom7 = document.getElementById("plot5")
        attach(onVisibilityChange(dom7, function() {
          plot(dom7, "4_1")
        }));

        const rot1 = document.getElementById("plot-rot-3")
        attach(onVisibilityChange(rot1, function() {
          [_gmat, _fp] = matrep["60_5"];
          _G = create_group(_gmat, _fp);
          _Ggens = _G.gens;
          _Ggens[0] = _Ggens[0].mul(_Ggens[0]);
          const G1 = new Group(_Ggens.map((g) => g.mat));
          plot2(rot1, G1, "60_5");
        }))

        const rot2 = document.getElementById("plot-rot-2")
        attach(onVisibilityChange(rot2, function() {
          [_gmat, _fp] = matrep["24_12"];
          _G = create_group(_gmat, _fp);
          _Ggens = _G.gens;
          _Ggens[2] = _Ggens[3].mul(_Ggens[2]);
          _Ggens[1] = _Ggens[3].mul(_Ggens[1]);
          const G2 = new Group(_Ggens.map((g) => g.mat));
          plt = plot2(rot2, G2, "24_12");
          linkforcectx = plt.d3Force('link');
          linkforcectx.distance(d => [300,60,0,60][d.group]);
        }))

        const rot3 = document.getElementById("plot-rot-1")
        attach(onVisibilityChange(rot3, function() {
          [_gmat, _fp] = matrep["12_3"];
          _G = create_group(_gmat, _fp);
          _Ggens = _G.gens;
          _Ggens[0] = _Ggens[2].mul(_Ggens[0]);
          const G2 = new Group(_Ggens.map((g) => g.mat));
          plt = plot2(rot3, G2, "12_3");
          linkforcectx = plt.d3Force('link');
          linkforcectx.distance(d => [200,60,60][d.group]);
        }))

        const rot4 = document.getElementById("plot-rot-6")
        attach(onVisibilityChange(rot4, function() {
          [_gmat, _fp] = matrep["60_5"];
          _G = create_group(_gmat, _fp);
          _Ggens = _G.gens;
          _Ggens[0] = _Ggens[0].mul(_Ggens[0]);
          const G1 = new Group(_Ggens.map((g) => g.mat));
          const pltt = plot2(rot4, G1, "60_5");
          const linkforcectxx = pltt.d3Force('link');
          const a = window.setInterval(() => {
            linkforcectxx.distance(d => [0, 200][d.group]);
            pltt.d3ReheatSimulation()
          }, 6000);
          const woof = window.setInterval(() => {
            const b = window.setInterval(() => {
              linkforcectxx.distance(d => [200, 0][d.group]);
              pltt.d3ReheatSimulation()
            }, 6000)
            clearInterval(woof)
          }, 3000)
        }))

        const d1 = document.getElementById("plot-direct-1")
        attach(onVisibilityChange(d1, function() {
          plot(d1, "200_37")
        }));
      })
    )
);

</script>


I recently made a little [web-widget](https://juliapoo.github.io/Cayley-Graph-Plotting/) to plot Cayley Graphs of over 6000 finite groups because I had a feeling they would look pretty.

<div class="cayley-container">
<div id="plot1" class="cayley-uwu" style="width:calc(100% - 2em); height: 500px;"></div>
</div>

And they are right? Above is the plot of the cayley graph of a very well-known group $A_5$. For all such diagrams in this post, feel free to zoom, pan and rotate the plots.

## Wait what are Cayley Graphs?

In short, Cayley Graphs are [graphs](https://en.wikipedia.org/wiki/Graph_(discrete_mathematics)) (and by that I mean a bunch of vertices connected by lines) that encode, rather inefficiently, the abstract structure of a [_Group_](https://en.wikipedia.org/wiki/Group_(mathematics)).

A Group on the other hand is, informally, a non-empty set whose elements are '_symmetrically related_' to each other. Groups are very fundamental objects in Mathematics and appear everywhere in Mathematics. The symmetries of a particular group are somewhat reflected in the symmetries of its cayley graph.

While a group's cayley graph encodes the entire structure of a group, it does so rather inefficiently and it's often easier to study groups abstractly. However, I think they are pretty, and there are a few group-theoretic concepts that present themselves naturally in cayley graphs.

This post will cover the bare minimum about Groups to appreciate cayley graphs, and you can also try plotting other groups in my [web-widget](https://juliapoo.github.io/Cayley-Graph-Plotting/). If you're interested in more useful ways to visualise groups, do take a look at my post on [Visualising Homomorphisms](/mathematics/2022/12/15/homomorphism-illustrated.html) which gives an intuition for the isomorphism theorems.

## What are groups?

Here's a description of a group:
> A group $G$ is a set of elements (cannot be empty) and a _binary operation_ $\cdot$ such that for any $a,b,c \in G$ the following holds
> 1. Associativity: $(a \cdot b) \cdot c = a \cdot (b \cdot c)$
> 2. Identity: There exists an element $e \in G$ such that $a \cdot e = e \cdot a = a$. In other words, $e$ doesn't change anything
> 3. Inverse: There exists an element which I'll denote $a^{-1}$ such that $a \cdot a^{-1} = a^{-1} \cdot a = e$. In other words, $a^{-1}$ _reverses_ what $a$ does, since $a^{-1} \cdot a \cdot b = e \cdot b = b$.
> 
> Where a binary operation is simply some operation that takes in two elements of $G$ and spits out another element of $G$.
> Note that we do not require $a \cdot b = b \cdot a$. This property of being able to "flip" the order of arguments is called _Abelian_.
>
> If a group $G$ has a finite number of elements, I'll call it a _finite group_. Otherwise, it's an _infinite group_.
>
> For brevity I would sometimes omit the $\cdot$, so $a \cdot b$ might be written as simply $ab$.

This description can apply to a whole bunch of things. A classic example is the integers $\mathbb{Z}$ and the operations $+$. For any integers $a,b,c$, we have:

1. $(a + b) + c = a + (b + c)$
2. $0 + a = a + 0 = a$
3. $a + (-a) = (-a) + a = 0$

Of course, in this example, $\mathbb{Z}$ is abelian as $a + b = b + a$. There are however groups where this doesn't hold. If you've played Zelda Tears of the Kingdom, you'd have encountered such a group when rotating an object. 

{% capture code %}
<div style="display: flex; align-items:center; justify-content: center;">
<blockquote class="twitter-tweet" data-theme="dark" data-dnt="true" align="center"><p lang="en" dir="ltr">In Zelda Tears of the kingdom, you can only rotate vertically and horizontally by 45°. Here&#39;s a tip for rotating around the third axis: Rotate all four directions, in order, for a 45° rotation<br><br>→↓←↑ = ↺<br>→↑←↓ = ↻<br><br>This happens because of some pretty neat math <br><br>1/🧵 <a href="https://t.co/H64RnTcCnf">pic.twitter.com/H64RnTcCnf</a></p>&mdash; chessapig (@chessapigbay) <a href="https://twitter.com/chessapigbay/status/1658711763960086529?ref_src=twsrc%5Etfw">May 17, 2023</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
</div>
{% endcapture %}
{{ code }}

You're pretty much only able to rotate 45 degrees horizontally and vertically. However, denoting $↓,→,↑,←$ to be a 45 degree rotation towards the direction of the arrow, we can also rotate around the third axis as performed by [@chessapig](https://twitter.com/chessapigbay) above:

$$
→ \; ↓ \; ← \; ↑ \; = \; ↺ \\
→ \; ↑ \; ← \; ↓ \; = \; ↻
$$

Do check out the thread above btw, it has a few interesting tibits.

Notice that the four operations here omit the brackets. For instance, the brackets in this expression $((→ \; ↓) \; ←) \; ↑$ are extraneous since it doesn't matter how I draw the brackets. This stems from the _associativity_ of 3D rotations.

The set of all rotations accessible by 45 degrees horizontal and vertical rotations form a group $G$ (try it yourself!). However, it is not abelian as otherwise, chessapig's rotation trick wouldn't work. This is because we can view $←$ as reversing whatever $→$ does, and similarly for $↓$ for $↑$. In other words, we can rewrite the above relations to be:

$$
→ \; ↓ \; →^{-1} \; ↓^{-1} \; = \; ↺ \\
→ \; ↑ \; →^{-1} \; ↑^{-1} \; = \; ↻
$$

Now, if this group $G$ is indeed abelian, then we would have for instance,

$$
\begin{aligned}
→ \; ↓ \; →^{-1} \; ↓^{-1} \; &= \; → \; (↓ \; →^{-1}) \; ↓^{-1} \\
&= \; → \; (→^{-1} \; ↓) \; ↓^{-1}  \\
&= \; (→ \; →^{-1}) \; (↓ \; ↓^{-1}) \\
&= \; e  \;  e = e \\
&\ne \; ↺
\end{aligned}
$$

Well clearly doing nothing ($e$) isn't the same as $↺$, so the group isn't abelian!

There's a caveat though; if you were to study the group $G$ accessible by 45 degree horizontal and vertical rotations, you'd realise that this group is infinite (If you know some linear algebra, you can try to prove this). However, if you have played the game, which I haven't, you'd notice the game only allows you to rotate an object a finite number of ways. This is because the game _cheats_, snapping the rotation of the object to the closest of a finite number of possibilities. Hence, the rotations as implemented in the game do not actually form a group.

This group $G$ is a _subgroup_ (i.e., a subset that also forms a group) of an infinite group known as $\mathrm{SO}(3)$, the set of all possible 3D rotations. We'll be encountering finite subgroups of $\mathrm{SO}(3)$ later in this post because they have particularly interesting Cayley graphs.

In this case, every element of $G$ is some combination of $→$ and $↓$ and their inverses. We say that $G$ is _generated_ by the elements $→$ and $↓$.

In general, we can always find a subset of any group $G$ that generates $G$. It's clear that finite groups have finite sets of generators. However, some infinite groups have finite sets of generators too, for instance, $\mathbb{Z}$ is generated by $1$.

## What's a group's Cayley Graph?

Let's suppose a group $G$ is generated by three elements $a,b,c \in G$. Every element of $g$ can be written as a combination of $a,b,c$, for instance, $g = abbc$. Note that because of associativity I can omit the brackets. We can think of "reaching" $g$ from $e$ via successive applications of left multiplication by $a,b,c$:

$$
e \xrightarrow{c} c \xrightarrow{b} bc \xrightarrow{b} bbc \xrightarrow{a} abbc
$$

Every element of $G$ can be thought of as a "path" from $e$, where each step involves taking one of the paths, $a,b$ or $c$. Of course, this path would be dependent on the choice of the set of generators $a,b,c$. Note that this "path" description of elements in a group $G$ only makes sense because of the associativity of the binary operation.

In finite groups, a path will eventually lead back to an element that has already been encountered. For instance, in a group $C_5$, there exists a single generator $g \in C_5$ such that $C_5 = \\{e, g^1, g^2, g^3, g^4\\}$. In this case, every path has to loop back to the identity $e$:

$$
e \xrightarrow{g} g^1 \xrightarrow{g} g^2 \xrightarrow{g} g^3 \xrightarrow{g} g^4 \xrightarrow{g} e
$$

<div class="cayley-container">
<div id="plot2" class="cayley-uwu" style="width:calc(100% - 2em); height: 500px;"></div>
</div>

This "looping" behaviour is why $C_5$ is called a _cyclic group_.

Now suppose we have multiple generators. We can represent left multiplication by each generator as a path with a unique colour. An arrow marks the direction of the path.

<div class="cayley-container">
<div id="plot3" class="cayley-uwu" style="width:calc(100% - 2em); height: 500px;"></div>
</div>

When we have two arrows pointing end-to-end, such as when we have
$e \xrightarrow{g} g \xrightarrow{g} e$, we can omit the arrow's direction.

The resulting graph is what is known as a Cayley Graph of a group. Each vertex on the graph is a unique element of the group, and each edge extending from a vertex represents a "path" from one vertex to another via left multiplication of a generator.

<div class="cayley-container">
<div id="plot4" class="cayley-uwu" style="width:calc(100% - 2em); height: 500px;"></div>
</div>

You might immediately notice that Cayley graphs tend to be rather symmetrical, which stems from the properties of groups. Firstly, every vertex has exactly one path per colour going away from the vertex, and one path per colour going into the vertex.

The reason why the paths have to be "balanced" in such a way is because of the existence of _inverses_ of every element in a group.

Suppose we have the path $a \xrightarrow{g} b$. Another way to write this is that $ga = b$. At the same time, since $g^{-1}$ exists, there's an element that can be written as $b' = g^{-1} a$. Then since $gb' = g g^{-1} a = a$, we have the following:

$$b' \xrightarrow{g} a \xrightarrow{g} b$$

Hence a path away from a vertex is always accompanied by a path toward the vertex. You can similarly convince yourself that the converse is true, that a path towards a vertex is always accompanied by a path away from the vertex.

These constraints on the paths that can be drawn between the vertices of a Cayley Graph are pretty restrictive and forces the graph to look symmetrical. Try it yourself: Start with 5 vertices, and try to draw paths that conform to these rules. (Challenge: Proof that any path you draw will always end up in a loop of 5 vertices).

Do note that the Cayley graph for a group might not look unique, and is highly dependent on the choice of generators.

## Rotation Groups

Say you start with a square and consider the set of rotations that fixes the position of the vertices.

<!--TODO: Hand drawn image-->

The rotations consist of rotating 0, 90, 180, 270 and 360 degrees. These rotations form a group, the cyclic group $C_4$, generated by 90 degree rotations. This is known as the _rotation group_ of a square. The Cayley Graph of this rotation group looks exactly like a square:

<div class="cayley-container">
<div id="plot5" class="cayley-uwu" style="width:calc(100% - 2em); height: 500px;"></div>
</div>

We can similarly talk about the rotation group of other shapes, like hexagons, which is the set of rotations that fixes the position of the vertices of the shape. These rotation groups are subgroups of the set of all 2D rotations $\mathrm{SO}(2)$, so a natural question is to ask "What are the finite subgroups of $\mathrm{SO}(2)$?".

It turns out that the finite subgroups of $\mathrm{SO}(2)$ describe the rotation groups of a regular $n$-gon, whose rotation group has the same structure as the cyclic group $C_n$, which shouldn't come as too surprising.

Similarly to the square example, the Cayley Graph of the rotation group of a regular $n$-gon does look like said $n$-gon.

Does this observation extend to 3D? To put it precisely, are the finite subgroups of $\mathrm{SO}(3)$ rotation groups of some 3D shape, and do the Cayley Graphs of these rotation groups resemble the underlying 3D shape? 

$\mathrm{SO}(2)$ is contained in $\mathrm{SO}(3)$, i.e., the set of 2D rotations can be found in the set of 3D rotations. So the finite subgroups of $\mathrm{SO}(3)$ would contain the cyclic groups $C_n$. In addition, $\mathrm{SO}(3)$ contains the _dihedral groups_ $D_n$, the set of rotations and reflections of a regular $2n$-gon. This is because we can perform a "flip" (or reflection) of a 2D shape by flipping it through the third dimension:

<!--TODO: Handdrawn diagram-->

However, these subgroups are kinda boring. They mostly take place in a single plane of existence (a 2D plane), and don't really 'fully utilise' 3D space.

It turns out there are **exactly** $3$ more finite subgroups of $\mathrm{SO}(3)$ that don't fit into any of the above categories. These are 

- $A_4$: the group of tetrahedral rotations
- $S_4$: the group of cube and octohedron rotations
- $A_5$: the group of icosahedral and dodecahedral rotations

<div class="cayley-container">
<div id="plot-rot-1" class="cayley-uwu" style="width:calc((100% - 0.5em)/3); height: 300px; border-right:0;"></div>
<div id="plot-rot-2" class="cayley-uwu" style="width:calc((100% - 0.5em)/3); height: 300px;"></div>
<div id="plot-rot-3" class="cayley-uwu" style="width:calc((100% - 0.5em)/3); height: 300px; border-left:0;"></div>
</div>


Note: The plots of the groups above look different from what you'll see on my [other site](https://juliapoo.github.io/Cayley-Graph-Plotting/). This is because I'm using a different set of generators. In particular:

- $A_4$: If the site used $(a,b,c)$, I used $(ca, b, c)$ here.
- $S_4$: If the site used $(a,b,c,d)$, I used $(a,db, dc, d)$ here.
- $A_5$: If the site used $(a,b)$, I used $(a^2, b)$ here.

These polyhedra for which the rotation groups describe the rotations of are precisely every convex regular polyhedra in 3D, or the [Platonic Solids](https://en.wikipedia.org/wiki/Platonic_solid) (thanks wikipedia). 

<center>
<img src="/assets/posts/2023-07-15-plotting-cayley-graphs/platonics.JPG">
</center>

In addition, [_duals_](https://en.wikipedia.org/wiki/Dual_polyhedron) (one replaces a polyhedra's vertices with faces to get its dual) share the same rotation group:

- The regular tetrahedron is its own dual
- The cube and octahedron are duals.
- The icosahedron and dodecahedron are duals.

Here's an animation by [@Toby Schachman](https://twitter.com/mandy3284) showing how an octahedron transforms into its dual (the cube):

{% capture code %}
<div style="display: flex; align-items:center; justify-content: center;">
<blockquote class="twitter-tweet" data-theme="dark" data-dnt="true" align="center" data-conversation="none"><p lang="en" dir="ltr">Here&#39;s an animation showing a cube transforming into an octahedron and back again. <a href="https://t.co/FuNWOQF61m">pic.twitter.com/FuNWOQF61m</a></p>&mdash; Toby Schachman (@mandy3284) <a href="https://twitter.com/mandy3284/status/1188842844879896577?ref_src=twsrc%5Etfw">October 28, 2019</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
</div>
{% endcapture %}
{{ code }}

The shape that happens in between the octahedron and the cube, is a _truncated octahedron_, which looks precisely like the Cayley Graph of $S_4$! Furthermore, the Cayley Graph of $A_4$ looks like a _truncated tetrahedron_. $A_5$ in particular exhibits both an icosahedron and dodecahedron simply by changing the lengths of the edges:

<div class="cayley-container">
<div id="plot-rot-6" class="cayley-uwu" style="width:calc(100% - 2em); height: 500px;"></div>
</div>

## Direct Products

Direct products are a method of constructing a larger group from two smaller groups, written as $A \times B$. You've likely came across direct products in some form: If $\mathbb{R}$ is the number line (say an $x$-axis), then $\mathbb{R}^2$ is the $xy$-plane. In this case, $\mathbb{R}^2$ is the direct product $\mathbb{R} \times \mathbb{R}$.

Direct products $A \times B$ can be thought of as creating a copy of $A$ for each element in $B$, and vice-versa ($A \times B$ = $B \times A$). In the axis-plane example above, we are duplicating the $x$-axis for each element of the $y$-axis, forming a plane. We represent an element in $A \times B$ as a tuple $(a,b) \in A \times B$ where $a \in A$ and $b \in B$.

Elements in $A \times B$ interact _component-wise_. For the case of groups, $A$ and $B$ are groups and $(a,b) \cdot (a', b') = (a \cdot a', b \cdot b')$, where the $\cdot$ in the right-hand side is the binary operator in the groups $A$ and $B$. You can try to convince yourself that $A \times B$ also forms a group.

The Cayley Graphs of direct products exhibit this intuition. For instance, the direct product of two cyclic groups $C_{10} \times C_{20}$

<div class="cayley-container">
<div id="plot-direct-1" class="cayley-uwu" style="width:calc(100% - 2em); height: 500px;"></div>
</div>

You get this glorious donut shape. Each $C_{10}$ (the smaller ring) is duplicated for each element of $C_{20}$ (the larger ring forming the donut). 

In a group $A \times B$, we have $(a', e) \cdot (a, b) = (a'a, b)$ where $e$ is the identity of $B$, we can think of multiplying by $(a', e)$ as traveling from the element $(a,b)$ to $(a'a, b)$. This can be seen as moving into a different element within the copy of $A$ associated with the element $b \in B$. However, we can also think of this from $B$'s perspective: We are traveling from the element $b$ within the copy of $B$ associated with the element $a \in A$, to the element $b$ within a _different_ copy of $B$ associated with the element $a'a \in A$. I.e., we've just changed "universe".

<!-- Handdrawn image of this teleportation of universes -->

## Semi-direct Products



<!-- 
1. Intro
2. What are groups and how are they symmetrical
2. What are Cayley Graphs and how do they showcase this symmetry
3. Rotation Groups
4. Direct Products
5. Semi-direct products
-->