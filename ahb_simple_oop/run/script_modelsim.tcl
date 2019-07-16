if [file exists "work"] {vdel -all}
vlib work
# compile rtl design files
vlog -f ../run/rtl.f
# compile testbench files
vlog -f ../run/tb.f

vsim -novopt -assertdebug work.ahb_tb +UVM_TESTNAME=system_test
# add waves
add wave -position insertpoint sim:/ahb_tb/uart_if_0/*
add wave -position insertpoint sim:/ahb_tb/s_if_0/*
add wave -position insertpoint sim:/ahb_tb/pwm_if_0/*
add wave -position insertpoint sim:/ahb_tb/gpio_if_1/*
add wave -position insertpoint sim:/ahb_tb/gpio_if_0/*

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
# run simulation
run -all

quit 