#!/bin/bash

# clean compile/run files
find ./ -type f -name "*.adr" -exec rm -f {} \;
find ./ -type f -name "*.class" -exec rm -f {} \;
find ./ -type f -name "*.out" -exec rm -f {} \;