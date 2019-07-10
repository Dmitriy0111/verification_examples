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
class uart_generator_rand extends uart_base_generator;

    `uvm_component_utils(uart_generator_rand)

    function new (string name, uvm_component parent);
        super.new(name, parent);
        this.name = name;
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual uart_if)::get(null, "*","uart_if_", uart_if_))
            $fatal("Failed to get uart_if_");
        drv_port = new("drv_port",this);
        scb_port = new("scb_port",this);
        uart_transactor_ = new(50000000, "[ UART transactor ]");
        uart_transactor_.en_real_br;
    endfunction : build_phase

    function void settings();
        
    endfunction : settings

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

    function uart_cd get_data();

        uart_cd ret_data;

        uart_transactor_.rand_make();
        cycle++;
        this.print_info();
        ret_data.tx_data = uart_transactor_.tx_data;
        ret_data.stop_sel = uart_transactor_.stop_sel;
        ret_data.comp = uart_transactor_.comp;

        return ret_data;

    endfunction : get_data

endclass : uart_generator_rand