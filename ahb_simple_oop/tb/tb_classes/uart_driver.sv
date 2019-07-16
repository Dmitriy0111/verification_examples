/*
*  File            :   uart_driver.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.16
*  Language        :   SystemVerilog
*  Description     :   This is uart driver class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "../../rtl/periphery/gpio/gpio.svh"

import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::*;

class uart_driver #(parameter string if_name = "") extends uvm_component;
    `uvm_component_utils(uart_driver)

    virtual uart_if     uart_if_;

    string              name = "";

    function new (string name, uvm_component parent);
        super.new(name, parent);
        this.name = name;
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual uart_if)::get(null, "*",if_name, uart_if_))
            $fatal("Failed to get %s",if_name);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        uart_if_.uart_rx = '1;
    endtask : run_phase

endclass : uart_driver
