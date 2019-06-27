   
vlog ../rtl/*.sv
vlog ../rtl/uart/*.sv
vlog ../tb/*.sv

#vopt +acc=a counter_tb -o dbgver

set test "counter_tb"
set test "register_tb"
set test "uart_transmitter_tb"

if {$test == "counter_tb"} {
    vsim -novopt -assertdebug work.counter_tb

    add wave -position insertpoint sim:/counter_tb/*
    add wave -position insertpoint sim:/counter_tb/counter_0/*

    add wave /counter_tb/counter_0/inc_assert
    add wave /counter_tb/counter_0/dec_assert
} elseif {$test == "register_tb"} {
    vsim -novopt -assertdebug work.register_tb

    add wave -position insertpoint sim:/register_tb/*
    add wave -position insertpoint sim:/register_tb/register_0/*

    add wave /register_tb/register_0/rs_work_assert
    add wave /register_tb/register_0/we_work_assert
    add wave /register_tb/register_0/dc_unknown_assert
} elseif {$test == "uart_transmitter_tb"} {
    vsim -novopt -assertdebug work.uart_transmitter_tb

    add wave -position insertpoint sim:/uart_transmitter_tb/*
    add wave -position insertpoint sim:/uart_transmitter_tb/uart_transmitter_0/*
}


run -all

wave zoom full

#quit
