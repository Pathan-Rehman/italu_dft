# tt_um_italu – Tiny Tapeout Design

## Overview
This repository contains the complete flow for the **tt_um_italu** design, a small ALU with DFT/BIST, targeting the **ihp‑sg13g2** 130 nm PDK. The project goes from Verilog RTL through synthesis, placement, routing, power‑grid insertion, GDSII generation, DRC, and LVS sign‑off.

## Directory Structure
```
italu-sim/
├─ rtl/                # Verilog RTL sources (top‑level module `tt_um_italu.v`)
├─ synth/              # OpenROAD synthesis output
├─ routing/            # Placement and routing results (`*.def`, routed netlist)
├─ signoff/            # DRC/LVS artifacts
│   ├─ drc/            # DRC report (0 violations)
│   └─ lvs/            # LVS artifacts, cleaned SPICE, powered netlist, scripts
│       └─ extracted_cells/  # All *.ext extraction files
├─ gds/                # Final GDSII layout (`tt_um_italu.gds`)
├─ README.md           # This document
└─ SUMMARY.md          # Full end‑to‑end flow description
```

## Flow Summary
1. **RTL** – `rtl/tt_um_italu.v`
2. **Synthesis** – OpenROAD (`synthesis.tcl`) → `synth/tt_um_italu.synth.v`
3. **Placement** – OpenROAD (`place.tcl`) → placed DEF
4. **Routing** – OpenROAD (`route.tcl`) → `routing/tt_um_italu.def` & `routing/routed_netlist.v`
5. **Power‑grid** – OpenROAD (`add_power.tcl`) → `signoff/lvs/routed_powered_netlist.v` (adds explicit VDD/VSS ports)
6. **GDSII** – Magic generates `gds/tt_um_italu.gds`
7. **DRC** – Magic DRC → `signoff/drc/drc_report.rpt` (0 errors)
8. **Extraction** – Magic `ext2spice` → `signoff/lvs/tt_um_italu.ext.spice`
9. **LVS Preparation** – `clean_spice.sh` strips filler cells → `tt_um_italu.clean.spice`
10. **LVS** – Netgen with `custom_setup.tcl` (global VDD/VSS) → `signoff/lvs/lvs_report.out` (Circuits match)

## Reproducing the Flow
```bash
# Clone the repo
git clone https://github.com/Pathan-Rehman/italu_dft.git
cd italu-dft/italu-sim

# Synthesis
openroad synthesis.tcl

# Place & route
openroad place.tcl
openroad route.tcl

# Add power pins
openroad add_power.tcl

# Generate GDSII
magic -dnull -noconsole -rcfile $PDK_ROOT/ihp-sg13g2/libs.tech/magic/ihp-sg13g2.magicrc <<'EOF'
read def routing/tt_um_italu.def
writegds gds/tt_um_italu.gds
quit
EOF

# DRC check
magic -dnull -noconsole -rcfile $PDK_ROOT/ihp-sg13g2/libs.tech/magic/ihp-sg13g2.magicrc <<'EOF'
# (DRC commands) …
quit
EOF

# Extraction for LVS
magic -dnull -noconsole -rcfile $PDK_ROOT/ihp-sg13g2/libs.tech/magic/ihp-sg13g2.magicrc <<'EOF'
read gds/tt_um_italu.gds
extract all
ext2spice lvs
ext2spice -o signoff/lvs/tt_um_italu.ext.spice
quit
EOF

# Clean filler cells
./signoff/lvs/clean_spice.sh signoff/lvs/tt_um_italu.ext.spice signoff/lvs/tt_um_italu.clean.spice

# Run LVS
netgen -batch lvs signoff/lvs/tt_um_italu.clean.spice signoff/lvs/routed_powered_netlist.v signoff/lvs/custom_setup.tcl -log signoff/lvs/lvs_report.out
```

All intermediate results are stored under `signoff/` for traceability.

## License
Apache‑2.0 – see the `LICENSE` file.

---
*Maintainer: Pathan‑Rehman*
