/*
*  File            :   gpio_monitor.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.15
*  Language        :   SystemVerilog
*  Description     :   This is gpio monitor class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "../../rtl/periphery/gpio/gpio.svh"

import test_pkg::*;

class gpio_monitor;

    virtual gpio_if     gpio_if_;

    string              name = "";

    function new(string name="");
        this.name = name;
    endfunction : new

    function build_phase(virtual gpio_if gpio_if_);
        this.gpio_if_ = gpio_if_;
    endfunction : build_phase

    task run_phase();
    endtask : run_phase

endclass : gpio_monitor
