# OpenSTA script: post-synthesis STA for tt_um_italu
set LIB /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib

read_liberty $LIB
read_verilog ../../synth/synth_netlist.v
link_design tt_um_italu
read_sdc ../../synth/constraints.sdc

# ---------------------------------------------------------------
# Reports
# ---------------------------------------------------------------

report_checks -path_delay max -group_count 10 -digits 3 > reports/setup_worst_paths.rpt
report_checks -path_delay min -group_count 10 -digits 3 > reports/hold_worst_paths.rpt

report_worst_slack -max > reports/worst_slack_setup.rpt
report_worst_slack -min > reports/worst_slack_hold.rpt
report_tns > reports/tns.rpt
report_wns > reports/wns.rpt

report_check_types -max_slew -max_capacitance -max_fanout -violators > reports/design_rule_violations.rpt

report_clock_skew > reports/clock_skew.rpt

puts "\n================ STA SUMMARY ================"
puts "--- Setup (worst slack) ---"
report_worst_slack -max
puts "--- Hold (worst slack) ---"
report_worst_slack -min
puts "--- TNS / WNS ---"
report_tns
report_wns
puts "--- Critical path (setup) ---"
report_checks -path_delay max -group_count 1 -digits 3
puts "=============================================\n"

exit
