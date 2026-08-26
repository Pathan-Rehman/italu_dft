# Global + detailed routing (mirrors LibreLane's openroad.GlobalRouting /
# DetailedRouting steps)

read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_tech.lef
read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef
read_liberty /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib

read_def ../cts/cts.def
read_sdc ../synth/constraints.sdc

set_routing_layers -signal Metal1-Metal4 -clock Metal1-Metal4
set_wire_rc -signal -layer Metal3
set_wire_rc -clock  -layer Metal3

# ---------------------------------------------------------------
# Synthesis constant nets: OpenROAD's verilog reader names nets
# driven by logic-1 'one_' and types it POWER, which TritonRoute
# refuses to route. uio_oe = 8'hFF is genuinely a constant: tie
# its output pins directly to the VDD power net.
# ---------------------------------------------------------------

set block [ord::get_db_block]
set const_net [$block findNet one_]
if {$const_net != "NULL"} {
    set vdd_net [$block findNet VDD]
    foreach bterm [$const_net getBTerms] {
        puts "Tying port [$bterm getName] to VDD"
        $bterm connect $vdd_net
    }
    odb::dbNet_destroy $const_net
}

repair_tie_fanout -separation 1.0 {sg13g2_stdcell_typ_1p20V_25C/sg13g2_tiehi/L_HI sg13g2_stdcell_typ_1p20V_25C/sg13g2_tielo/L_LO}
detailed_placement
check_placement

# ---------------------------------------------------------------
# Global routing
# ---------------------------------------------------------------

global_route \
    -guide_file route.guide \
    -congestion_iterations 100 \
    -verbose

# ---------------------------------------------------------------
# Detailed routing
# ---------------------------------------------------------------

detailed_route \
    -output_drc route_drc.rpt \
    -droute_end_iter 64 \
    -verbose 1

puts "\n================ ROUTE SUMMARY ================"
report_worst_slack -max
report_worst_slack -min
puts "===============================================\n"

write_def routed.def

exit
