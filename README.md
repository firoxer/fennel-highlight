fennel-highlight
===

Syntax highlighting for [Fennel](https://fennel-lang.org/) and maybe a bit for Lua too

Say what now?
---

[Have a look!](https://firoxer.github.io/fennel-highlight/example.html) This is the highlighted source for the highlighter itself (first the original Fennel, then the compiled Lua) with some `fennel.css` slapped on top of it.

Usage
---

In short, do
```fnl
(local highlight (require :highlight))
(local fennel (require :fennel))

(let [source (read-from-file-or-whatever)
      html-tags (highlight.fennel->html (fennel.syntax) source)]
  (each [_ tag (ipairs html-tags)]
    (write-to-your-page tag)))
```

You can also have a look at `highlight-cli.fnl` for a working example.

