# Floorplan replicating the Tiny Tapeout 1x1 tile on IHP SG13G2
# Die area and pin placement taken from tt-support-tools'
# tech/ihp-sg13g2/def/tt_block_1x1_pgvdd.def

read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_tech.lef
read_lef /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef
read_liberty /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib

read_verilog ../synth/synth_netlist.v
link_design tt_um_italu
read_sdc ../synth/constraints.sdc

# ---------------------------------------------------------------
# Floorplan: TT 1x1 tile (values from the official DEF template)
#   die:  202.08 x 154.98 um
#   core: rows at x=2.88..199.20, y=3.78..151.20 (39 rows, site 0.48x3.78)
# ---------------------------------------------------------------

initialize_floorplan -die_area {0.0 0.0 202.08 154.98} \
                     -core_area {2.88 3.78 199.2 151.2} \
                     -site CoreSite

make_tracks

# ---------------------------------------------------------------
# Pin placement per the TT DEF template:
# all pins on Metal4, top edge, y = 153.98..154.98 um,
# x positions spaced 3.84um, matching the shuttle arrangement.
# ---------------------------------------------------------------

set block [ord::get_db_block]
set m4 [[ord::get_db_tech] findLayer Metal4]

set pin_xs {
    uo_out[0]  118.08   uo_out[1] 114.24   uo_out[2] 110.40
    uo_out[3]  106.56   uo_out[4] 102.72   uo_out[5]  98.88
    uo_out[6]   95.04   uo_out[7]  91.20
    clk        187.20   ena       191.04   rst_n     183.36
    ui_in[0]   179.52   ui_in[1]  175.68   ui_in[2]  171.84
    ui_in[3]   168.00   ui_in[4]  164.16   ui_in[5]  160.32
    ui_in[6]   156.48   ui_in[7]  152.64
    uio_oe[0]   56.64   uio_oe[1]  52.80   uio_oe[2]  48.96
    uio_oe[3]   45.12   uio_oe[4]  41.28   uio_oe[5]  37.44
    uio_oe[6]   33.60   uio_oe[7]  29.76
    uio_out[0]  87.36   uio_out[1] 83.52   uio_out[2] 79.68
    uio_out[3]  75.84   uio_out[4] 72.00   uio_out[5] 68.16
    uio_out[6]  64.32   uio_out[7] 60.48
    uio_in[0]  148.80   uio_in[1] 144.96   uio_in[2] 141.12
    uio_in[3]  137.28   uio_in[4] 133.44   uio_in[5] 129.60
    uio_in[6]  125.76   uio_in[7] 121.92
}

foreach {pname px} $pin_xs {
    set bterm [$block findBTerm $pname]
    if {$bterm == "NULL"} {
        puts "WARN: no port named $pname"
        continue
    }
    set bpin [odb::dbBPin_create $bterm]
    $bpin setPlacementStatus FIRM
    set x [expr {int(round($px * 1000))}]
    odb::dbBox_create $bpin $m4 [expr {$x - 150}] 153980 [expr {$x + 150}] 154980
}

# ---------------------------------------------------------------
# Reports + outputs
# ---------------------------------------------------------------

puts "\n================ FLOORPLAN SUMMARY ================"
report_design_area

set dbu [$block getDefUnits]
set core [$block getCoreArea]
set die [$block getDieArea]
puts "Die:  [$die xMin] [$die yMin] -> [$die xMax] [$die yMax] (DBU)"
puts "Core: [$core xMin] [$core yMin] -> [$core xMax] [$core yMax] (DBU)"
puts "Rows: [llength [$block getRows]]"
puts "===================================================\n"

write_def floorplan.def
write_verilog floorplan_netlist.v

exit
