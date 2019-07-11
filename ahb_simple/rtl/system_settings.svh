/*
*  File            :   system_settings.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.11
*  Language        :   SystemVerilog
*  Description     :   This is system settings
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef SYSTEM_SETTINGS
`define SYSTEM_SETTINGS

    parameter SLAVE_COUNT = 4;

    /*  
        memory map for devices
    
        0x0000_0000\
                    \
                    GPIO_0
                    /
        0x0000_ffff/
        0x0001_0000\
                    \
                    GPIO_1
                    /
        0x0001_ffff/
        0x0002_0000\
                    \
                    PWM
                    /
        0x0002_ffff/
        0x0003_0000\
                    \
                    UART
                    /
        0x0003_ffff/
        0x0004_0000\
                    \
                    Unused
                    /
        0xffff_ffff/
    */

    parameter GPIO_0_ADDR_MATCH     = 32'h0000XXXX;    
    parameter GPIO_1_ADDR_MATCH     = 32'h0001XXXX;
    parameter PWM_ADDR_MATCH        = 32'h0002XXXX;
    parameter UART_ADDR_MATCH       = 32'h0003XXXX;

    parameter GPIO_0_ADDR_S         = 32'h00000000;    
    parameter GPIO_1_ADDR_S         = 32'h00010000;
    parameter PWM_ADDR_S            = 32'h00020000;
    parameter UART_ADDR_S           = 32'h00030000;

    parameter   logic   [0 : SLAVE_COUNT-1][31 : 0] ahb_vector = 
                                                                {
                                                                    GPIO_0_ADDR_MATCH,
                                                                    GPIO_1_ADDR_MATCH,
                                                                    PWM_ADDR_MATCH,
                                                                    UART_ADDR_MATCH
                                                                };

`endif