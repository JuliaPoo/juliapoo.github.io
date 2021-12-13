---
layout: post
author: JuliaPoo

display-title: Hello! This is my first post!

nav:
  - name: A code block
    level: 1
    permalink: #a-code-block
  - name: Some Stuff
    level: 2
    permalink: #some-stuff
  - name: Another code block
    level: 2
    permalink: #another-code-block
  
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

<img src="/assets/img/alula-neon.svg" alt="drawing" style="width:200px;"/>

## Another code block


```python
S = lambda x: lambda y: lambda z: x(z)(y(z))
K = lambda x: lambda y: x
I = lambda x: x
A = lambda n: n+1
Z = lambda f: (lambda g: f(g(g)))(lambda g: f(lambda y: g(g)(y)))

to_str = Z(lambda f: lambda l: "" if S(S(I)(K(1)))(K(0))(S(I)(K(K))(l)) else chr(S(S(I)(K(A)))(K(0))(S(K(S(I)(K(K))))(S(I)(K(K(I))))(l)))+f(S(K(S(I)(K(K(I)))))(S(I)(K(K(I))))(l)))

alula = \
                                                           S(
                                                        S      (I
                                                      )(         S
                                                      (          S(                                                                                                              I
                                                      )(   S(S  (I                                                                                )                          (S  (S(
                                                        I)(S(S(I                                                                              )( S(S                      (I)(S(S(I)(
                                                         S(S(I)(                                                                              S(S(I)(                     S(S(I)(S(S(I
                                          )(          S(S(I)(K(S(K          (S                                                              (S)(K(K))))                  (S(K(K))(S(K(S
                                         ) )          (S(K(S(I)))(K                                                                          ))))(K)(K)))                )(K(S(S(K(S))(K
                                         )            )(S(K(S(S(S(                                                                           K(S))(K)))))(K             )(S(S(K(S))(K))(I
                                               )         )(S(S(K         (                                                                     S))(K))(S(S(K(           S))(K))(S(S(K(S))
                                                 (K))(I)))))))))(K(S(K(                                                                        S(S(S(K(S))(K)))        ))(K)(S(S(K(S))(K))
                                           (S(K(S(S(S(K(S))(K )))))(K)(S(S(K(                                                                   S))(K))(S(S(K(S))(K)   )(I)))(I)))(I)))))(  K(S(K(S
                                       (S(I)(K(S(S(K(S)  )  (  K)))))))  (K)(S(K(                                                                 S(S(S(K(S))(K)))))(K)(S(S(K(S))(K))(S(S( K(S))(K))
                                    (I)) )(S(  S(K (S   ))  (   K  ))  (I    )))(S(K                                                                (S(S(S(K(S))(K)))))(K)(S(S(K(S))(K))(S(S(K(S)
                                 )(K   ))(    I)  ))   (S   (   S(   K   (S    ))(K ))(                                                               S(S(K(S))(K))(I))))))))(K(S(S(K(S))(K))(S(
                               S(K   (S)    )(   K)    )    (    S(   S(   K(     S)   )(K                                                              ))(S(S(K(S(S(I)(K(S(S(K(S))(K)))))))(K
                            ))(    S(     S(    K(    S)    )    (K    ))   )(      S(   S(K                                                                (S(S(I)(K(S(S(K(S))(K)))))))(K))(
                          S(S    (K      (S    ))     (     K     )     ))    (       S(   K(S                                                                  (S(S(K(S))(K)))))(K)(S(S(K(S)
                        )(K     ))      (S    (S     (K     (     S)     )     (K      ))    (I)                                                                   ))  (S(S(K(S))(K))(I)))))
                       ))     ))       )      )      (K     (      S      (     S(       K(    S(S                                                                       (I)(K(S(S(K(S))(K)
                     ))      ))       )      )       (      K      )      )(     S(       S(     K(                                                                     S))(K)))(S(S(K(S(
                    S(      I        )      (K       (      S      (S      (      K(       S)     )(K                                                           )))))))(K))(S(S(K(S))(
                  K)      ))        (       S       (K      (      S(       S      (S        (      K(                                                        S))(K)))))(K)(S(S(K(
                 S)      )(        K       ))       (       S       (       S(      K         (      S)                                                       )(K))(I)))(S(S(K(
                S)      )(        K)       )        (       I       )        )       )         )      ))                                                     ))(K(S(S(K(S(S(I)(K
               (S      (S         (       K(        S       )       )(       K)       )         )       ))                                                    ))(K))(S(S(K(S))(K
              ))      )(         S        (        S(       K       (S        (       S(         I       )(                                                  K(S(S(K(S))(K))))
             ))       )         (        K)        )(       S        (        S        (         K(       S)                                                  )(K)))(S(S(K(S))
            (K       )          )        (         S        (        S        (K        (         S)       )                                                  (K))(S(K(S(S
           (S       (K         (         S         )        )        (         K        )          )        )                                                   ))(K
          )(        S          (        S(         K        (        S         )         )         (K       ))
         (S        (          S         (          K        (        S)        )(        K          )        )(
         I)       ))          (         S         (S        (        K(         S         )          )        (K
        ))        (          I         ))         ))        )        ))         )         )          )(       K(
        S        (K          (         S(         S         (         S         (          K          (        S)
       )(        K          ))         )          )         )         (         K)         (          S         (
       S        (K          (          S          )         )         (         K)         )          (I        ))
      (S        (           S          (          K         (         S          )          )          (        K)
      )         (           S         (S          (         K         (          S          )          )         (K
     ))        (S          (          S(          K         (         S          )          )          (K        ))
     (I        ))          )          ))          )         )         )          (K         (           S         (
     S         (           K          (           S         (         S          (I          )          (         K
     (         S           (          S          (K         (         S          ))          (          K         ))
    ))         )           )          )          (K         )         )          (S          (          S(        K(
    S)         )           (          K          ))         )         (          S(          S          (K        (S
    (S         (           I          )          (K         (         S          (S          (          K(        S)
    )(         K           )          )          ))         )         )          )(          K          ))        (S
    (S        (K          (S         ))( K)))(S(K(S(S(S(K(S))(K)))))(K)(S(S(K(S) )(          K          ))        (S
    (S(K(S))(K))          (I          )          ))         (         S          (S          (          K(S))(K))(I)
    ))        )))))(K(S(K(S(S(I)(K(S(S(K(S       ))        (K)        ))      ))))(K)(S( K(S(S(S(K(S))(K))        ))
    )(         K           )          (          S(         S         (          K(          S          )         )(
    K)         )           (          S          (S         (         K(         S)          )          (K        ))
    (I         )           )          )          (S         (         S                                 (K        (S
    ))         (           K          )          )(         I         )                                 ))        (S
    (K         (           S          (          S(         S         (                                 K(        S)          )(
    K)         )           )          )          )(         K         )                                 (S        (S          (K         (S
    ))         (           K          )          )(         S         (                                 S(        K(          S)         )(
    K)         )           (          I          ))         )         (                                 S(        S(          K(         S)
    )(         K           )          )          (S         (         S                                 (K        (S          ))         (K
    ))         (           I          )          ))         )         )                                 ))        )(          K(         S(
    K(         S           (          S          (I         )         (                                 K(        S(          S(         K(
    S)         )           (          K          ))         )         )                                 )))(K)(S(K(S(         S(         S(
    K(         S           )          )          (K         )         )                                 )))(      K)          (S(        S(
    K(         S           )          )          (K         )         )                                 (S      (S(K(          S       ))(K
    ))         (           I          )          ))         (         S                                 (S        (K          (S))( K)) (I)
    ))         (           S          (          K(         S         (                                 S(        S(           K         (S
    ))         (           K          )          ))         )         )                                 (K        )(           S         (S
    (K         (           S          )          )(         K         )                                 )(        S(           S         (K
    (S         )           )          (          K)         )         (                                 I)        ))           (         S(
    S(         K           (          S          ))         (         K                                 ))        (S           (         S(
    K(         S           )          )          (K         )         )                                 (I        ))           )         ))
    ))         )           (          K          (S         (         S                                 (K        (S           )         )(
    K)         )           (          S          (K         (         S          (S          (          S         (K           (         S)
    )(         K           )          )          ))         )         (          K           )          (         S(           S         (K
    (S         )           )          (          K)         )         (          S           (          K         (S
    (S        (S(         K(S        ))(        K))        ))        )(K        )(S         (S(        K(S        ))
    (K        ))(         S(         S(         K(S         )         )         (K)         )(         I))        )(
 I)))(I))))))(K(S(K(S(S(I)(K(S(S(K(S))(K)))))))(K)(S(K(S(S(S(K(S))(K)))))(K)(S(S(K(S))(K))(I))(S(S(K(S))(K))(I)))(S(K(S(
S(S(K(S))(K)))))(K)(S(S(K(S))(K))(S(S(K(S))(K))(S(S(K(S))(K))(I))))(S(S(K(S))(K))(I)))))(S(K(S(K(S(K(S(S)(K(K))))(S(K(K)
 )(S(K(S))(S(K(S(I)))(K))))(K(I))))))(S(K(S(S)(K(S(K(K))(S(K(S))(S(K(S(I)))(K)))))))(S(K(K))(S(K(S(S(S)(K(K)))))(K)))))

print(to_str(alula))
```

Inline `stuff`.