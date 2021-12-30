---
layout: post
author: JuliaPoo
category: Mathematics

display-title: "Renumbering Dice"
tags:
    - math
    - combinatorics
    - polynomial-factoring
    - dice

nav: |
    * TODO
excerpt: "An exploration of multiple ways to describe rolling dice, and answering questions on re-numbering dice."
---

<!-- 
TODO:
1. Probability distribution of dice rolling
2. Polynomial way of looking at dice rolling.
3. Dice renumbering problem 1
4. Dice renumbering problem 2
4. Number bases
-->

So a typical way of rolling dice is to take one or more dice, rolling and then summing their results. For instance, a common case is taking two 6-die, rolling them and summing the results.

In this example, you can get a $2$ by rolling $(1,1)$, up to a $12$ by rolling $(6,6)$.




```python
from sympy.utilities.iterables import multiset_partitions
from collections import Counter
from typing import List

# Work in integer polynomials
x = PolynomialRing(ZZ, 'x').gen()

def dice(nsides:int) -> "PolynomialZZ":
    
    """Returns polynomial of a nsides-ed die"""
    
    return sum(x^i for i in range(nsides))

def get_numberings(nsides: List[int]) -> List[List[int]]:
    
    """
    Returns possible numberings of dice that
    give the same distribution as regular dice with sides `nsides`
    """
    
    # Target distribution
    target = reduce(lambda a,b: a*b, map(dice, nsides))

    # Factors of target distribution
    # Stored as [(factor, sum of coefficients), ...]
    tfactors = [(f,f(1)) for f,c in target.factor() for _ in range(c)]

    tsols = [] # Stores the possible numberings
    _ns = Counter(nsides)
    for ps in multiset_partitions(tfactors, len(nsides)):

        # Skip solutions where new dice don't have NSIDES sides
        ns = [reduce(lambda a,b:a*b[1], p, 1) for p in ps]
        if Counter(ns) != _ns:
            continue

        # Multiply factors together
        ps = [reduce(lambda a,b:a*b[0], p, 1) for p in ps]

        # Skip solutions with negative coefficients
        if min(min(p.coefficients()) for p in ps) < 0:
            continue

        # Convert polynomials to numberings
        tsols.append([
            [c+1 for c,n in p.dict().items() for _ in range(n)]
            for p in ps
        ])
        
    return tsols


nsides = [20,6]
tsols = get_numberings(nsides)

print("Possible Numberings:")
for t in tsols:
    print()
    for n,d in zip(nsides,t): 
        d = " ".join(f"{x:3}" for x in d)
        print(f"{n:2}-sides: {d}")
```