#!/bin/bash
export PDK=ihp-sg13g2
export PDK_ROOT=/foss/pdks

magic -dnull -noconsole -rcfile $PDK_ROOT/ihp-sg13g2/libs.tech/magic/ihp-sg13g2.magicrc << EOFMAGIC
gds read ../../gds/tt_um_italu.gds
load tt_um_italu
extract do local
extract all
ext2spice lvs
ext2spice -o tt_um_italu.ext.spice
quit
EOFMAGIC

netgen -batch lvs "tt_um_italu.ext.spice tt_um_italu" "../../routing/routed_netlist.v tt_um_italu" $PDK_ROOT/ihp-sg13g2/libs.tech/netgen/setup.tcl lvs_report.out
