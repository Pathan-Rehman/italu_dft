# Clock Tree Synthesis (mirrors LibreLane's openroad.CTS step)

read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_tech.lef
read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef
read_liberty /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib

read_def ../placement/placed.def
read_sdc ../synth/constraints.sdc

set_routing_layers -signal Metal1-Metal4 -clock Metal1-Metal4

# Wire RC estimates for parasitic-aware optimization
set_wire_rc -signal -layer Metal3
set_wire_rc -clock  -layer Metal3

# ---------------------------------------------------------------
# Build the clock tree: 165 flops off the clk port
# ---------------------------------------------------------------

clock_tree_synthesis \
    -buf_list {sg13g2_buf_1 sg13g2_buf_2 sg13g2_buf_4} \
    -root_buf sg13g2_buf_4 \
    -sink_clustering_enable \
    -balance_levels

# Legalize the newly inserted buffer cells
detailed_placement
check_placement -verbose

estimate_parasitics -placement
set_propagated_clock [all_clocks]

puts "\n================ CTS SUMMARY ================"
puts "--- Skew ---"
report_clock_skew
puts "--- Setup timing after CTS ---"
report_worst_slack -max
report_wns
report_tns
puts "--- Hold timing after CTS ---"
report_worst_slack -min
puts "=============================================\n"

write_def cts.def

exit
