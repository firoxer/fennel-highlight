#!/bin/sh

git submodule update --init --recursive
cd fennel
make
cd ..

fennel --compile highlight.fnl >highlight.lua

echo "<style>" >example.html
cat fennel.css >>example.html
echo "</style><pre>" >>example.html
lua -e 'do
  highlight = require("highlight")
  fennel = require("fennel.fennel")
  example = io.open("example.fnl", "rb"):read("*all")
  print(highlight.for_html(fennel.syntax(), example))
end' >>example.html
