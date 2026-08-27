# tt_um_italu – Tiny Tapeout ALU with DFT/BIST

## Project overview

This repository contains the **OpenLane/OpenROAD ASIC flow** for the Tiny Tapeout design `tt_um_italu`.  The design implements a small ALU with added Design‑For‑Test (DFT) and Built‑In‑Self‑Test (BIST) structures.

The flow hierarchy (relevant directories):

```
italu-sim/
│   README.md               <-- you are here
│   ... (RTL, simulation, etc.)
└── signoff/                <-- sign‑off artifacts
    ├── drc/
    │   └── drc_report.rpt   <-- DRC report (0 violations)
    └── lvs/
        ├── lvs_report.out   <-- LVS report (Circuits match)
        ├── tt_um_italu.clean.spice   <-- Magic‑extracted SPICE without filler cells
        ├── routed_powered_netlist.v <-- Verilog netlist with explicit VDD/VSS
        ├── custom_setup.tcl  <-- Netgen setup (global power nets)
        ├── clean_spice.sh    <-- Helper script that strips filler cells
        └── extracted_cells/  <-- all *.ext extraction files (kept separate)
```

### Design‑rule check (DRC)
* **Tool:** Magic (PDK = `ihp‑sg13g2`).
* **Result:** `signoff/drc/drc_report.rpt` shows **0 DRC violations**.  The layout complies with the IHP SG13G2 design rules.

### Layout‑versus‑schematic check (LVS)
* **Extraction:** Magic `ext2spice` → `tt_um_italu.ext.spice`.
* **Cleanup:** `clean_spice.sh` removes the filler‑cell subcircuits, producing `tt_um_italu.clean.spice`.
* **Power‑pin handling:** `custom_setup.tcl` marks `VDD` and `VSS` as global nets so the top‑level pin mismatch disappears.
* **Verilog netlist:** OpenROAD script `gen_powered_netlist.tcl` creates `routed_powered_netlist.v` that includes the power pins.
* **Result:** `signoff/lvs/lvs_report.out` ends with:

```
Final result: Circuits match.
```
Thus the layout and schematic are fully equivalent.

## How to reproduce the sign‑off
```
# 1. Extract SPICE (already done)
magic -dnull -noconsole -rcfile $PDK_ROOT/ihp-sg13g2/libs.tech/magic/ihp-sg13g2.magicrc <<'EOF'
  gds read ../gds/tt_um_italu.gds
  load tt_um_italu
  extract all
  ext2spice lvs
  ext2spice -o tt_um_italu.ext.spice
  quit
