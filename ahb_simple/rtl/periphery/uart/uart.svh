/*
*  File            :   uart.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.11
*  Language        :   SystemVerilog
*  Description     :   This is UART module header file
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef UART_DEFS
`define UART_DEFS

    typedef struct packed
    {
        logic   [3  : 0]    UN;     // unused
        logic   [0  : 0]    RX_EN;  // receiver enable
        logic   [0  : 0]    TX_EN;  // transmitter enable
        logic   [0  : 0]    RX_VAL; // rx byte received
        logic   [0  : 0]    TX_REQ; // request transmit
    } UCR;  // uart control reg

    typedef struct packed
    {
        logic   [15 : 0]    COMP;   // data for comparing
    } UDVR;  // uart divide reg

    typedef struct packed
    {
        logic   [7  : 0]    DATA;   // data field
    } UDR;  // uart data register

    //constant's for uart module
    parameter UART_CR_R = 'h0;
    parameter UART_TX_R = 'h4;
    parameter UART_RX_R = 'h8;
    parameter UART_DR_R = 'hC;

    parameter UART_RX_EN  = 3;
    parameter UART_TX_EN  = 2;
    parameter UART_RX_VAL = 1;
    parameter UART_TX_REQ = 0;

`endif
