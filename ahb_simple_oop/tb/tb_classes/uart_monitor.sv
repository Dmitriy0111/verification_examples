/*
*  File            :   uart_monitor.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.15
*  Language        :   SystemVerilog
*  Description     :   This is uart monitor class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "../../rtl/periphery/uart/uart.svh"

import test_pkg::*;

class uart_monitor;

    virtual uart_if     uart_if_;

    string              name = "";

    function new(string name="");
        this.name = name;
    endfunction : new

    function build_phase(virtual uart_if uart_if_);
        this.uart_if_ = uart_if_;
    endfunction : build_phase

    task run_phase();
    endtask : run_phase

endclass : uart_monitor
