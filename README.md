fennel-highlight
===

Syntax highlighting for [Fennel](https://fennel-lang.org/)

Say what now?
---

[Have a look!](https://firoxer.github.io/fennel-highlight/example.html) This is the highlighted source for the highlighter itself with some `fennel.css` slapped on top of it.

Usage
---

See `highlight-cli.fnl` for a working example.

In short, do
```
(local highlight (require :highlight))
(local fennel (require :fennel))

(print (highlight.for-html (fennel.syntax) your-fennel-source-code-here))
```
