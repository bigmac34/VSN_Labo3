file delete -force work
vlib work
vcom /media/sf_VSN/Macchi/VSN_Labo3/visualisation/src/log_pkg.vhd
vcom /media/sf_VSN/Macchi/VSN_Labo3/visualisation/src/fifo.vhd
vcom /media/sf_VSN/Macchi/VSN_Labo3/visualisation/src/spike_detection.vhd
vcom /media/sf_VSN/Macchi/VSN_Labo3/visualisation/src_tb/spike_detection_tb.vhd
vsim -GERRNO=15 -GINPUT_FILE_NAME=/media/sf_VSN/Macchi/VSN_Labo3/visualisation/src_tb/input_values.txt work.spike_detection_tb
run -all
coverage attribute -name ERRNO -value dirtest15
coverage save ../dirtest15.ucdb
