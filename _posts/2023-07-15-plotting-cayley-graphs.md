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

        plot(document.getElementById("plot1"), "60_5")
        plot(document.getElementById("plot2"), "5_1")

        let plt, linkforcectx;

        let [_gmat, _fp] = matrep["60_5"];
        let _G = create_group(_gmat, _fp);
        let _Ggens = _G.gens;
        _Ggens[0] = _Ggens[0].mul(_Ggens[0]);
        const G1 = new Group(_Ggens.map((g) => g.mat));
        plot2(document.getElementById("plot-rot-1"), G1, "60_5");

        [_gmat, _fp] = matrep["24_12"];
        _G = create_group(_gmat, _fp);
        _Ggens = _G.gens;
        _Ggens[2] = _Ggens[3].mul(_Ggens[2]);
        _Ggens[1] = _Ggens[3].mul(_Ggens[1]);
        const G2 = new Group(_Ggens.map((g) => g.mat));
        plt = plot2(document.getElementById("plot-rot-2"), G2, "24_12");
        linkforcectx = plt.d3Force('link');
        linkforcectx.distance(d => [300,60,0,60][d.group]);
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

In short, Cayley Graphs are [graphs](https://en.wikipedia.org/wiki/Graph_(discrete_mathematics)) (and by that I mean a bunch of nodes connected by lines) that encode, rather inefficiently, the abstract structure of a [_Group_](https://en.wikipedia.org/wiki/Group_(mathematics)).

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
> Note that we do not require $a \cdot b = b \cdot a$. This property of being able to "switch" the order of arguments is called _Abelian_.
>
> If a group $G$ has a finite number of elements, I'll call it a _finite group_. Otherwise, it's an _infinite group_.
>
> For brevity I would sometimes omit the $\cdot$, so $a \cdot b$ might be written as simply $ab$.

This description can apply to a whole bunch of things. A classic example is the integers $\mathbb{Z}$ and the operations $+$. For any integers $a,b,c$, we have:

1. $(a + b) + c = a + (b + c)$
2. $0 + a = a + 0 = a$
3. $a + (-a) = (-a) + a = 0$

Of course, in this example, $\mathbb{Z}$ is abelian as $a + b = b + a$. There are however groups where this doesn't hold. If you've played Zelda Tears of the Kingdom, you'd have encountered such a group when rotating an object. 

<div style="display: flex; align-items:center; justify-content: center;">
<iframe style="border:none;" width="550" height="400" data-tweet-url="https://twitter.com/chessapigbay/status/1658711763960086529" src="data:text/html;charset=utf-8,%3Cblockquote%20class%3D%22twitter-tweet%22%3E%3Cp%20lang%3D%22en%22%20dir%3D%22ltr%22%3EIn%20Zelda%20Tears%20of%20the%20kingdom%2C%20you%20can%20only%20rotate%20vertically%20and%20horizontally%20by%2045%B0.%20Here%26%2339%3Bs%20a%20tip%20for%20rotating%20around%20the%20third%20axis%3A%20Rotate%20all%20four%20directions%2C%20in%20order%2C%20for%20a%2045%B0%20rotation%3Cbr%3E%3Cbr%3E%u2192%u2193%u2190%u2191%20%3D%20%u21BA%3Cbr%3E%u2192%u2191%u2190%u2193%20%3D%20%u21BB%3Cbr%3E%3Cbr%3EThis%20happens%20because%20of%20some%20pretty%20neat%20math%20%3Cbr%3E%3Cbr%3E1/%uD83E%uDDF5%20%3Ca%20href%3D%22https%3A//t.co/H64RnTcCnf%22%3Epic.twitter.com/H64RnTcCnf%3C/a%3E%3C/p%3E%26mdash%3B%20chessapig%20%28@chessapigbay%29%20%3Ca%20href%3D%22https%3A//twitter.com/chessapigbay/status/1658711763960086529%3Fref_src%3Dtwsrc%255Etfw%22%3EMay%2017%2C%202023%3C/a%3E%3C/blockquote%3E%0A%3Cscript%20async%20src%3D%22https%3A//platform.twitter.com/widgets.js%22%20charset%3D%22utf-8%22%3E%3C/script%3E%0A"></iframe>
</div>

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

This group $G$ is a _subgroup_ (i.e., a subset that also forms a group) of an infinite group known as $SO(3)$, the set of all possible 3D rotations. We'll be encountering finite subgroups of $SO(3)$ later in this post because they have particularly interesting Cayley graphs.

In this case, every element of $G$ is some combination of $→$ and $↓$ and their inverses. We say that $G$ is _generated_ by the elements $→$ and $↓$.

In general, we can always find a subset of any group $G$ that generates $G$. It's clear that finite groups have finite sets of generators. However, some infinite groups have finite sets of generators too, for instance, $\mathbb{Z}$ is generated by $1$.

## What's a group's Cayley Graph?

Let's suppose a group $G$ is generated by three elements $a,b,c \in G$. Every element of $g$ can be written as a combination of $a,b,c$, for instance, $g = abbc$. Note that because of associativity I can omit the brackets. We can think of "reaching" $g$ from $e$ via successive applications of left multiplication by $a,b,c$:

$$
e \xrightarrow{c} c \xrightarrow{b} bc \xrightarrow{b} bbc \xrightarrow{a} abbc
$$

Every element of $G$ can be thought of as a "path" from $e$, where each step involves taking one of the paths, $a,b$ or $c$. Of course, this path would be dependent on the choice of the set of generators $a,b,c$. Note that this "path" description of elements in a group $G$ only makes sense because of the associativity of the binary operation.

In finite groups, a path will eventually lead back to an element that has already been encountered. For instance, in a group $C_5$, there exists a single generator $g \in C_5$ such that $C_5 = \{e, g^1, g^2, g^3, g^4\}$. In this case, every path has to loop back to the identity $e$:

$$
e \xrightarrow{g} g^1 \xrightarrow{g} g^2 \xrightarrow{g} g^3 \xrightarrow{g} g^4 \xrightarrow{g} e
$$

<div class="cayley-container">
<div id="plot2" class="cayley-uwu" style="width:calc(100% - 2em); height: 500px;"></div>
</div>

This "looping" behaviour is why $C_5$ is called a _cyclic group_.

Now suppose we have multiple 


## Why are Cayley Graphs so _symmetrical_?

## Rotation Groups

<div class="cayley-container">
<div id="plot-rot-1" class="cayley-uwu" style="width:calc(100% - 2em); height: 500px;"></div>
</div>

<div class="cayley-container">
<div id="plot-rot-2" class="cayley-uwu" style="width:calc(100% - 2em); height: 500px;"></div>
</div>

<!-- 
1. Intro
2. What are groups and how are they symmetrical
2. What are Cayley Graphs and how do they showcase this symmetry
3. Rotation Groups
4. Direct Products
5. Semi-direct products
-->