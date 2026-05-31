set TOP top_sgla_innovus

# TODO: 請改成你的實際製程 LEF/TechLEF/Lib 路徑
set init_lef_file "/path/to/tech.lef /path/to/stdcell.lef"
set init_verilog "${TOP}_syn.v"
set init_mmmc_file "mmmc.tcl"
set init_top_cell $TOP

if {[file exists "${TOP}_syn.sdc"]} {
  set init_pwr_net {VDD}
  set init_gnd_net {VSS}
}

init_design

floorPlan -site core -r 1.0 0.7 20 20 20 20

addRing -nets {VDD VSS} -layer {top M8 bottom M8 left M7 right M7} -width 2 -spacing 1
sroute

place_opt_design
clock_opt_design
route_opt_design

verify_drc
verifyConnectivity

report_timing > reports_innovus_timing.rpt
report_area > reports_innovus_area.rpt

saveDesign ${TOP}_postroute.enc
streamOut ${TOP}.gds -mapFile /path/to/streamOut.map -merge /path/to/merge.gds -libName WORK

exit

