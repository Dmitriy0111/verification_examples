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
class uart_driver extends uart_btc;

    uart_cd             uart_cd_;

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

    task print_info();
        $display("[ Info  ] | %h | %s | Tx data    | 0x%h" , cycle , name , uart_cd_.tx_data);
        $display("[ Info  ] | %h | %s | comp       | %1d"  , cycle , name , uart_cd_.comp);
        $display("[ Info  ] | %h | %s | Stop bits  | %s\n" , cycle , name , uart_cd_.stop_sel == 2'b00 ? "0.5 bits" : 
                                                                            uart_cd_.stop_sel == 2'b01 ? "1 bit   " : 
                                                                            uart_cd_.stop_sel == 2'b10 ? "1.5 bits" : 
                                                                                                         "2 bits  " );
    endtask : print_info

    task run();
        forever
        begin
            ->synch[0];
            wait(synch[1].triggered);
            mbx[1].get(uart_cd_);
            cycle++;
            this.print_info();

            uart_if_.stop_sel = uart_cd_.stop_sel;
            uart_if_.tx_data = uart_cd_.tx_data;
            uart_if_.comp = uart_cd_.comp;
            uart_if_.req = '1;
            @(posedge uart_if_.req_ack);
            uart_if_.req = '0;
            @(posedge uart_if_.clk);
            if( ( rep_c != -1 ) && ( cycle == rep_c ) )
                -> dis_ev;
        end
    endtask : run

endclass : uart_driver