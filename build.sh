#!/bin/bash
touch build/dummy
rm build/*
ca65 src/aspect.s -g -o build/aspect.o
ld65 -o build/aspect.nes -C src/aspect.cfg build/aspect.o -m build/aspect.map.txt -Ln build/aspect.labels.txt --dbgfile build/aspect.nes.dbg
