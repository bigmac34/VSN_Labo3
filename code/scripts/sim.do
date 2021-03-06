
# !/usr/bin/tclsh

# Main proc at the end #

#------------------------------------------------------------------------------
proc compile_duv { } {
  global Path_DUV
  puts "\nVHDL DUV compilation :"

  vcom $Path_DUV/spike_detection_pkg.vhd
  vcom $Path_DUV/log_pkg.vhd
  vcom $Path_DUV/fifo.vhd
  vcom $Path_DUV/spike_detection.vhd
}

#------------------------------------------------------------------------------
proc compile_tb { } {
  global Path_TB
  global Path_DUV
  puts "\nVHDL TB compilation :"

  vcom -work common_lib  -2008 $Path_TB/common_lib/logger_pkg.vhd
  vcom -work common_lib  -2008 $Path_TB/common_lib/common_ctx.vhd

  vcom -work project_lib -2008 $Path_TB/project_logger_pkg.vhd
  vcom -work project_lib -2008 $Path_TB/project_ctx.vhd

  vcom -2008 $Path_TB/constant_pkg.vhd
  vcom -2008 $Path_TB/transactions_pkg.vhd
  vcom -2008 $Path_TB/transaction_fifo_pkg.vhd
  vcom -2008 $Path_TB/agent0_pkg.vhd
  vcom -2008 $Path_TB/agent1_pkg.vhd
  vcom -2008 $Path_TB/scoreboard_pkg.vhd
  vcom -2008 $Path_TB/spike_detection_tb.vhd

}

#------------------------------------------------------------------------------
proc sim_start {TESTCASE ERRNO} {

  vsim -t 1ns -novopt  -GTESTCASE=$TESTCASE -GERRNO=$ERRNO work.spike_detection_tb
  do ../scripts/wave.do
#  add wave -r *
  wave refresh
  run -all
}

#------------------------------------------------------------------------------
proc do_all {TESTCASE ERRNO} {
  compile_duv
  compile_tb
  sim_start $TESTCASE $ERRNO
}

## MAIN #######################################################################

# Compile folder ----------------------------------------------------
if {[file exists work] == 0} {
  vlib work
}

vlib tlmvm
vmap tlmvm ../tlmvm
##vmap tlmvm tlmvm

puts -nonewline "  Path_VHDL => "
set Path_DUV     "../src"
set Path_TB       "../src_tb"

global Path_DUV
global Path_TB

# start of sequence -------------------------------------------------

if {$argc>0} {
  if {[string compare $1 "all"] == 0} {
    do_all 1 0
  } elseif {[string compare $1 "comp_duv"] == 0} {
    compile_duv
  } elseif {[string compare $1 "comp_tb"] == 0} {
    compile_tb
  } elseif {[string compare $1 "sim"] == 0} {
    sim_start 1 $2
  }

} else {
  do_all 1 0
}
