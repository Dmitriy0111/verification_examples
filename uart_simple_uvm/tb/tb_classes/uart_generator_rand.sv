/*
*  File            :   uart_generator_rand.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.09
*  Language        :   SystemVerilog
*  Description     :   This is uart generator class for uart transmitter unit (with random)
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import uart_pkg::*;

// class uart generator
class uart_generator_rand extends uvm_component;

    `uvm_component_utils(uart_generator_rand)

    uvm_put_port    #(uart_cd)  drv_port;
    uvm_put_port    #(uart_cd)  scb_port;

    virtual uart_if             uart_if_;

    string                      name = "";

    integer                     cycle = 0;
    integer                     rep_c = -1;

    uart_transactor             uart_transactor_;

    function new (string name, uvm_component parent);
        super.new(name, parent);
        uart_transactor_ = new(50000000, "[ UART transactor ]");
        this.name = name;
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual uart_if)::get(null, "*","uart_if_", uart_if_))
            $fatal("Failed to get uart_if_");
        drv_port = new("drv_port",this);
        scb_port = new("scb_port",this);
        uart_transactor_.en_real_br;
    endfunction : build_phase

    task print_info();
        $display("[ Info  ] | %h | %s | Work freq  | %1d"  , cycle , name , uart_transactor_.work_freq);
        $display("[ Info  ] | %h | %s | Tx data    | 0x%h" , cycle , name , uart_transactor_.tx_data);
        $display("[ Info  ] | %h | %s | Baudrate   | %1d"  , cycle , name , uart_transactor_.real_br ? uart_transactor_.baudrate : uart_transactor_.work_freq / uart_transactor_.comp );
        $display("[ Info  ] | %h | %s | comp       | %1d"  , cycle , name , uart_transactor_.comp);
        $display("[ Info  ] | %h | %s | Stop bits  | %s\n" , cycle , name , uart_transactor_.stop_sel == 2'b00 ? "0.5 bits" : 
                                                                            uart_transactor_.stop_sel == 2'b01 ? "1 bit   " : 
                                                                            uart_transactor_.stop_sel == 2'b10 ? "1.5 bits" : 
                                                                                                                 "2 bits  " );
    endtask : print_info

    task run_phase(uvm_phase phase);
        uart_cd     uart_cd_;
        repeat(20)//forever
        begin
            uart_transactor_.rand_make();
            cycle++;
            this.print_info();
            uart_cd_.tx_data = uart_transactor_.tx_data;
            uart_cd_.stop_sel = uart_transactor_.stop_sel;
            uart_cd_.comp = uart_transactor_.comp;
            drv_port.put(uart_cd_);
            scb_port.put(uart_cd_);
            @(posedge uart_if_.clk);
            //repeat(20000) @(posedge uart_if_.clk);
        end
    endtask : run_phase

endclass : uart_generator_rand