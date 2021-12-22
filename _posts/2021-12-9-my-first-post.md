---
layout: post
author: JuliaPoo
category: Misc

display-title: Hello! This is my first post!
tags:
    - first
  
nav: |
    * [A code block](#a-code-block)
        * [Some Stuff](#some-stuff)
        * [Another code block](#another-code-block)
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

* One
* Two
    * Two.one!
    * Two.two!
        * Two.two.one!
        * Two.two.two!
* Gun

<img src="/assets/img/alula-neon.svg" alt="drawing" style="width:200px;"/>

## Another code block


```python
# Some experimental code
# Not meant to be high quality, or efficient. 
# Just wanna try out some stuff out.
# Wanna try bringing the cancer of C pointers to python

from dataclasses import dataclass, field
from typing import Any, List, Union

from copy import deepcopy
from functools import reduce
from math import ceil, floor

@dataclass
class Pointer():
    obj:List[Any] = field(default_factory=lambda:[None])
    _id:int = 0
    def __post_init__(self): self._id = id(self)
    def get(self) -> Any: return self.obj[0]
    def set(self, obj:Any) -> None: self.obj[0] = obj; return self
    def __str__(self) -> str: return f"{self.obj[0]}*"
    def __repr__(self) -> str: return str(self)
    
REF = lambda x: Pointer().set(x)
SNNum = Pointer # Whatever

def SNNum_parse(s:List) -> SNNum:
    deref = lambda a: REF(a) if type(a)==int else SNNum_parse(a)
    return REF([*map(deref, s),])

def _SNNum_getOrder(n:SNNum, _acc:List) -> List[Pointer]:
    out = lambda a: _acc.append(a) if type(a.get())==int else _SNNum_getOrder(a, _acc)
    [*map(out, n.get())]
    return _acc

def SNNum_isPair(n:SNNum) -> bool:
    a,b = (*n.get(),)
    return type(a.get()) == int and type(b.get()) == int

def _SNNum_explode(pair:SNNum, order:List[Pointer]) -> None:
    
    a,b = (*pair.get(),)
    ai = order.index(a)
    
    if ai > 0:
        tmp = order[ai-1]
        tmp.set(tmp.get() + a.get())
    if ai+1 < len(order)-1:
        tmp = order[ai+2]
        tmp.set(tmp.get() + b.get())
    
    pair.set(0)
    order[ai:ai+2] = [pair]

def _SNNum_split(n:SNNum, order:List[Pointer]) -> None:
    c = n.get()
    a,b = floor(c/2), ceil(c/2)
    n.set([REF(a), REF(b)])
    ci = order.index(n)
    order[ci:ci+1] = n.get()
    
def _SNNum_reduce_explode(n:SNNum, order:List[Pointer], _depth=0) -> bool:
    
    is_pair = SNNum_isPair(n)
    if _depth >= 4 and is_pair:
        _SNNum_explode(n, order)
        return True
    
    ret = False
    for c in n.get():
        if type(c.get()) == int: continue
        ret |= _SNNum_reduce_explode(c, order, _depth+1)
    return ret

def _SNNum_reduce_split(n:SNNum, order:List[Pointer]) -> bool:
    
    if type(n.get()) == int:
        if n.get() >= 10:
            _SNNum_split(n, order)
            return True
        return False
    
    for c in n.get():
        if _SNNum_reduce_split(c, order):
            return True
        
def _SNNum_reduce(n:SNNum, order:List[Pointer]) -> bool:
    
    if _SNNum_reduce_explode(n, order): return True
    if _SNNum_reduce_split(n, order): return True
    
    return False

def SNNum_add(a:SNNum, b:SNNum) -> SNNum:
    
    a,b = deepcopy(a), deepcopy(b)
    c = REF([a,b])
    order = _SNNum_getOrder(c, [])
    while _SNNum_reduce(c, order):
        pass
    return c

def SNNum_getMagnitude(n:SNNum) -> int:
    if type(n.get()) == int: return n.get()
    a,b = (*map(SNNum_getMagnitude, n.get()),)
    return 3*a + 2*b


eqns = [*map(eval, open("18"))]
eqns = [*map(SNNum_parse, eqns)]

res = reduce(SNNum_add, eqns[1:], eqns[0])
ans1 = SNNum_getMagnitude(res)

ans2 = -1
for ai,a in enumerate(eqns):
    print(ai, end="\r")
    for bi,b in enumerate(eqns):
        if ai == bi: continue
        c = SNNum_add(a,b)
        m = SNNum_getMagnitude(c)
        if ans2 < m: ans2 = m

ans1, ans2
```


Inline `stuff`.