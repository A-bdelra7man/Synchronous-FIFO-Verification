vlib work
vlog -f src_files +define+SIM +cover -covercells
vsim -voptargs=+acc top -cover
add wave -position insertpoint sim:/top/intf/*
coverage save top.ucdb -onexit
run 0
run -all