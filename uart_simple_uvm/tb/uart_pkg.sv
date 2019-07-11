/*
*  File            :   uart_pkg.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.28
*  Language        :   SystemVerilog
*  Description     :   This is uart package
*  Copyright(c)    :   2019 Vlasov D.V.
*/

package uart_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

    /*****************************************************
    **  UART transactor class                           **
    *****************************************************/
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

        covergroup uart_transactor_cg with function sample();
            stop_sel_cp : coverpoint stop_sel
                {
                    bins stop_sel_bin[]        = { [0 : 3] };
                }
            baudrate_cp : coverpoint baudrate
                {
                    bins standart_baudrate_bin[] = baudrate_l;
                }
            tx_data_cp : coverpoint tx_data
                {
                    bins tx_data_bins[16]      = { [0 : 255] };
                }
            cross stop_sel_cp , baudrate_cp;
        endgroup : uart_transactor_cg

        function new(integer work_freq_i, string name_i = "" );
            this.work_freq = work_freq_i;
            uart_transactor_cg = new;
        endfunction : new

    endclass : uart_transactor

    typedef struct packed 
    {
        logic   [7  : 0]    tx_data;
        logic   [15 : 0]    comp;
        logic   [1  : 0]    stop_sel;
    } uart_cd;  // uart control/data

`include "uart_generator_rand.sv"
`include "uart_generator_direct.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"
`include "uart_scoreboard.sv"
`include "uart_coverage.sv"
`include "uart_test_rand.sv"
`include "uart_test_direct.sv"

endpackage : uart_pkg