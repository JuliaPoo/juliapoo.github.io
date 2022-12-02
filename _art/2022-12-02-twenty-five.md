---
layout: art-writeup
author: JuliaPoo
category: Generative

display-title: Twenty Five
excerpt: A visualisation of a simple finite automata from Advent Of Code 2021 Day 25

preview-url: /assets/art/2022-12-02-twenty-five/final2-browser-300-trim-com.gif

gallery:

    - url: /assets/art/2022-12-02-twenty-five/final2-browser-512.mp4
      alt: Video of the full reaction
      desc: Video of the full reaction
      type: video/mp4
      preview-url: /assets/art/2022-12-02-twenty-five/preview.png

tags:
    - generative
    - finite-automata
---

## Code

```py
import taichi as ti
import numpy as np

ti.init(arch=ti.gpu)

arr = (np.random.rand(512, 512)*4).astype(int)
arr[arr >= 3] = 0

x,y = arr.shape
sea = ti.field(dtype=ti.types.i8, shape=(x, y))
bak = ti.field(dtype=ti.types.i8, shape=(x, y))
sea.from_numpy(arr)
bak.copy_from(sea)

@ti.kernel
def forward2():
    for i, j in sea:
        ii = (i+1)%x
        if sea[i,j] == 2 and sea[ii,j] == 0:
            bak[i,j] = 0
            bak[ii,j] = 2
     
@ti.kernel
def forward1():
    for i, j in sea:
        jj = (j+1)%y
        if sea[i,j] == 1 and sea[i,jj] == 0:
            bak[i,j] = 0
            bak[i,jj] = 1

gui = ti.GUI("Sea", res=(x, y))
cnt = []
while not gui.get_event(ti.GUI.ESCAPE, ti.GUI.EXIT):
    mask = sea.to_numpy()
    img = np.zeros((*mask.shape, 3), dtype=np.uint8)
    img[mask == 0] = [1, 21, 66]
    img[mask == 1] = [3, 255, 247]
    img[mask == 2] = [247, 116, 146]
    cnt.append(img)
    gui.set_image(img)
    gui.show()
    forward1()
    sea.copy_from(bak)
    forward2()
    sea.copy_from(bak)

video_manager = ti.tools.VideoManager(output_dir="./out", framerate=60, automatic_build=False, width=2*x, height=2*y)
for img in cnt:
    video_manager.write_frame(img)
video_manager.make_video(mp4=True)
```