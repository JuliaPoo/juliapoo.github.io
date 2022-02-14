---
layout: post
author: JuliaPoo
category: Misc

display-title: "The Math of Happiness"
tags:
    - math
    - nonsense

nav: |
    * TODO
    
excerpt: A nonsense analysis of the ups and downs of life, complete with hand wavy econ-style mathematics and shitty references to nuanced concepts that do not have its fair treatment here.
---

<!--
f be the perceived fortune. f' be the level of happiness. f'' (change in happiness). 

Expectation is e = f'' + k*f', where k is the level of optimism.

f is influenced external stimuli c(t). c is the 'average' perceived fortune of a person in the same position, meant to be independent of f.

f differs from c because of latent satisfaction (l) and expectations.  

f = c + l - r*e, where r is resignation. (minus cuz expections lead to disappointment).

f is in fort. f' in fort/s, f'' in fort/s^2. k in 1/s. l in fortune. r in s^2

==> f(t) = c(t) + l + r*(f''(t) + kf'(t))
-->

<style>

#nikoooo {
    font-family: consolas;
    line-height: 1.2em;
    font-size: calc(min(1vw, 10px));
    text-shadow: 
        0 0 0.60em rgba(245, 83, 237, 1), 
        0 0 1.20em rgba(245, 83, 237, 0.7), 
        0 0 1.80em rgba(245, 83, 237, 0.5), 
        0 0 2.30em rgba(245, 83, 237, 0.3), 
        0 0 2.90em rgba(245, 83, 237, 0.2), 
        0 0 3.50em rgba(245, 83, 237, 0.1); 
}

</style>

{% raw %}
<center>
<strong>
<pre id="nikoooo">
                                        _/``<_                                                                                      
                                      _/`    `~_                                                                                    
                                     _/   {    `\                                                                                   
                                    _/    [      *_                                                                                 
                                   _/     O        \_                                                                               
               ___                _:      \         `\                                                                              
               ]  `^>__       _~^`         \          `                                                                             
               ]       ``-=v*`              \   _      _                                                                            
               O         _@                  `<_ \_    [                                                                            
               V        _@          ,           ```    ' '```F-~L__                                                                 
                [       /`          *>_              ____   *'^``- ^                                                                
                Y       L                   ___U_I`C  ;/  __==:`                   _____                                            
                 {      OL           _Uc7```"@     [ :( ,/` .^        _____-><^'`````'`^-C_-~__                                     
                 'L     '{,     _,_@F@ /`_:``\[    4 `-7`.___U_  ___o@-{____I_```````~--,=-,[E,C_~__                                
                  `L       __-_-@'`  4_`^-'_' "_   [ `[_:*`C_-/OC_I-~---,-,___ [``F--,_'**-C__  ``*E`_<_                            
                    O   __<C/'`/{>__ V ,   \_| O   O  [`  `'='                [``'`F--=-I__  ```>~_ _`~}`^<_                        
                  _/  _V-*`'C  _7L*\`-``\,___ '[    ,* /  _'  ``c*F-,..,,___                     `~[` `*`~`<`\_                     
                 _'__C*[L  (`\_O `L|           @ _'*  ;   /              ```"*`^~__                 `\__     `~`\_                  
                 /_`` (_@__ \_ *L_,/  ,C@^   _>}_:`  /   /  ~__                    ``v__                \(_      `,                 
                .->-c'`  [C@_OLC>L__    __U-4C/":   _`  :      `*<_              L_     `\L               `~      ',                
                          `[_-*`>>C`````C  _/`_'   _/ _/           `>L_          ( `<_     `>__             \_     )_               
                              __  `'^\ ]__/`_O*    !_ `               `>L         L   >_      `>L        _    L     \_              
                 _~             ``\~_  '#{ _*_       /                   `_       \_    \_       `\_     `{   (      V              
              _<`             _,     `<_O{/`;`_,~ c7O`                     \_      \      \_       `\_    \\_  L     (L             
            _/                V_       `*C '`      OO       ]               `<      \       \_      _ \    (\_ (     ]U             
            `                  `~_    _  `\       ,)        |                 \              \_    _ ` `    O\_|      L             
          7                       `--*     \      //        U                 'C              \_   \  \_`   \ {V      [             
         !                            `\_   O    _C         !                  '_              \    [  \_\   O`` ,    [             
         V                           \_ }   O    **`                           V[               ,   U   ( `  L  _`   ,/             
         L                          ___C__,--~ -`            O                  \               O   [    Y [  L }    OC             
                                   /`                       _4                  U[                  [    \ U  \,`   /'              
        ~_                        ,"                     __ `                    \                  [     Y', _/   :,`              
         \_                       [            o__   __v``                       )O_                @     ' O V    _{               
          \_                      O,               CC                            [*`                [       V `    @                
           `,                     \\                 ` __                       /V                 O       _`'    O                 
           _-\_                    OL                   `~_                     #`                         V_    O`                 
           \_*.\(_                 \\                      \_                  /V                          /`   ,`                  
            \, \__`v~__       __,~^`[L                      [                 _'`                         '    ,`                   
              \__ `   _[[C````      (O                      [                _(/                         V    _`                    
                 `````]C `O<_        `>_                    O               :>'                          }   >`                     
                    (`_~`   `,         ``,_                ,               /^                           .` _/                       
                    `C,==- ``O`,          `KL              /            _,//                            / ,'                        
                      =-~*'``  ',           `^            _'       _-~:`OO`                            ',/                          
                         `o~___             U ` __,U.=-````     _,>`_-*7/`                            /`                            
                         @______:     ,L__  '*``      ___,--^_CC**`` .C/                             :                              
                                |     "* `*~__  `c@@F=-'````       ,(/`                            _/                               
                         -v~,__  .           ``*{  ^>_           >C^                              _*                                
                         *==LLL_`'L                __(\       _U/'                 _v`           }`                                 
                                 __\_            ,<` \:\    _,``                _-^            _C                                   
                            __-*`)" `\___________*   ]  \ _/}`               _ `              ,/                                    
                           (` _ `      ____          /] 'C<`            __-*`              _~`                                      
                            >'         [   `>~_     _*O<`         __- ^``                _/`                                        
                                         `*>L_ \   _'`     ___- ``                     _/`                                          
                                               `  ,`   __<``                         _:`                                            
                                    _L____      ,/`   -{>=.U__                    _U~`                                              
                                     Y     ``[ _`            `\_               _,*`                                                 
                                     `------'` |               `L           __/`                                                    
                                       _______ '<_              \     __- ^``                                                       
                                      \_    __}  `~_            __~-``                                                              
                                       `````        `~-<   __-- `                                                                   
</pre>
</strong>
</center>
{% endraw %}