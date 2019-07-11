if [file exists "work"] {vdel -all}
vlib work
# compile rtl design files
vlog -f ../run/rtl.f
# compile testbench files
vlog -f ../run/tb.f

vsim -novopt -assertdebug work.ahb_tb
# add waves
add wave -position insertpoint sim:/ahb_tb/*

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
# run simulation
run -all

quit 