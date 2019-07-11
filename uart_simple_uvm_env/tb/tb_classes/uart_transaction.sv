/*
*  File            :   uart_transaction.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.09
*  Language        :   SystemVerilog
*  Description     :   This is uart transaction class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import uart_pkg::*;

// class uart generator
class uart_transaction extends uvm_transaction;
    `uvm_component_utils(uart_transaction)

    class uart_transactor;

        rand    logic   [7  : 0]    tx_data;
        rand    logic   [15 : 0]    comp;
        rand    logic   [1  : 0]    stop_sel;
        rand    integer             baudrate;
        rand    logic   [0  : 0]    real_br;

        integer                     work_freq;
        integer                     baudrate_l[5] = { 9600 , 19200 , 38400 , 57600 , 115200 };

        constraint tx_data_c
        {
            tx_data inside {[0 : 255]};
        }

        constraint stop_sel_c
        {
            stop_sel inside {[0 : 3]};
        }

        constraint real_br_on_c
        {
            real_br == '1;
        }

        constraint real_br_off_c
        {
            real_br == '0;
        }

        constraint comp_c
        {
            if( real_br == '1 )
                comp == work_freq / baudrate;
            else
                comp inside{ [6 : 65530] };
        }

        constraint baudrate_c
        {
            baudrate inside{ baudrate_l };
        }

        task edit_work_freq(integer new_work_freq);
            work_freq = new_work_freq;
        endtask : edit_work_freq
        // enable real baudrate
        task en_real_br();
            this.real_br_off_c.constraint_mode(0);
            this.real_br_on_c.constraint_mode(1);
        endtask : en_real_br
        // disable real baudrate
        task dis_real_br();
            this.real_br_off_c.constraint_mode(1);
            this.real_br_on_c.constraint_mode(0);
        endtask : dis_real_br
        // make random transaction
        task rand_make();
            assert(this.randomize()) else $display("[Error] Generation random transaction failed!" );
            uart_transactor_cg.sample;
        endtask : rand_make

        function new(integer work_freq_i, string name_i = "" );
            this.work_freq = work_freq_i;
            uart_transactor_cg = new;
        endfunction : new

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
        $display("[ Info  ] | %h | %s | Coverage   | %2.0f%%"  , cycle , name , uart_transactor_.get_cov());
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

endclass : uart_transaction