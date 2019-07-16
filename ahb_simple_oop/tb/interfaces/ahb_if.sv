/*
*  File            :   ahb_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.15
*  Language        :   SystemVerilog
*  Description     :   This is ahb interface
*  Copyright(c)    :   2019 Vlasov D.V.
*/

interface ahb_if #(parameter if_n = 1);

    // Interface signals
    // clock and reset
    logic               [0  : 0]    hclk;       // hclock
    logic               [0  : 0]    hresetn;    // hresetn
    // ahb signals
    logic   [if_n-1 : 0][31 : 0]    haddr;      // AHB HADDR
    logic   [if_n-1 : 0][31 : 0]    hwdata;     // AHB HWDATA
    logic   [if_n-1 : 0][31 : 0]    hrdata;     // AHB HRDATA
    logic   [if_n-1 : 0][0  : 0]    hwrite;     // AHB HWRITE
    logic   [if_n-1 : 0][1  : 0]    htrans;     // AHB HTRANS
    logic   [if_n-1 : 0][2  : 0]    hsize;      // AHB HSIZE
    logic   [if_n-1 : 0][2  : 0]    hburst;     // AHB HBURST
    logic   [if_n-1 : 0][1  : 0]    hresp;      // AHB HRESP
    logic   [if_n-1 : 0][0  : 0]    hready;     // AHB HREADYOUT
    logic   [if_n-1 : 0][0  : 0]    hsel;       // AHB HSEL

endinterface : ahb_if
