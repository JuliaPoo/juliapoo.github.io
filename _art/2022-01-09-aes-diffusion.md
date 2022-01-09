---
layout: art-writeup
author: JuliaPoo
category: Generative

display-title: AES-128 Diffusion
excerpt: |
    Visualizations of the diffusion property of AES. Originally made to be displayed at the Seattle Universal Math Museum "For the Love of Math!" exhibition.

preview-url: /assets/art/2022-01-09-aes-diffusion/aes128-diffusion-9r-mod128.png

gallery:

    - url: /assets/art/2022-01-09-aes-diffusion/aes128-diffusion-9r-mod128.png
      alt: Plot of diffusion for round 0 to 8.
      desc: |
        Plot of diffusion for round 0 to 8. You can see the plot getting more and more random as the number of rounds increase.

    - url: /assets/art/2022-01-09-aes-diffusion/aes128-diffusion-9r-mod128-0.png
      alt: Plot of diffusion for round 0.
      desc: |
        Plot of diffusion for round 0.

    - url: /assets/art/2022-01-09-aes-diffusion/aes128-diffusion-9r-mod128-1.png
      alt: Plot of diffusion for round 1.
      desc: |
        Plot of diffusion for round 1.

    - url: /assets/art/2022-01-09-aes-diffusion/aes128-diffusion-9r-mod128-2.png
      alt: Plot of diffusion for round 2.
      desc: |
        Plot of diffusion for round 2.

    - url: /assets/art/2022-01-09-aes-diffusion/aes128-diffusion-9r-mod128-3.png
      alt: Plot of diffusion for round 3.
      desc: |
        Plot of diffusion for round 3.

    - url: /assets/art/2022-01-09-aes-diffusion/aes128-diffusion-9r-mod128-4.png
      alt: Plot of diffusion for round 4.
      desc: |
        Plot of diffusion for round 4.

    - url: /assets/art/2022-01-09-aes-diffusion/aes128-diffusion-9r-mod128-5.png
      alt: Plot of diffusion for round 5.
      desc: |
        Plot of diffusion for round 5.

    - url: /assets/art/2022-01-09-aes-diffusion/aes128-diffusion-9r-mod128-6.png
      alt: Plot of diffusion for round 6.
      desc: |
        Plot of diffusion for round 6.

    - url: /assets/art/2022-01-09-aes-diffusion/aes128-diffusion-9r-mod128-7.png
      alt: Plot of diffusion for round 7.
      desc: |
        Plot of diffusion for round 7.

    - url: /assets/art/2022-01-09-aes-diffusion/aes128-diffusion-9r-mod128-8.png
      alt: Plot of diffusion for round 8.
      desc: |
        Plot of diffusion for round 8.

    - url: /assets/art/2022-01-09-aes-diffusion/aes128-diffusion-9r-mod128-9.png
      alt: Plot of diffusion for round 9.
      desc: |
        Plot of diffusion for round 9.

    - url: /assets/art/2022-01-09-aes-diffusion/aes128-diffusion-9r-mod128-10.png
      alt: Plot of diffusion for round 10.
      desc: |
        Plot of diffusion for round 10.

tags:
    - generative
    - cryptography
    - aes128
    - diffusion
---

## Metadata

