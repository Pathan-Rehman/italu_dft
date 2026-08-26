#!/bin/bash
iverilog -g2012 -o sim.vvp tb.v ../rtl/project.v
vvp sim.vvp > results.txt 2>&1
