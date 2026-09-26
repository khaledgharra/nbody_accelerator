#============================================================
# CTS — Clock Tree Synthesis (nbody_accelerator)
# Run AFTER placeDesign, BEFORE routeDesign
# Usage:  source cts.tcl
#============================================================

puts "=== CTS STEP 1: Set CTS mode ==="
setDesignMode -process 180

puts "=== CTS STEP 2: Run Clock Tree Synthesis ==="
clockDesign

puts "=== CTS STEP 3: Post-CTS timing optimization ==="
optDesign -postCTS

puts "=== CTS DONE ==="
puts "Next: routeDesign"
