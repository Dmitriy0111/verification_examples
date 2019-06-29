/*
*  File            :   uart_transmitter_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.28
*  Language        :   SystemVerilog
*  Description     :   This is testbench for uart_transmitter
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module uart_transmitter_tb();

    timeprecision       1ns;
    timeunit            1ns;

    import uart_pkg::*;
    
    parameter           T = 10,
                        resetn_delay = 7,
                        repeat_cycles = 400;

    uart_if             uart_if_();

    uart_transmitter 
    uart_transmitter_0
    (
        // reset and clock
        .clk        ( uart_if_.clk      ),  // clk
        .resetn     ( uart_if_.resetn   ),  // resetn
        // controller side interface
        .tr_en      ( uart_if_.tr_en    ),  // transmitter enable
        .comp       ( uart_if_.comp     ),  // compare input for setting baudrate
        .tx_data    ( uart_if_.tx_data  ),  // data for transfer
        .req        ( uart_if_.req      ),  // request signal
        .stop_sel   ( uart_if_.stop_sel ),  // stop select
        .req_ack    ( uart_if_.req_ack  ),  // acknowledgent signal
        // uart tx side
        .uart_tx    ( uart_if_.uart_tx  )   // UART tx wire
    );

    uart_enviroment uart_enviroment_;

    // start simulation
    initial
    begin
        uart_enviroment_ = new(uart_if_);
        uart_enviroment_.build();
        uart_enviroment_.run(resetn_delay, T);
    end

endmodule : uart_transmitter_tb
