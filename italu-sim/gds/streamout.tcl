# GDS stream-out with Magic (mirrors LibreLane's Magic.StreamOut /
# scripts/magic/def/mag_gds.tcl)
drc off
crashbackups disable
locking disable

gds noduplicates true
gds readonly true

# std cell geometry
gds read /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/gds/sg13g2_stdcell.gds

# annotate cells with LEF views
lef read /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_tech.lef
lef read /foss/pdks/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef

load (NEWCELL)

def read ../fill/routed_fill.def

load tt_um_italu
select top cell
units microns

property FIXED_BBOX 0um 0um 202.08um 154.98um

select top cell
cellname filepath tt_um_italu .
save
load tt_um_italu
select top cell

cif *hier write disable
cif *array write disable

gds nodatestamp yes

gds write tt_um_italu.gds
puts "GDS Write Complete"
quit -noprompt
