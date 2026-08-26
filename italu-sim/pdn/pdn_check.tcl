read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_tech.lef
read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef
read_def pdn.def

set block [ord::get_db_block]
array set layer_wires {}
foreach net {VDD VSS} {
    set n [$block findNet $net]
    foreach sw [$n getSWires] {
        foreach w [$sw getWires] {
            set ln [$w getTechLayer]
            if {$ln == "NULL"} { continue }
            set lname [$ln getName]
            if {[info exists layer_wires($lname)]} {
                incr layer_wires($lname)
            } else {
                set layer_wires($lname) 1
            }
        }
    }
}
puts "Special wiring by layer:"
foreach l [lsort [array names layer_wires]] {
    puts "  $l: $layer_wires($l)"
}

puts "\ncheck_power_grid:"
check_power_grid -net VDD
check_power_grid -net VSS
exit
