#============================================================
# nbody_accelerator — Floorplan + Power Planning (core-only, no pad ring)
# Usage:  source floorplan.tcl
#============================================================

puts "=== STEP 1: Floorplan ==="
# -r <aspect ratio> <utilization> <left> <bottom> <right> <top> core-to-die margins.
# Aspect 1.0 = square core, 65% utilization (cell area / core area), 5um
# margin on each side for the ring + stripes below.
floorPlan -site CoreSite -r 1.0 0.65 5 5 5 5

puts "=== STEP 2: Connect global power/ground nets ==="
globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose
deselectAll

puts "=== STEP 3: Add core power ring ==="
# Plain M5(top/bottom)/M4(left/right) ring - no pad frame to route around,
# unlike i2c's TOP_M ring which was sized for its PIO320SL pad cells.
setAddRingMode \
    -ring_target default \
    -extend_over_row 0 \
    -ignore_rows 0 \
    -avoid_short 0 \
    -skip_crossing_trunks none \
    -stacked_via_top_layer M5 \
    -stacked_via_bottom_layer M1 \
    -orthogonal_only true \
    -skip_via_on_pin { standardcell } \
    -skip_via_on_wire_shape { noshape }

addRing \
    -nets {VDD VSS} \
    -around core \
    -layer {top M5 bottom M5 left M4 right M4} \
    -width 2 \
    -spacing 1 \
    -center 1

puts "=== STEP 4: Add vertical power stripes (M4) ==="
addStripe \
    -nets {VDD VSS} \
    -layer M4 \
    -direction vertical \
    -width 2 \
    -spacing 1 \
    -set_to_set_distance 50 \
    -start_from left \
    -stacked_via_top_layer M5 \
    -stacked_via_bottom_layer M1

puts "=== STEP 5: Route power to standard cell pins ==="
setSrouteMode -padPinLayerRange {M1 M5}
sroute \
    -connect { corePin } \
    -layerChangeRange { M1 M5 } \
    -nets { VDD VSS }

puts "=== Floorplan + Power Planning DONE (no pad-margin blockages needed - core-only) ==="
puts "Next: placeDesign, source cts.tcl, then routeDesign"
