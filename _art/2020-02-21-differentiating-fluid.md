---
layout: art-writeup
author: JuliaPoo
category: Generative

display-title: Differentiating Fluid
excerpt: |
    By differentiating a fluid simulator, one can solve via gradient decent for the initial velocity field that brings a fluid from one configuration to another.

preview-url: /assets/art/2020-02-21-differentiating-fluid/fengshui.gif

gallery:

    - url: /assets/art/2020-02-21-differentiating-fluid/fengshui.gif
      alt: A fluid moving from the chinese characters feng to shui.
      desc: |
        A fluid moving from the chinese characters feng to shui.
tags:
    - generative
    - difftaichi
    - fluid
---

## Metadata

This 200x200 mini animation took 1hr to solve. It's a legit fluid simulator, and it solves for the velocity field that brings the first image to the next.

This was done with the amazing [DiffTaichi](https://github.com/taichi-dev/difftaichi), with one of the examples given by the authors.

The chinese words are 风水, meaning (from my understanding) fortune vibes, for lack of better terms.

## Code

I have determined the code to be too messy to be worth cleaning up and post.