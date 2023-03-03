#!/bin/sh

git submodule update --init --recursive
cd fennel
make
cd ..

fennel/fennel --compile init.fnl >init.lua

echo "<style>" >example.html
cat fennel.css >>example.html
echo "</style><pre>" >>example.html
fennel/fennel cli.fnl init.fnl >>example.html
echo "" >>example.html
fennel/fennel cli.fnl --from-lua init.lua >>example.html
