N-BODY ACCELERATOR - SYNTHESIS BUNDLE

This folder contains the SystemVerilog source and synthesis script for
nbody_accelerator_fp32.sv, set up the same way as i2c_syn_tech/.

Files included:
- nbody_accelerator_fp32.sv
- nbody_syn.tcl
- .synopsys_dc.setup   (same Tower 0.18um tsl18fs120 library as the i2c flow)

How to run on the lab machine:

1) Connect via VNC, then in a terminal on the remote desktop:
     bash
     export DISPLAY=:<n>
     cd ~/Desktop/khaled/nbody_accelerator   (wherever you cloned this repo)
     git pull origin main

2) Open Design Vision from this folder:
     design_vision &

3) In Design Vision's command line run:
     source nbody_syn.tcl

Expected output:
- nbody_accelerator_syn.v
- reports/timing.rpt
- reports/area.rpt
- reports/power.rpt

Top module : nbody_accelerator
Clock port : clk (10 ns period, i.e. 100 MHz)
Reset      : rst_n (active-low; no special CTS/DFT handling applied here,
             same as the base i2c synthesis step)
