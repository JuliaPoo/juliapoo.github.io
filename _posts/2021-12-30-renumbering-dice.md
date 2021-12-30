---
layout: post
author: JuliaPoo
category: Unlisted #Mathematics

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
3. Solving problem 1
4. Dice renumbering problem 2
5. Generalised Number bases
6. Solving problem 2
-->

So a typical way of rolling dice is to take one or more dice, rolling and then summing their results. For instance, a common case is taking two 6-die, rolling them and summing the results.

In this example, you can get a $2$ by rolling $(1,1)$, up to a $12$ by rolling $(6,6)$.

However, the probabilities of getting a $2$ through $12$ aren't the same.

{% capture img %}
![two 6-die probabilities](/assets/posts/2021-12-30-renumbering-dice/2-6die.svg)
{% endcapture %}
<center>
{{ img | markdownify }}
</center>

Similarly, rolling more than two 6-die will result in a different probability distribution. For instance, here is three 6-dice:

{% capture img %}
![three 6-die probabilities](/assets/posts/2021-12-30-renumbering-dice/3-6die.svg)
{% endcapture %}
<center>
{{ img | markdownify }}
</center>

There's a generic method to compute this distribution. We could simply tally all possible rolls. For the case of rolling two 6-die, we have $6^2 = 36$ possibilities, each of equal probability. For each possibility, we can find the sum of the results and construct a table as follows:

{% capture tab %}
|<!-- -->|<!-- -->|<!-- -->|<!-- -->|<!-- -->|<!-- -->|<!-- -->|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
||<span class="glow-text">1</span>|<span class="glow-text">2</span>|<span class="glow-text">3</span>|<span class="glow-text">4</span>|<span class="glow-text">5</span>|<span class="glow-text">6</span>|
|<span class="glow-text">1</span>|2|3|4|5|6|7|
|<span class="glow-text">2</span>|3|4|5|6|7|8|
|<span class="glow-text">3</span>|4|5|6|7|8|9|
|<span class="glow-text">4</span>|5|6|7|8|9|10|
|<span class="glow-text">5</span>|6|7|8|9|10|11|
|<span class="glow-text">6</span>|7|8|9|10|11|12|
{% endcapture %}

<center class="table-no-outline table-scrollx">
{{ tab | markdownify }}
</center>

This is rem


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