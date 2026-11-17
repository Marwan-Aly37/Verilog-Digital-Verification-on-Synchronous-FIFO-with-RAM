vlib work
vlog +define+SIM shared_pkg.sv FIFO_transaction_dataPackage.sv FIFO_coverage_dataPackage.sv FIFO_scoreboard_dataPackage.sv FIFO_interface.sv FIFO_top.sv FIFO.sv FIFO_testbench.sv FIFO_monitor.sv +cover -covercells
vsim -voptargs=+acc -classdebug work.FIFO_top -cover
view wave
add wave -r /FIFO_top/*
coverage save FIFO_top.ucdb -onexit
run 0
run -all

vcover report FIFO_top.ucdb -details -annotate -all -output FIFO_rpt.txt
