/*
*  File            :   uart_pkg.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.28
*  Language        :   SystemVerilog
*  Description     :   This is uart package
*  Copyright(c)    :   2019 Vlasov D.V.
*/

package uart_pkg;

    /*****************************************************
    **  UART base test class                            **
    *****************************************************/
    class uart_btc;

        string              name = "";
        // mailboxes
        mailbox             mbx[];
        // events
        event               synch[];

        process             env_th;

        event               dis_ev;

        integer             cycle = 0;
        integer             rep_c = -1;
        // interface
        virtual uart_if     uart_if_;

        function new(virtual uart_if uart_if_);
            this.uart_if_ = uart_if_;
        endfunction : new

        virtual task run();
        endtask : run

        virtual task build( mailbox mbx_i[] = null, event synch_i[] = null, event dis_ev = null );
        endtask : build
        
    endclass : uart_btc

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

`include "tb_classes/uart_generator.sv"
`include "tb_classes/uart_driver.sv"
`include "tb_classes/uart_monitor.sv"
`include "tb_classes/uart_scoreboard.sv"
`include "tb_classes/uart_enviroment.sv"

endpackage : uart_pkg