/*
*  File            :   register.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.27
*  Language        :   SystemVerilog
*  Description     :   This is register with synchronious and asynchronious resets
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module register
#(
    parameter                       width = 8   // data width
)(
    //reset and clock
    input   logic   [0       : 0]   clk,        // clock
    input   logic   [0       : 0]   resetna,    // reset async
    input   logic   [0       : 0]   resetns,    // reset sync
    //register side
    input   logic   [width-1 : 0]   datai,      // input data
    output  logic   [width-1 : 0]   datao,      // output data
    input   logic   [0       : 0]   we          // write enable
);

    logic   [width-1 : 0]   int_reg;    // internal register
    
    assign datao = int_reg;
    
    always_ff @(posedge clk, negedge resetna)
    if( !resetna )
        int_reg <= '0;
    //else if( !resetns )
    //    int_reg <= '0;
    else if( we )
        int_reg <= datai;

    property rs_work;   // sync reset property
        @(posedge clk) ( !resetns ) |=> (datao == '0)
    endproperty

    property dc_unknown; // data or control unknown
        @(posedge clk) !$isunknown( { we , datao } )
    endproperty

    property we_work; // write enable working
        @(posedge clk) disable iff(!resetna) ( we ) |=> ( ( datao == $past(datai) ) || ( !$past( resetns ) && ( datao == '0 ) ) )
    endproperty

    rs_work_assert: assert property( rs_work ) else $error("[Error] Internal register not reset!");

    dc_unknown_assert: assert property( dc_unknown ) else $error("[Error] Data or control are unknown!");

    we_work_assert: assert property( we_work ) else $error("[Error] Internal register is'nt writing!");

endmodule : register
