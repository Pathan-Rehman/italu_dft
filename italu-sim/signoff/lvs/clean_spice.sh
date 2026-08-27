#!/usr/bin/env bash
# clean_spice.sh - remove filler cell subcircuits from Magic SPICE netlist
# Usage: clean_spice.sh <input_spice> <output_spice>

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input_spice> <output_spice>"
  exit 1
fi

input="$1"
output="$2"
skip=0
while IFS= read -r line; do
  if [ $skip -eq 1 ]; then
    if [[ $line =~ ^\.ends ]]; then
      skip=0
    fi
    continue
  fi
  if [[ $line =~ ^\.subckt.*fill_ ]]; then
    skip=1
    continue
  fi
  echo "$line"
done < "$input" > "$output"
