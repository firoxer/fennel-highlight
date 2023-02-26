#!/bin/sh

git submodule update --init --recursive
cd fennel
make
cd ..

fennel/fennel --compile highlight.fnl >highlight.lua

echo "<style>" >example.html
cat fennel.css >>example.html
echo "</style><pre>" >>example.html
fennel/fennel highlight-cli.fnl example.fnl >>example.html
