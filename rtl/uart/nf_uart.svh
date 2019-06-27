/*
*  File            :   nf_uart.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.21
*  Language        :   SystemVerilog
*  Description     :   This is constants for uart module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`ifndef NF_UART_CONSTANTS
`define NF_UART_CONSTANTS 1

    typedef enum logic [3 : 0]
    {
        NF_UART_CR  =   4'h0,
        NF_UART_TX  =   4'h4,
        NF_UART_RX  =   4'h8,
        NF_UART_DR  =   4'hC
    } nf_uart_consts;  // uart constants

`endif
