file delete -force work
vlib work
vmap work work
ln -s /mnt/hgfs/VSN/Labos/labo3_spikeonchip/visualisation/tlmvm
vcom -2008 /mnt/hgfs/VSN/Labos/labo3_spikeonchip/visualisation/src/spike_detection_pkg.vhd
vcom -2008 /mnt/hgfs/VSN/Labos/labo3_spikeonchip/visualisation/src/log_pkg.vhd
vcom -2008 /mnt/hgfs/VSN/Labos/labo3_spikeonchip/visualisation/src/fifo.vhd
vcom -2008 /mnt/hgfs/VSN/Labos/labo3_spikeonchip/visualisation/src/spike_detection.vhd
vcom -2008 /mnt/hgfs/VSN/Labos/labo3_spikeonchip/visualisation/src_tb/transactions_pkg.vhd
vcom -2008 /mnt/hgfs/VSN/Labos/labo3_spikeonchip/visualisation/src_tb/transaction_fifo_pkg.vhd
vcom -2008 /mnt/hgfs/VSN/Labos/labo3_spikeonchip/visualisation/src_tb/agent0_pkg.vhd
vcom -2008 /mnt/hgfs/VSN/Labos/labo3_spikeonchip/visualisation/src_tb/agent1_pkg.vhd
vcom -2008 /mnt/hgfs/VSN/Labos/labo3_spikeonchip/visualisation/src_tb/scoreboard_pkg.vhd
vcom -2008 /mnt/hgfs/VSN/Labos/labo3_spikeonchip/visualisation/src_tb/spike_detection_tb.vhd
vsim -GERRNO=11 work.spike_detection_tb
run -all
coverage attribute -name ERRNO -value dirtest11
coverage save ../dirtest11.ucdb
