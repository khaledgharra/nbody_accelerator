#============================================================
# N-Body Accelerator - Fmax exploration script
# Purpose: nbody_syn.tcl's 10ns run closed at exactly slack=0.00,
# which only proves DC stopped optimizing once it hit the target -
# it says nothing about the real critical path length. This script
# asks for an unrealistically fast period so the optimizer is forced
# to try its hardest, then we read the *negative* slack it reports
# back to get the true critical-path delay.
#
# Read reports/timing_fmax.rpt afterward:
#   worst slack (negative) = CLK_PERIOD_PROBE - true_critical_path_delay
#   => true_critical_path_delay = CLK_PERIOD_PROBE - slack
# Pick a real target period a bit above that number (leave margin
# for real placement/routing wire delay, which this pre-layout run
# does not include).
#============================================================

remove_design -all

set DESIGN_NAME      nbody_accelerator
set CLK_NAME         clk
set CLK_PERIOD_PROBE 3

set_app_var search_path [concat [list . [pwd]] $search_path]

file mkdir WORK
define_design_lib WORK -path ./WORK

analyze -format sverilog {
    ./nbody_accelerator_fp32.sv
}

elaborate $DESIGN_NAME
current_design $DESIGN_NAME
link
uniquify
check_design

create_clock -name $CLK_NAME -period $CLK_PERIOD_PROBE -waveform [list 0 [expr {$CLK_PERIOD_PROBE / 2.0}]] [get_ports $CLK_NAME]
set_input_delay  0 -clock $CLK_NAME [remove_from_collection [all_inputs] [get_ports $CLK_NAME]]
set_output_delay 0 -clock $CLK_NAME [all_outputs]

# High effort so we actually push the critical path as far as it'll go,
# instead of stopping at whatever the (unreachable) target implies.
compile_ultra -no_autoungroup

file mkdir reports
redirect -file reports/timing_fmax.rpt { report_timing -max_paths 10 }
redirect -file reports/area_fmax.rpt   { report_area }

puts "============================================================"
puts "FMAX PROBE DONE (target was ${CLK_PERIOD_PROBE}ns - not meant to pass)"
puts "Read reports/timing_fmax.rpt: true_critical_path = period - slack"
puts "============================================================"
