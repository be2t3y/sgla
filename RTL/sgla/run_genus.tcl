set TOP top_sgla_innovus
set RTL_DIR .
set FILELIST ${RTL_DIR}/filelist_synth.f
set SDC ${RTL_DIR}/constraints.sdc

# TODO: 請改成你的實際製程 db/lib 路徑
set LIB_SETUP "/path/to/your/lib_setup.tcl"
if {[file exists $LIB_SETUP]} {
  source $LIB_SETUP
}

read_hdl -f $FILELIST
elaborate $TOP
check_design -all

read_sdc $SDC

syn_generic
syn_map
syn_opt

report_area > reports_genus_area.rpt
report_timing > reports_genus_timing.rpt
report_power > reports_genus_power.rpt

write_hdl > ${TOP}_syn.v
write_sdc > ${TOP}_syn.sdc
write_design -innovus ${TOP}_syn

quit

