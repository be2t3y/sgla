# TODO: 依你的製程替換以下 library
create_library_set -name LIB_BC -timing [list /path/to/stdcell_bc.lib]
create_library_set -name LIB_WC -timing [list /path/to/stdcell_wc.lib]

create_rc_corner -name RC_BEST
create_rc_corner -name RC_WORST

create_delay_corner -name DC_BC -library_set LIB_BC -rc_corner RC_BEST
create_delay_corner -name DC_WC -library_set LIB_WC -rc_corner RC_WORST

create_constraint_mode -name CON_FUNC -sdc_files [list constraints.sdc]

create_analysis_view -name AV_SETUP -constraint_mode CON_FUNC -delay_corner DC_WC
create_analysis_view -name AV_HOLD -constraint_mode CON_FUNC -delay_corner DC_BC

set_analysis_view -setup [list AV_SETUP] -hold [list AV_HOLD]

