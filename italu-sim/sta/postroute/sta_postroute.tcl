# Post-route STA with extracted parasitics
set LIB /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib

read_liberty $LIB
read_verilog ../../routing/routed_netlist.v
link_design tt_um_italu
read_sdc ../../synth/constraints.sdc
read_spef ../../routing/routed.spef

set_propagated_clock [all_clocks]

report_checks -path_delay max -group_path_count 10 -digits 3 > reports/pr_setup_worst_paths.rpt
report_checks -path_delay min -group_path_count 10 -digits 3 > reports/pr_hold_worst_paths.rpt

report_worst_slack -max > reports/pr_worst_slack_setup.rpt
report_worst_slack -min > reports/pr_worst_slack_hold.rpt
report_tns > reports/pr_tns.rpt
report_wns > reports/pr_wns.rpt
report_clock_skew > reports/pr_clock_skew.rpt
report_check_types -max_slew -max_capacitance -max_fanout -violators > reports/pr_design_rule_violations.rpt

puts "\n============ POST-ROUTE STA SUMMARY ============"
puts "--- Setup ---"
report_worst_slack -max
report_tns
puts "--- Hold ---"
report_worst_slack -min
puts "--- Critical path ---"
report_checks -path_delay max -group_path_count 1 -digits 3
puts "================================================\n"
exit
