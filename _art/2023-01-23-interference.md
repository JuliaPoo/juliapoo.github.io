---
layout: art-writeup
author: JuliaPoo
category: Generative

display-title: Interference
excerpt: Exploiting pixel aliasing during image resizing to make shapes and 3D objects appear via Moiré patterns.

preview-url: /assets/art/2023-01-23-interference/cube-preview.jpg

gallery:

    - url: /assets/art/2023-01-23-interference/uwu-crop.webm
      alt: "Moiré patterns that uwu in 3D"
      desc: "Moiré patterns that `uwu` in **3D**"
      type: video/webm
      preview-url: /assets/art/2023-01-23-interference/uwu-preview.jpg

    - url: /assets/art/2023-01-23-interference/alula-crop.webm
      alt: "Moiré patterns that form my favourite character: Alula!"
      desc: "Moiré patterns that form my favourite character: Alula!"
      type: video/webm
      preview-url: /assets/art/2023-01-23-interference/alula-preview.jpg

    - url: /assets/art/2023-01-23-interference/sphere-crop.webm
      alt: "Moiré patterns that makes an actual SPHERE"
      desc: "Moiré patterns that makes an actual SPHERE"
      type: video/webm
      preview-url: /assets/art/2023-01-23-interference/sphere-preview.jpg

    - url: /assets/art/2023-01-23-interference/cube-crop.webm
      alt: "C U B E"
      desc: "C U B E"
      type: video/webm
      preview-url: /assets/art/2023-01-23-interference/cube-preview.jpg

    - url: /assets/art/2023-01-23-interference/vase-crop.webm
      alt: "The face-vase illusion in 3D"
      desc: "The face-vase illusion in 3D"
      type: video/webm
      preview-url: /assets/art/2023-01-23-interference/vase-preview.jpg

    - url: /assets/art/2023-01-23-interference/uwu-source.jpeg
      alt: Original image for the UWU
      desc: Original image for the UWU

    - url: /assets/art/2023-01-23-interference/alula-source.jpeg
      alt: Original image for the ALULA
      desc: Original image for the ALULA

    - url: /assets/art/2023-01-23-interference/sphere-source.jpeg
      alt: Original image for the SPHERE
      desc: Original image for the SPHERE

    - url: /assets/art/2023-01-23-interference/cube-source.jpeg
      alt: Original image for the CUBE
      desc: Original image for the CUBE

    - url: /assets/art/2023-01-23-interference/vase-source.jpeg
      alt: Original image for the VASE
      desc: Original image for the VASE

    - url: /assets/art/2023-01-23-interference/prototype.webm
      alt: "A prototype I hastily wrote at 2am upon being hit with this idea"
      desc: "A prototype I hastily wrote at 2am upon being hit with this idea"
      type: video/webm
      preview-url: /assets/art/2023-01-23-interference/prototype-preview.jpg

tags:
    - generative
    - moire-patterns
---

## Meta

These videos are formed by something called [Moire Patterns](https://en.wikipedia.org/wiki/Moir%C3%A9_pattern), where I've exploited the regularity in artifacts created via pixel aliasing during image resizing to form a sorta "second pattern" over the pattern that's already present in the image. The _interference_ between these two patterns reveals the hidden object. Moire patterns, as I've used here, is able to reveal, in some sense, a 3D depth map of the first pattern, allowing me to "render" 3D objects.

I WILL WRITE A FOLLOW UP POST ON THE MATH BEHIND THIS BECAUSE IT IS VERY INTRIGING.

## Code

- [Unorganised Jupyter Notebook](/assets/art/2023-01-23-interference/Moire Pattern - Distance Functions.ipynb)