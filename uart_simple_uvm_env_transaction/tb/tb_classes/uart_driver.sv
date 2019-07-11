/*
*  File            :   uart_driver.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.28
*  Language        :   SystemVerilog
*  Description     :   This is uart driver class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import uart_pkg::*;

// class uart driver
class uart_driver extends uvm_component;
    `uvm_component_utils(uart_driver)

    uvm_get_port    #(uart_cd)  drv_port;

    virtual uart_if             uart_if_;

    string                      name = "";

    integer                     cycle = 0;
    integer                     rep_c = -1;

    function new (string name, uvm_component parent);
        super.new(name, parent);
        this.name = name;
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual uart_if)::get(null, "*","uart_if_", uart_if_))
            $fatal("Failed to get uart_if_");
        drv_port = new("drv_port",this);
    endfunction : build_phase

    task print_info( uart_cd uart_cd_ );
        $display("[ Info  ] | %h | %s | Tx data    | 0x%h" , cycle , name , uart_cd_.tx_data);
        $display("[ Info  ] | %h | %s | comp       | %1d"  , cycle , name , uart_cd_.comp);
        $display("[ Info  ] | %h | %s | Stop bits  | %s\n" , cycle , name , uart_cd_.stop_sel == 2'b00 ? "0.5 bits" : 
                                                                            uart_cd_.stop_sel == 2'b01 ? "1 bit   " : 
                                                                            uart_cd_.stop_sel == 2'b10 ? "1.5 bits" : 
                                                                                                         "2 bits  " );
    endtask : print_info

    task run_phase(uvm_phase phase);
        uart_cd     uart_cd_;
        
        repeat(20)//forever
        begin
            drv_port.get(uart_cd_);
            cycle++;
            this.print_info(uart_cd_);
            uart_if_.tr_en = '1;
            uart_if_.stop_sel = uart_cd_.stop_sel;
            uart_if_.tx_data = uart_cd_.tx_data;
            uart_if_.comp = uart_cd_.comp;
            uart_if_.req = '1;
            @(posedge uart_if_.req_ack);
            uart_if_.req = '0;
            @(posedge uart_if_.clk);
            uart_if_.tr_en = '0;
        end

    endtask : run_phase

endclass : uart_driver