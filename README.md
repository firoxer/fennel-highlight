fennel-highlight
===

Syntax highlighting for [Fennel](https://fennel-lang.org/)

What now?
---

[Have a look!](https://firoxer.github.io/fennel-highlight/example.html) This is all generated from `sample.fnl` with `highlight.fnl` with some `fennel.css` slapped on top of it.

Usage
---

See `highlight-cli.fnl` for a working example.

In short, do
```
(local highlight (require :highlight))
(local fennel (require :fennel))

(print (highlight.for-html (fennel.syntax) your-fennel-source-code-here))
```
