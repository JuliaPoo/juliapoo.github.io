---
layout: default
title: About
---

# Hello!

This is a test markdown page

## Here's a header 2!

Here's a sample code block!

```python
def beta_eta_reduce(expr:SKInode_T, max_depth:int=500, raise_error=True, \
    _ctx:set=set(), _depth:int=0) -> SKInode_T:

    if _depth == max_depth:
        if raise_error:
            raise Exception("`beta_eta_reduce` Max depth `%d` reached"%max_depth)
        return expr
    _depth += 1

    if type(expr) == str:
        if expr in ATOMS and expr not in _ctx:
            return code_to_ski(ATOMS[expr])
        return expr

    # Shortforms
    B = lambda e,_c,_d: beta_eta_reduce(e, max_depth, raise_error, _c, _d)
    N, C, D = SKInode, NodeType.CALL, NodeType.DECL

    t = expr.node_type
    c1,c2 = expr.childs

    if t == C:

        c2 = B(c2, _ctx, _depth)
        if type(c1) == N and \
            c1.node_type == D:
            n,fn = c1.childs
            (_ctx := _ctx.copy()).add(n)
            return B(sub(fn, n, c2, _ctx), _ctx, _depth)

        if type(c1) == str:
            if c1 in 'SKI' and c1 not in _ctx:
                c1 = code_to_ski(ATOMS[c1])
                return B(N(t, (c1,c2)), _ctx, _depth)
            return N(t, (c1,c2))

        c1 = B(c1, _ctx, _depth)
        if (type(c1) == N and \
            c1.node_type == D):
            return B(N(t, (c1,c2)), _ctx, _depth)

        return N(t,(c1,c2))

    if t == D:

        if type(c2) != str and \
            c2.node_type == C:
            d1,d2 = c2.childs
            if d2 == c1 and not is_free(d1, c1):
                return B(d1, _ctx, _depth)

        (_ctx := _ctx.copy()).add(c1)
        c2 = B(c2, _ctx, _depth)
        return N(t, (c1, c2))

    raise Exception("Unexpected NodeType!")
```