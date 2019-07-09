/*
*  File            :   uart_scoreboard.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.28
*  Language        :   SystemVerilog
*  Description     :   This is uart scoreboard class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import uart_pkg::*;

// class uart monitor
class uart_scoreboard extends uart_btc;

    uart_cd             uart_cd_0;
    uart_cd             uart_cd_1;

    uart_cd             uart_cd_from_generator[$];
    uart_cd             uart_cd_from_monitor[$];

    integer             uart_tx_c = 0;

    function new( string name_i = "" , virtual uart_if uart_if_ );
        super.new(uart_if_);
        this.name = name_i;
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

    task run();
        forever
        fork
            rec_from_uart_generator();
            rec_from_uart_monitor();
            compare_data();
        join
    endtask : run

    // synch[0] and mbx[0] from uart_generator
    // synch[1] and mbx[1] from uart_monitor

    task rec_from_uart_generator();
        wait(synch[0].triggered);
        mbx[0].get(uart_cd_0);
        uart_cd_from_generator.push_front(uart_cd_0);
    endtask : rec_from_uart_generator

    task rec_from_uart_monitor();
        wait(synch[1].triggered);
        mbx[1].get(uart_cd_1);
        uart_cd_from_monitor.push_front(uart_cd_1);
    endtask : rec_from_uart_monitor

    task compare_data();

        @( ( uart_cd_from_monitor.size != 0 ) && ( uart_cd_from_generator.size != 0 ) );
        cycle++;
        if( uart_cd_from_monitor.pop_front().tx_data == uart_cd_from_generator.pop_front().tx_data )
            $display("[ Info  ] | %h | %s | test pass\n" , cycle , name );
        else
            $display("[ Error ] | %h | %s | test fail\n" , cycle , name );

        if( ( rep_c != -1 ) && ( cycle == rep_c ) )
            -> dis_ev;
        
    endtask : compare_data

endclass : uart_scoreboard