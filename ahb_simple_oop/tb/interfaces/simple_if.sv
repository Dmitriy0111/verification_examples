/*
*  File            :   simple_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.15
*  Language        :   SystemVerilog
*  Description     :   This is simple interface
*  Copyright(c)    :   2019 Vlasov D.V.
*/

interface simple_if;

    logic   [0  : 0]    clk;
    logic   [0  : 0]    resetn;

    logic   [31 : 0]    addr;       // address memory
    logic   [31 : 0]    rd;         // read memory
    logic   [31 : 0]    wd;         // write memory
    logic   [0  : 0]    we;         // write enable signal
    logic   [1  : 0]    size;       // size for load/store instructions
    logic   [0  : 0]    req;        // request memory signal
    logic   [0  : 0]    req_ack;    // request acknowledge memory signal

endinterface : simple_if
