# PDN generation replicating Tiny Tapeout's IHP SG13G2 configuration
# (values from libs.tech/librelane/config.tcl + LibreLane pdn_cfg.tcl)

read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_tech.lef
read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef
read_liberty /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib

read_def ../floorplan/floorplan.def
read_sdc ../synth/constraints.sdc

# ---------------------------------------------------------------
# Global connections: hook every cell's VDD/VSS pins to the nets
# ---------------------------------------------------------------

add_global_connection -net VDD -inst_pattern .* -pin_pattern ^VDD$ -power
add_global_connection -net VSS -inst_pattern .* -pin_pattern ^VSS$ -ground
global_connect

set_voltage_domain -name CORE -power VDD -ground VSS

# ---------------------------------------------------------------
# Grid per TT IHP settings:
#   vertical layer   : TopMetal1 (w=2.2, pitch=75.6, offset=13.6, spacing=4.0)
#   horizontal layer : TopMetal2 (same)
#   followpin rails  : Metal1 (standard cell rails)
#   core ring        : disabled (TT default)
# ---------------------------------------------------------------

define_pdn_grid -name stdcell_grid \
    -starts_with POWER \
    -voltage_domain CORE \
    -pins {TopMetal1 TopMetal2}

add_pdn_stripe -grid stdcell_grid -layer TopMetal1 \
    -width 2.2 -pitch 75.6 -offset 13.6 -spacing 4.0 \
    -extend_to_boundary -starts_with POWER

add_pdn_stripe -grid stdcell_grid -layer TopMetal2 \
    -width 2.2 -pitch 75.6 -offset 13.6 -spacing 4.0 \
    -extend_to_boundary -starts_with POWER

add_pdn_connect -grid stdcell_grid -layers {TopMetal1 TopMetal2}

add_pdn_stripe -grid stdcell_grid -layer Metal1 -width 0.44 -followpins

add_pdn_connect -grid stdcell_grid -layers {Metal1 TopMetal1}

# ---------------------------------------------------------------
# Build the grid
# ---------------------------------------------------------------

pdngen

puts "\n================ PDN SUMMARY ================"
foreach net {VDD VSS} {
    set n [[ord::get_db_block] findNet $net]
    set wires [$n getSWires]
    set count 0
    foreach sw $wires { set count [expr {$count + [llength [$sw getWires]]}] }
    puts "$net: $count special wire segments"
}
puts "=============================================\n"

write_def pdn.def

exit
