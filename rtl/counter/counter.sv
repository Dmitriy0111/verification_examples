/* 
*  File            :   nf_register.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.26
*  Language        :   SystemVerilog
*  Description     :   This is counter example
*  Copyright(c)    :   2019 Vlasov D.V.
*/ 

module counter
#(
    parameter                       width = 8
)(
    input   logic   [0       : 0]   clk,        // clock
    input   logic   [0       : 0]   resetn,     // reset
    input   logic   [0       : 0]   inc,        // counter increment
    input   logic   [0       : 0]   dec,        // counter decrement
    output  logic   [width-1 : 0]   c_out       // counter out
);

    logic   [width-1 : 0]   count;  // internal counter

    assign c_out = count;

    always_ff @(posedge clk, negedge resetn)
    begin : count_ff
        if( !resetn )
            count <= '0;
        else
            count <= count + ( dec ? -1 : 0 ) + ( inc ? 1 : 0 );
    end : count_ff

    property inc_prop;
        @(negedge clk) disable iff( !resetn ) ( inc and ( count == $past(count) + 1 ) )
    endproperty : inc_prop

    property dec_prop;
        @(negedge clk) disable iff( !resetn ) ( dec and ( count == $past(count) - 1 ) )
    endproperty : dec_prop

    inc_assert: assert property( inc_prop ) else $error("[Error] Increment fail!");
    dec_assert: assert property( dec_prop ) else $error("[Error] Decrement fail!");

endmodule : counter
