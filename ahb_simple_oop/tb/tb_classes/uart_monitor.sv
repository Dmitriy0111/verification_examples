/*
*  File            :   uart_monitor.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.16
*  Language        :   SystemVerilog
*  Description     :   This is uart monitor class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "../../rtl/periphery/uart/uart.svh"

import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::*;

class uart_monitor #(parameter string if_name = "") extends uvm_component;
    `uvm_component_utils(uart_monitor)
    // uvm ports for connecting testbench classes
    uvm_get_port    #(logic [15 : 0])   drv_simple2uart_mon_port;
    uvm_put_port    #(logic [7  : 0])   uart_mon2scb_port;
    // uart settings
    integer                             baudrate = 0;
    // interface
    virtual uart_if                     uart_if_;
    // current name
    string                              name = "";
    // current cycle variable
    integer                             cycle = 0;
    // class constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        this.name = name;
    endfunction : new
    // uvm build phase
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual uart_if)::get(null, "*",if_name, uart_if_))
            $fatal("Failed to get %s",if_name);
        drv_simple2uart_mon_port = new("drv_simple2uart_mon_port",this);
        uart_mon2scb_port = new("uart_mon2scb_port", this);
    endfunction : build_phase
    // task for receiving data over uart
    task rec_uart();
        integer             uart_tx_c;
        logic   [7 : 0]     uart_rec_d;
        uart_tx_c = 0;
        @(negedge uart_if_.uart_tx);
        repeat(baudrate) @(posedge uart_if_.clk);   // start
        repeat(8)                                   // data
        begin
            repeat(baudrate)
            begin
                uart_tx_c += uart_if_.uart_tx;
                @(posedge uart_if_.clk);
            end
            uart_rec_d = { ( uart_tx_c > ( baudrate >> 1 ) ) , uart_rec_d[7 : 1] };
            uart_tx_c = '0;
        end
        repeat(baudrate)                            // stop
        begin
            if( uart_if_.uart_tx == '0 )
                uart_tx_c++;
            @(posedge uart_if_.clk);
        end
        cycle++;
        $display("[ Info  ] | %h | %s | Received data = 0x%h\n" , cycle , name , uart_rec_d);
        uart_mon2scb_port.put(uart_rec_d);
        uart_tx_c = '0;
    endtask : rec_uart
    // task for receiving setings (baudrate)
    task rec_settings();
        drv_simple2uart_mon_port.get(baudrate);
        $display("[ Info  ] | %h | %s | New baudrate = 0x%h\n" , cycle , name , baudrate);
    endtask : rec_settings
    // uvm run phase
    task run_phase(uvm_phase phase);
       
        forever
        fork
            this.rec_settings();
            this.rec_uart();
        join

    endtask : run_phase

endclass : uart_monitor
