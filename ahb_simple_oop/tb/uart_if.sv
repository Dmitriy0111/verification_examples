/*
*  File            :   uart_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.15
*  Language        :   SystemVerilog
*  Description     :   This is pwm interface
*  Copyright(c)    :   2019 Vlasov D.V.
*/

interface uart_if;

    // clock and reset
    logic   [0 : 0]     clk;        // clock
    logic   [0 : 0]     resetn;     // resetn
    // GPIO side
    logic   [0 : 0]     uart_tx;    // UART tx wire
    logic   [0 : 0]     uart_rx;    // UART rx wire

endinterface : uart_if
