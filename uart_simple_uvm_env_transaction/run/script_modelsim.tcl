if [file exists "work"] {vdel -all}
vlib work
# compile rtl design files
vlog -f ../run/rtl.f
# compile testbench design files
vlog -f ../run/tb.f

vsim -novopt -assertdebug work.uart_transmitter_tb +UVM_TESTNAME=uart_test_rand
# add waves
add wave -position insertpoint sim:/uart_transmitter_tb/uart_transmitter_0/*

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
# run simulation
run -all

vsim -novopt -assertdebug work.uart_transmitter_tb +UVM_TESTNAME=uart_test_direct
# add waves
add wave -position insertpoint sim:/uart_transmitter_tb/uart_transmitter_0/*

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
# run simulation
run -all

quit 
