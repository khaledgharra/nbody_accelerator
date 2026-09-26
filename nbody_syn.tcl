#============================================================
# N-Body Accelerator synthesis script - SystemVerilog version
# Tool       : Synopsys Design Vision / Design Compiler
# Top module : nbody_accelerator
# Clock port : clk
# Output     : nbody_accelerator_syn.v
#============================================================

# Clean old data from this Design Vision session
remove_design -all

# Variables
set DESIGN_NAME nbody_accelerator
set CLK_NAME    clk
set CLK_PERIOD  15

# Make includes searchable from the current folder
set_app_var search_path [concat [list . [pwd]] $search_path]

# Create WORK library for analyze/elaborate flow
file mkdir WORK
define_design_lib WORK -path ./WORK

# Read SystemVerilog RTL. All submodules (fp_mul, fp_sqrt, fp_div, fp_add,
# body_regfile, pair_rom, nbody_core, nbody_accelerator) live in this one file.
analyze -format sverilog {
    ./nbody_accelerator_fp32.sv
}

# Build the top design
elaborate $DESIGN_NAME
current_design $DESIGN_NAME
link
uniquify
check_design

# Clock constraint
create_clock -name $CLK_NAME -period $CLK_PERIOD -waveform {0 5} [get_ports $CLK_NAME]

# Basic I/O constraints for backend/floorplan exercise
set_input_delay  0 -clock $CLK_NAME [remove_from_collection [all_inputs] [get_ports $CLK_NAME]]
set_output_delay 0 -clock $CLK_NAME [all_outputs]

# Synthesis - same basic idea as the i2c backend lab
compile -exact_map

# Reports
file mkdir reports
redirect -file reports/timing.rpt { report_timing -max_paths 10 }
redirect -file reports/area.rpt   { report_area }
redirect -file reports/power.rpt  { report_power }

# Netlist for Innovus / floorplan
write -hierarchy -format verilog -output nbody_accelerator_syn.v

puts "============================================================"
puts "SYNTHESIS FINISHED SUCCESSFULLY"
puts "Generated netlist: nbody_accelerator_syn.v"
puts "Reports folder: reports/"
puts "Top module: nbody_accelerator"
puts "Clock port: clk"
puts "============================================================"
