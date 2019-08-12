/*
*  File            :   uart_monitor.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.28
*  Language        :   SystemVerilog
*  Description     :   This is uart monitor class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

// class uart monitor
class uart_monitor extends uart_btc;

    uart_cd             uart_cd_;

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

    task print_info();
        $display("[ Info  ] | %h | %s | Tx data    | 0x%h\n" , cycle , name , uart_cd_.tx_data);
    endtask : print_info

    task run();
        forever
        begin
            @(negedge uart_if_.uart_tx);
            repeat(uart_if_.comp) @(posedge uart_if_.clk);    // start
            repeat(8)                       // data
            begin
                repeat(uart_if_.comp)
                begin
                    uart_tx_c += uart_if_.uart_tx;
                    @(posedge uart_if_.clk);
                end
                uart_cd_.tx_data = { ( uart_tx_c > ( uart_if_.comp >> 1 ) ) , uart_cd_.tx_data[7 : 1] };
                uart_tx_c = '0;
            end
            repeat(uart_if_.stop_sel)
            begin
                repeat( uart_if_.comp / 2 )
                begin
                    if( uart_if_.uart_tx == '0 )
                        uart_tx_c++;
                    @(posedge uart_if_.clk);
                end
            end
            cycle++;
            if( uart_tx_c > ( uart_if_.comp / 10 ) )
                $display("[ Error ] | %h | %s | Stop bits count error!", cycle, name );
            this.print_info();
            mbx[0].put(uart_cd_);
            ->synch[0];
            if( ( rep_c != -1 ) && ( cycle == rep_c ) )
                -> dis_ev;
        end
    endtask : run

endclass : uart_monitor