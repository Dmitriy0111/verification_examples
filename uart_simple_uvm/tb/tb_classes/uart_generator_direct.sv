/*
*  File            :   uart_generator_direct.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.09
*  Language        :   SystemVerilog
*  Description     :   This is uart generator class for uart transmitter unit (with random)
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import uart_pkg::*;

// class uart generator
class uart_generator_direct extends uart_btc;

    uart_cd             uart_cd_;

    uart_transactor     uart_transactor_;

    integer             f_d;

    function new( string name_i = "" , virtual uart_if uart_if_ , integer work_freq_i = 50000000 );
        super.new(uart_if_);
        uart_transactor_ = new(work_freq_i, "[ UART transactor ]");
        this.name = name_i;
        f_d = $fopen("../tb/uart_direct.txt", "r");
        if( !f_d )
            $stop;
    endfunction : new

    task build( mailbox mbx_i[] = null, event synch_i[] = null, event dis_ev = null );
        this.mbx          = new[mbx_i.size()];
        foreach(mbx[i])
            this.mbx[i]   = mbx_i[i];
        this.synch        = new[synch_i.size()];
        foreach(synch[i])
            this.synch[i] = synch_i[i];
        this.dis_ev = dis_ev;
    endtask : build

    task print_info();
        $display("[ Info  ] | %h | %s | Work freq  | %1d"  , cycle , name , uart_transactor_.work_freq);
        $display("[ Info  ] | %h | %s | Tx data    | 0x%h" , cycle , name , uart_transactor_.tx_data);
        $display("[ Info  ] | %h | %s | Baudrate   | %1d"  , cycle , name , uart_transactor_.work_freq / uart_transactor_.comp );
        $display("[ Info  ] | %h | %s | comp       | %1d"  , cycle , name , uart_transactor_.comp);
        $display("[ Info  ] | %h | %s | Stop bits  | %s\n" , cycle , name , uart_transactor_.stop_sel == 2'b00 ? "0.5 bits" : 
                                                                            uart_transactor_.stop_sel == 2'b01 ? "1 bit   " : 
                                                                            uart_transactor_.stop_sel == 2'b10 ? "1.5 bits" : 
                                                                                                                 "2 bits  " );
    endtask : print_info

    task read_data();
        $fscanf(f_d, "%h %d %d", uart_transactor_.tx_data, uart_transactor_.stop_sel, uart_transactor_.comp);
        uart_cd_.tx_data = uart_transactor_.tx_data;
        uart_cd_.stop_sel = uart_transactor_.stop_sel;
        uart_cd_.comp = uart_transactor_.comp;
    endtask : read_data

    task run();
        forever
        begin
            wait(synch[0].triggered);
            read_data();
            cycle++;
            this.print_info();
            mbx[1].put(uart_cd_);
            ->synch[1];
            mbx[2].put(uart_cd_);
            ->synch[2];
            if( ( rep_c != -1 ) && ( cycle == rep_c ) )
                -> dis_ev;
            @(posedge uart_if_.clk);
        end
    endtask : run

endclass : uart_generator_direct