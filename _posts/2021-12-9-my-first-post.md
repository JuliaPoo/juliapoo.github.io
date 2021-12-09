---
layout: post
author: JuliaPoo

display-title: Hello! This is my first post!
---

This is my first post! Am learning jekyll right now and so far it's been going great!

## A code block:

```python
from ski import *

S = lambda x: lambda y: lambda z: x(z)(y(z))
K = lambda x: lambda y: x
I = lambda x: x
A = lambda n: n+1
B = lambda n: n-1
Z = lambda f: (lambda g: f(g(g)))(lambda g: f(lambda y: g(g)(y)))

code = "[f:[x:f(f(x))]]"

ast = code_to_ski(code)
ast = compile_SKI(ast)
print(ast)

res = eval(f"{str(ast)}(lambda n: n+1)(0)")
print(res)
```

## Some Stuff

A list:

1. One
2. Two
3. Gun

