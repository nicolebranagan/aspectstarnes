#!/bin/bash
touch build/dummy
rm build/*
for file in src/*.s
do
    ca65 "$file" -g -o build/`basename $file .s`.o
done
ld65 -o build/aspect.nes -C src/aspect.cfg build/*.o -m build/aspect.map.txt -Ln build/aspect.labels.txt --dbgfile build/aspect.nes.dbg
