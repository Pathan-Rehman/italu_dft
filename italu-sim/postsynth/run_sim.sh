#!/bin/bash
iverilog -g2012 -o postsim.vvp tb_ps.v synth_netlist.v /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/verilog/sg13g2_stdcell.v /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/verilog/sg13g2_udp.v
vvp postsim.vvp > results.txt 2>&1
