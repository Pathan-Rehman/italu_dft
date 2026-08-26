# Fill/decap insertion (mirrors LibreLane's openroad.FillInsertion)

read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_tech.lef
read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef
read_liberty /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib

read_def ../routing/routed.def

set block [ord::get_db_block]
set before [llength [$block getInsts]]

filler_placement {sg13g2_fill_8 sg13g2_fill_4 sg13g2_fill_2 sg13g2_fill_1}

set after [llength [$block getInsts]]
puts "\n================ FILL SUMMARY ================"
puts "Instances before: $before"
puts "Instances after : $after"
puts "Fill cells added: [expr {$after - $before}]"
check_placement
puts "==============================================\n"

write_def routed_fill.def
exit
