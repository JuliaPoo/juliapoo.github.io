#let col = white
#let debug = true


#let html-equation(size: 1em, it) = html.frame()[
  #set text(size: size, fill: col)
  #it
]

#let template(
  layout: none,
  author: none,
  category: none,
  display-title: none,
  tags: (),
  excerpt: none,
  doc
) = context {
  if target() == "html" {
      html.elem("style", read("typst-style.css"))
  }

  if (debug and target() == "html") {
    html.elem("style")[
      body {
        background-color: \#001431;
        color: white;
      }
    ]
  }

  show math.equation.where(block: false): it => {
    if target() == "html" {
      html.elem("span", attrs: (class: "typst-eqn-inline"), html-equation(it))
    } else { it }
  }
  show math.equation.where(block: true): it => {
    if target() == "html" {
      html.elem("div", attrs: (class: "typst-eqn-block"), html-equation(it, size: 1.2em))
    } else { it }
  }
  show raw.where(block: true): it => {
    if target() == "html" {
      html.elem("div", attrs: (class: "typst-codeblock"), it)
    } else { it }
  }

  show image: it => {
    if target() == "html" {
      html.elem("img", attrs: (class: "typst-image", src: "/" + it.source))
    } else { it }
  }

  show raw.where(block: true): it => {
    if target() == "html" {
      raw(theme: "dracula.tmTheme", it)
    } else { it }
  }

  context if target() != "html" {
    align(center)[
      #text(size: 2.3em, weight: "bold", display-title)
      #block(width: 80%)[
        #{
          set par(justify: true)
          set align(left)
          excerpt
        }
        #grid(
          columns: (50%, 50%),
          align: (right + top, left + top),
          column-gutter: 1em,
          row-gutter: 0.7em,
          [*Author:*], author,
          [*Category:*], category,
          [*Tags:*], tags.join(", ")
        )
      ]
    ]
  }

  doc
}