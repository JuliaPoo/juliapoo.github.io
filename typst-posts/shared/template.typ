#let mode = sys.inputs.at("mode", default: "print")
#let primary-col = if mode == "print" {black} else {white}

#let template(
  layout: none,
  author: none,
  category: none,
  display-title: none,
  tags: (),
  excerpt: none,
  doc
) = {

  if mode == "print" {
    show math.equation.where(block: true): set block(above: 1em, below: 1em)

    align(center)[
      #text(size: 2.3em, weight: "bold", display-title)
      #block(width: 80%)[
        #{
          set par(justify: true)
          set align(left)
          excerpt
        }
        #grid(
          columns: (auto, auto),
          align: (right + top, left + top),
          column-gutter: 1em,
          row-gutter: 0.7em,
          [*Author:*], author,
          [*Category:*], category,
          [*Tags:*], tags.join(", ")
        )
      ]
    ]

    show link: it => text(fill: rgb("#016539"), underline(it))
    set par(justify: true)
    
    doc 

  } else {

    let html-equation(size: 1em, it) = html.frame()[#{
      set text(size: size, fill: primary-col)
      it
    }]
    html.elem("style", read("typst-style.css"))
    show math.equation.where(block: false): it => {
      html.elem("span", attrs: (class: "typst-eqn-inline"), html-equation(it))
    }
    show math.equation.where(block: true): it => {
      html.elem("div", attrs: (class: "typst-eqn-block"), html-equation(it, size: 1.2em))
    }
    show raw.where(block: true): it => {
      html.elem("div", attrs: (class: "typst-codeblock"), it)
    }
    show image: it => {
      html.elem("img", attrs: (class: "typst-image", src: "/" + it.source))
    }

    set raw(theme: "dracula.tmTheme")

    doc
  }

}