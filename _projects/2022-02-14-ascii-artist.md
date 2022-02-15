---
layout: project-writeup
author: JuliaPoo

display-title: "Ascii Artist"
display-image: "/assets/projects/2022-02-14-ascii-artist/bluetit-demo.jpg"
tags:
    - ascii-art
    - machine-learning
    - python

excerpt: "An ascii art generator that's actually good. Does edge detection and selects the most appropriate characters."
---

## Links

* [Github](https://github.com/JuliaPoo/AsciiArtist)
* [Pypi](https://pypi.org/project/asciiartist/)

<style>
@keyframes huerot {
    0% {
        -webkit-filter: hue-rotate(0deg);
    }

    50% {
        -webkit-filter: hue-rotate(180deg);
    }

    100% {
        -webkit-filter: hue-rotate(0deg);
    }
}
#jelly {
    font-family: monospace;
    white-space: pre;
    line-height: 1.4em;
    font-size: calc(min(16px, 1.6vw));
    text-shadow: 
        0 0 0.60em rgba(245, 83, 237, 1.6), 
        0 0 1.20em rgba(245, 83, 237, 1.3), 
        0 0 1.80em rgba(245, 83, 237, 0.8), 
        0 0 2.30em rgba(245, 83, 237, 0.6), 
        0 0 2.90em rgba(245, 83, 237, 0.3), 
        0 0 3.50em rgba(245, 83, 237, 0.2); 
    overflow: auto;
    animation: 6s infinite huerot;
}
</style>

<center>
<pre id="jelly">
{% raw %}
                                         ___.=-------9-e===,.L___                        
                                  _.&gt;z*```     [   7`(   '`     `"^r~~__                 
                                ~*20{%/_/     x)   /(          7L  . `{*^&lt;_              
                              _z%7`~``_^_y  ^ `/  7 '   _n   _ '`  n`  \\ )\.            
                            ,,,{^  f//|2_( /)x_  _`_\z= M._  {\  }L.t__  \ L[^_          
                          _&lt;//\` `)@'"/ / PKL . _` / _/\ _%V'] L  '\(|V h \^~(_\         
                          `)/v7 _'[,_` / /  " _ U _ v   o/   ) \ [  /@U  N . (M(@,       
                       _ _y`//_k(y_/U-((_`  L y \-/ [ .~   &gt; __V/ _  v   \ \__\[`X(      
                      _/_(   &gt;`             "/      [&lt;`   ``   `\ `   _   &gt;~  \{`/M\     
                      `y`                                             `v     L L\[\_\    
                    _(                                                       \`  [ \(,   
                    V                                                        *     ?     
                    |`&gt;,,=~^~,{`,,__, ,,-`&gt;.Y_  _  _, _vy         _                  My  
                    \/Y.[&gt;;(./ ```j` [/ `j` `*\@``*j7`\_O)*`{ e==~^} --L              \  
                     `[_M\, . *L   `_\`         ``                  \_ '*~H.,-&gt;        U 
                     _  ````\"')(o_ y(_.               _   _          `````7;^\L,,=    U 
                    _/`          ``%\~(F               |\z_[_         .o,._]` }-_&lt;``\_   
                   _/              V`     .~          _"-%) `        , O~\_]_\)'f?`*{`   
                  _(                      `            \`            `\.    `'           
                  /(                                                                     
                  U                      (K_                         D                   
                  `                      [` ``                   U^L(                    
                   (                    7\\              ,/                              
                   \\                   \    -, __      __\?                             
                    \L                   `/   )v&lt;_     ([`       V                       
                     `(                    - `  '`             _                         
                       (                    `,_.      (        _                         
                       ]                 /  /(S_      _`      /                          
                       /                      `V      `\     `'_                         
                      y`                / /     _       \                                
                     _`          _/  _.* _`  _.  ^ _     `_    ]                         
                    _/           }[  ` _ }  _O      /    ``;   ]      .                  
                    /            _[  , M                  ^'U  }   \_\                   
                   _(             [``\ U               Y       |                         
                   /              [    {         /   ,/ _U     {                         
                  _(              ML   U        _` \ |  `-             _                 
                 _(                \   ]       _/  `j`__.`           _ |                 
                 O(     _           \  \       _ _    ]                `                 
                 J       (          \  [ _,s._,)``=v  ]                                  
                 "       `\          M [ (  [``__``   \               (_                 
                 [         \( _/     OL]  \_    `u6   _L        ,    v w                 
                 'O         `"`       (]   f      .  n_          (   (                   
                  ^,                  J/    `~_/V `    ,         "                       
                   "k          ,       (    _fpxU     L`     U    _*                     
                  _  "kLL_yHy`MOO          yKj\ **j`  U `.   /                           
                 _)`'=6f:f7(` `  '\co   V y`  /   /   ][           `                     
                ./[q`   _ `*\ _      L  | [_  `/     \\   \_/   _ `                      
              ,{){    _``&gt;~,_``     n\  ]  `\  O    _v     _  \@(                        
              VC,_QjcS,[_n.-) k=&gt;^&gt; \     \ _V__   ,7)     _  {\                         
               ```\_),[?(@)= [O7` __Nk^r6`\;&__&lt;`   )/     }  [_                         
                    `*``  ````)&gt;, `'  `     /^"[~_ \_`     \K&lt;`"                         
                             _(               H[_`` V        [_ L                        
                        ,*'n}``L               \(. _`        ./_`,                       
                       y~               __,L-L_ {*_`     \~  k)/ \                       
                     L_j`          _,~``  ^`  &gt;(\\(    ~  [J/ 7`                         
                     [````   _7_v'?       _  /  \ `     `_( _^ /                         
                    _V__    z&gt;`   (      _/    _`  `~_ Or`_/\~.`     _                   
                   0{--    /7    /    7F` \   M(      (`^`_&lt;`_/  __/ `                   
                   .Ho)         _( ___[   |  ,M`    `y^67'` _y   _`                      
                   }      [[    y  _V     /_y(/K_   (/``   ,/  , `                       
                   )V     _[   /_.-``    ,O/`/   )/^*`     /``                           
                    Px_  L (L_(_(`    &gt;-^`  /7)&lt;J`        ``                             
                      ``'/@)}` // _,~(  _ ,__/`                                          
                         .wy[/_ /kkK___z{/k`                                             
                       _zN  &lt;dj`G`J~-C&lt;'2^            _/                                 
                      .`x\   ``  _,/``_/      _      _(                                  
             _ _vo.,_&gt;(       ,~`    _(   _,&gt;^`     y`                                   
         _ ,{y_{}H)\L  _ \ .~Lf     _(  ,z`       _7`                                    
         )}{_    ``~(\&lt;L_ /         M )^`        _(                                      
         ``/@&lt;_      `_ [           \/`         y`                                       
       (~yO%}{`(:&lt;' .^` \V          .          y`                                        
        D[{/    `- (   __(          "                                                    
       _\/`           _(y/           !                                                   
      _/7             /[`                                                                
      ?/              M/                                                                 
     (,   /          _)(                                                                 
     _`  /           VL\                                                                 
   _`(   (                                                                               
  z\`   M                                                                                
  Vh    [                                                                                
 ]t__   {                                                                                
 `*fP7j:*~=,~_                                                                           
        )`  `/                                                                           
         \ //                                                                            
          {{L                                                                            
          'U\                                                                            
            K~_                                                                          
           _  `*\                                                                        
           [                                                                             
           ]                                                                             
           (                                                                             
          _`                                                                             
{% endraw %}
</pre>
<center>