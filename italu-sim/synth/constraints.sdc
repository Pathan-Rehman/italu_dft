# SDC constraints for iTALU post-synthesis STA
# 50 MHz clock (same as the testbench: 20 ns period)

create_clock -name clk -period 20.0 [get_ports clk]

set_clock_uncertainty 0.1 [get_clocks clk]

# Inputs driven by external logic registered on clk
set_input_delay 2.0 -clock clk [get_ports {rst_n ui_in[*] uio_in[*]}]
# Outputs to external registers
set_output_delay 2.0 -clock clk [all_outputs]

# Async reset: no timing path constrained through it
set_false_path -from [get_ports rst_n]

# Drive strengths / loads
set_driving_cell -lib_cell sg13g2_dfrbpq_1 -pin Q [get_ports {ui_in[*] uio_in[*]}]
set_load 0.05 [all_outputs]
