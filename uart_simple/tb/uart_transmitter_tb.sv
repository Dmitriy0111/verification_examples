/*
*  File            :   uart_transmitter_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.28
*  Language        :   SystemVerilog
*  Description     :   This is simple testbench for uart_transmitter
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module uart_transmitter_tb();

    timeprecision       1ns;
    timeunit            1ns;
    // testbench settigns
    parameter           T = 10,
                        resetn_delay = 7,
                        repeat_cycles = 400,
                        work_freq = 500000000;

    // testbench signals
    // reset and clock
    logic   [0  : 0]    clk;        // clk
    logic   [0  : 0]    resetn;     // resetn
    // controller side interface
    logic   [0  : 0]    tr_en;      // transmitter enable
    logic   [15 : 0]    comp;       // compare input for setting baudrate
    logic   [7  : 0]    tx_data;    // data for transfer
    logic   [0  : 0]    req;        // request signal
    logic   [1  : 0]    stop_sel;   // stop select
    logic   [0  : 0]    req_ack;    // acknowledgent signal
    // uart tx side
    logic   [0  : 0]    uart_tx;    // UART tx wire

    // help variables
    integer             cycle = 0;      // cycle counter
    integer             uart_tx_c = 0;  // uart tx counter
    logic   [7  : 0]    uart_rec_d;     // uart receive data
    
    // creating one uart transmitter module DUT
    uart_transmitter 
    uart_transmitter_0
    (
        // reset and clock
        .clk        ( clk       ),  // clk
        .resetn     ( resetn    ),  // resetn
        // controller side interface
        .tr_en      ( tr_en     ),  // transmitter enable
        .comp       ( comp      ),  // compare input for setting baudrate
        .tx_data    ( tx_data   ),  // data for transfer
        .req        ( req       ),  // request signal
        .stop_sel   ( stop_sel  ),  // stop select
        .req_ack    ( req_ack   ),  // acknowledgent signal
        // uart tx side
        .uart_tx    ( uart_tx   )   // UART tx wire
    );

    // generate clock
    initial
    begin
        clk = '0;
        forever
            #(T/2) clk = !clk;
    end
    // generate reset
    initial
    begin
        resetn = '0;
        repeat( resetn_delay ) @(posedge clk);
        resetn = '1;
    end
    // generate test
    initial
    begin
        tr_en = '0;
        tx_data = '0;
        comp = '0;
        req = '0;
        stop_sel = '0;
        @(posedge resetn);
        tr_en = '1;
        repeat( repeat_cycles )
        begin
            gen_random();
            req = '1;
            @(posedge req_ack);
            req = '0;
            @(posedge clk);
        end
        $stop;
    end
    // receive data
    initial
    begin
        forever
        begin
            rec_uart();
            if( tx_data == uart_rec_d )
                $display("Pass");
            else
                $display("Fail");
        end
    end
    // task for generating random data
    task gen_random();
        cycle++;
        $display("Curent cycle = %0d", cycle);
        tx_data = $random;
        $display("tx data      = 0x%h", tx_data);
        stop_sel = $random;
        $display("stop sel     = %s",   stop_sel == 2'b00 ? "0.5 bits" : 
                                        stop_sel == 2'b01 ? "1 bit   " : 
                                        stop_sel == 2'b10 ? "1.5 bits" : 
                                                            "2 bits  ");
        case($urandom_range(0,4))
            0       :   begin comp = work_freq / 9600;      $display("baudrate     = %s", "9600  "); end
            1       :   begin comp = work_freq / 19200;     $display("baudrate     = %s", "19200 "); end
            2       :   begin comp = work_freq / 38400;     $display("baudrate     = %s", "38400 "); end
            3       :   begin comp = work_freq / 57600;     $display("baudrate     = %s", "57600 "); end
            4       :   begin comp = work_freq / 115200;    $display("baudrate     = %s", "115200"); end
            default :   begin comp = work_freq / 9600;      $display("baudrate     = %s", "9600  "); end
        endcase
        $display("");
    endtask : gen_random
    // task for receiving data over uart
    task rec_uart();
        @(negedge uart_tx);
        repeat(comp) @(posedge clk);    // start
        repeat(8)                       // data
        begin
            repeat(comp)
            begin
                uart_tx_c += uart_tx;
                @(posedge clk);
            end
            uart_rec_d = { ( uart_tx_c > ( comp >> 1 ) ) , uart_rec_d[7 : 1] };
            uart_tx_c = '0;
        end
        repeat(stop_sel)
        begin
            repeat( comp / 2 )
            begin
                if( uart_tx == '0 )
                    uart_tx_c++;
                @(posedge clk);
            end
        end
        if( uart_tx_c > ( comp / 10 ) )
            $display("[ Error ] Stop bits count error!");
        $display("Received data = 0x%h", uart_rec_d);
    endtask : rec_uart

endmodule : uart_transmitter_tb
