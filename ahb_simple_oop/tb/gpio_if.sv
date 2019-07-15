/*
*  File            :   gpio_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.15
*  Language        :   SystemVerilog
*  Description     :   This is gpio interface
*  Copyright(c)    :   2019 Vlasov D.V.
*/

interface gpio_if #(parameter gpio_w=8);

    // clock and reset
    logic   [0        : 0]  clk;        // clock
    logic   [0        : 0]  resetn;     // resetn
    // GPIO side
    logic   [gpio_w-1 : 0]  gpi;        // GPIO input
    logic   [gpio_w-1 : 0]  gpo;        // GPIO output
    logic   [gpio_w-1 : 0]  gpd;        // GPIO direction

endinterface : gpio_if
