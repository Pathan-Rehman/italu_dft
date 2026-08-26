# Global + detailed placement (mirrors LibreLane's openroad.GlobalPlacement
# / DetailedPlacement steps)

read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_tech.lef
read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef
read_liberty /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib

read_def ../pdn/pdn.def
read_sdc ../synth/constraints.sdc

# Signal routing layers: Metal1..Metal4
# (TopMetal1/TopMetal2 are reserved for the PDN straps)
set_routing_layers -signal Metal1-Metal4 -clock Metal1-Metal4

# ---------------------------------------------------------------
# Global placement
# ---------------------------------------------------------------

# Core util is 58%; give the placer a bit of headroom for legalization
set target_density 0.62

global_placement -density $target_density

estimate_parasitics -placement

puts "\n================ GLOBAL PLACEMENT ================"
report_worst_slack -max
report_tns
puts "==================================================\n"

# ---------------------------------------------------------------
# Legalize with detailed placement
# ---------------------------------------------------------------

detailed_placement
check_placement -verbose

estimate_parasitics -placement

puts "\n================ PLACEMENT SUMMARY ================"
report_design_area
puts "--- Setup timing after placement ---"
report_worst_slack -max
report_wns
report_tns
puts "====================================================\n"

write_def placed.def

exit
