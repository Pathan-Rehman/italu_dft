# Parasitic extraction (RCX) + SPEF writeout
# (mirrors LibreLane's openroad.RCX)

read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_tech.lef
read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef
read_liberty /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib

read_def ../routing/routed.def

define_process_corner -ext_model_index 0 X
extract_parasitics \
    -ext_model_file /foss/pdks/ihp-sg13g2/libs.tech/librelane/openrcx/IHP_rcx_patterns.rules \
    -corner_cnt 1

write_spef routed.spef
puts "SPEF written: routed.spef"
exit
