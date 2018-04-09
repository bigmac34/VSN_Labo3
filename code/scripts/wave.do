onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /spike_detection_tb/clk_sti
add wave -noupdate /spike_detection_tb/rst_sti
add wave -noupdate -childformat {{/spike_detection_tb/port0_input_sti.sample -radix decimal}} -expand -subitemconfig {/spike_detection_tb/port0_input_sti.sample {-format Analog-Step -height 84 -max 1849.9999999999998 -min -850.0 -radix decimal}} /spike_detection_tb/port0_input_sti
add wave -noupdate /spike_detection_tb/port0_output_obs
add wave -noupdate /spike_detection_tb/port1_output_obs
add wave -noupdate /spike_detection_tb/duv/clk_i
add wave -noupdate /spike_detection_tb/duv/rst_i
add wave -noupdate /spike_detection_tb/duv/sample_i
add wave -noupdate /spike_detection_tb/duv/sample_valid_i
add wave -noupdate /spike_detection_tb/duv/ready_o
add wave -noupdate /spike_detection_tb/duv/samples_spikes_o
add wave -noupdate /spike_detection_tb/duv/samples_spikes_valid_o
add wave -noupdate /spike_detection_tb/duv/spike_detected_o
add wave -noupdate /spike_detection_tb/duv/read_fifo_s
add wave -noupdate /spike_detection_tb/duv/fifo_count_s
add wave -noupdate /spike_detection_tb/duv/sample_s
add wave -noupdate /spike_detection_tb/duv/moving_average_s
add wave -noupdate /spike_detection_tb/duv/counter_sample_s
add wave -noupdate /spike_detection_tb/duv/det_ready_s
add wave -noupdate /spike_detection_tb/duv/sum_squared_s
add wave -noupdate /spike_detection_tb/duv/sample_squared_s
add wave -noupdate /spike_detection_tb/duv/sum_squared_div_s
add wave -noupdate /spike_detection_tb/duv/spike_s
add wave -noupdate /spike_detection_tb/duv/moving_average_squared_s
add wave -noupdate /spike_detection_tb/duv/standard_deviation_squared_s
add wave -noupdate /spike_detection_tb/duv/product_std_dev_factor_squared
add wave -noupdate /spike_detection_tb/duv/deviation_s
add wave -noupdate /spike_detection_tb/duv/dev_squared_s
add wave -noupdate /spike_detection_tb/duv/current_state_s
add wave -noupdate /spike_detection_tb/duv/next_state_s
add wave -noupdate /spike_detection_tb/duv/counter_stored_samples_s
add wave -noupdate /spike_detection_tb/duv/rst_counter_sample_s
add wave -noupdate /spike_detection_tb/duv/write_sample_s
add wave -noupdate /spike_detection_tb/duv/data_out_s
add wave -noupdate /spike_detection_tb/duv/counter_errno_s
add wave -noupdate /spike_detection_tb/duv/spike_detected_s
add wave -noupdate /spike_detection_tb/duv/fifo0/clk_i
add wave -noupdate /spike_detection_tb/duv/fifo0/rst_i
add wave -noupdate /spike_detection_tb/duv/fifo0/data_i
add wave -noupdate /spike_detection_tb/duv/fifo0/wr_en_i
add wave -noupdate /spike_detection_tb/duv/fifo0/full_o
add wave -noupdate /spike_detection_tb/duv/fifo0/data_o
add wave -noupdate /spike_detection_tb/duv/fifo0/rd_en_i
add wave -noupdate /spike_detection_tb/duv/fifo0/empty_o
add wave -noupdate /spike_detection_tb/duv/fifo0/count_o
add wave -noupdate /spike_detection_tb/duv/fifo0/counter_s
add wave -noupdate /spike_detection_tb/duv/fifo0/fifo_mem_s
add wave -noupdate /spike_detection_tb/duv/fifo0/head_s
add wave -noupdate /spike_detection_tb/duv/fifo0/tail_s
add wave -noupdate /spike_detection_tb/duv/fifo0/wr_s
add wave -noupdate /spike_detection_tb/duv/fifo0/rd_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15184635 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {31500158 ns}