I made this originally to be displayed in the [Seattle Universal Math Museum](https://seattlemathmuseum.org/), <span style="color:plum">_"For the Love of Math!"_</span> exhibition curated by [Timea Tihanyi](https://www.timeatihanyi.com/), but for reasons I forgot I decided against it and submitted [MT19937](/art/2021-08-26-mt.html) instead.

I revisited this today and realised **wait hey this _is_ interesting**, and made the plots more visually appealing.

### What is AES?

So [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) is a symmetric-key encryption algorithm. It works by shuffling (unrigorous definition) the plaintext bits around to create the ciphertext. AES-128 is a specific instance of AES that works on $128$ bits of plaintext at a time, in order words, AES-128 has a 128-bit state.

AES is mostly linear in $GF(2)$. It consists of multiple rounds of the following operations:

1. Substitute
2. Shift
3. Mix
4. Add round key

In particular, steps 2-4 are linear operations, and can be represented as a matrix. Step 1 (`Substitute`) however, isn't linear, and _cannot_ be represented as a matrix. Needless to say, the `Substitute` step is one of the biggest reasons that AES is so hard to break.

### What am I plotting?

Each plot represents the _"dependencies"_ of each input bit at each round of AES. The plot for round 0 is the identity matrix, as each bit only _depends_ on itself.

At subsequent rounds, the _"dependencies"_ of each output bit becomes entangled with more and more input bits, resulting in a random plot at the later rounds. This is known as [_diffusion_](https://en.wikipedia.org/wiki/Confusion_and_diffusion), and is very important in cryptography.

The `Substitute` operation is dealt probabilistically, as for a given $n$-th bit, even knowing its value before `Substutite`, can result in both $0,1$ after `Substitute`, because this operation is done at the byte level. The `Substitute` operation is responsible for most of the _colour variations_ of this collection of images.

I also did other stuff that's not as faithful to the original AES-128 such as switching to the field $\mathbb{Z}$ in `gen_n_rounds` because it gives more visually interesting results. The final plots, however, are still faithful to what I'm trying to visualize.

## Code

Sage:

```python
from sage.all import *
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image

aes = mq.SR(10, 4, 4, 8, star=True, allow_zero_inversions=True)

F = aes.base_ring()
FP = PolynomialRing(F, 'k', 16)
key = FP.gens()
init_state = matrix(FP, [list(key[4*i:4*i+4]) for i in range(4)])

x = F.gens()[0]

def state_nth_bit(n:int):
    s = [list(i) for i in aes.state_array()]
    nb = n >> 3
    s[nb >> 2][nb & 3] = x^(n%8)
    return s

def flatten_aes_state(s):
    s = [j for i in s for j in list(i)]
    s = [i.polynomial().exponents() for i in s]
    s = [int(i in j) for j in s for i in range(8)]
    return s
    
def get_mix_mat_GF2():
    mats = []
    for i in range(16*8):
        mats.append(aes.mix_columns(state_nth_bit(i)))
    return matrix(ZZ, [flatten_aes_state(m) for m in mats]).T

sbox = aes.sbox()

def get_prob_bit(n:int):
    
    prob = [0]*8
    for i in range(0x100):
        if (i>>n) & 1 == 0:
            continue
        sb = sbox[i]
        for j in range(8):
            if (sb>>j) & 1:
                prob[j] += 1
                
    return prob

shuf = list(range(8))
def get_prob_bit(n:int):
    prob = [0]*8
    prob[shuf[n]] = 1
    return prob

def get_sub_mat_GF2():
    sub_mat = np.array([get_prob_bit(i) for i in range(8)], dtype=int)
    sub_mat = (sub_mat - sub_mat.min()) / (sub_mat.max() - sub_mat.min())
    sub_mat = matrix(ZZ, sub_mat.astype(int)).T
    return block_diagonal_matrix(*tuple([sub_mat]*16))

shift = matrix(ZZ, aes.shift_rows_matrix())
mix = get_mix_mat_GF2()
sub = get_sub_mat_GF2()
def gen_n_rounds(n:int):
    r1 = identity_matrix(ZZ, 128)
    for i in range(n):
        r1 = sub*r1
        r1 = shift*r1
        r1 = mix*r1
    return r1

n = 3
scale = 5
sz = 128*n*scale
cmap = plt.get_cmap('GnBu')

fimg = np.zeros((sz,sz,4), dtype=np.uint8)
for i in range(n*n):

    r1 = gen_n_rounds(i)
    y,x = i%n, i//n

    r1 = np.array(r1, dtype=float)
    r1 = (r1 - r1.min())/(r1.max() - r1.min())

    img = np.kron(r1, np.ones((scale,scale)))
    img = (cmap(img)*255).astype(np.uint8)
    
    fimg[
        128*scale*x:128*scale*(x+1),
        128*scale*y:128*scale*(y+1)
    ] = img
    
img = Image.fromarray(fimg)
img.save("dist/aes128-diffusion-9r-mod128.png")

for i in range(n*n):
    r1 = gen_n_rounds(i)

    r1 = np.array(r1, dtype=float)
    r1 = (r1 - r1.min())/(r1.max() - r1.min())

    img = np.kron(r1, np.ones((scale,scale)))
    img = (cmap(img)*255).astype(np.uint8)
    Image.fromarray(img).save(f"dist/aes128-diffusion-9r-mod128-{i}.png")
```