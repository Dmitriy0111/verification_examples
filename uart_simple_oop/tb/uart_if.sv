/*
*  File            :   uart_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.28
*  Language        :   SystemVerilog
*  Description     :   This is uart interface
*  Copyright(c)    :   2019 Vlasov D.V.
*/

timeprecision       1ns;
timeunit            1ns;

interface uart_if;

    // Interface signals

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

    task make_reset(integer resetn_delay);
        resetn = '0;
        repeat(resetn_delay) @(posedge clk);
        resetn = '1;
    endtask : make_reset

    task make_clock(integer T);
        clk = '0;
        forever
            #(T/2) clk = !clk; 
    endtask : make_clock

    task clean_signals();
        $display("Signals clean");
        tr_en = '0;
        comp = '0;
        tx_data = '0;
        req = '0;
        stop_sel = '0;
        req_ack = '0;
    endtask : clean_signals

endinterface : uart_if