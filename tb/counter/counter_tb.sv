/*
*  File            :   counter_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.26
*  Language        :   SystemVerilog
*  Description     :   This is testbench for counter
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module counter_tb();

    timeprecision       1ns;
    timeunit            1ns;
    
    parameter           T = 10,
                        resetn_delay = 7,
                        repeat_cycles = 400;

    localparam          width = 8;

    bit     [0       : 0]   clk;        // clock
    bit     [0       : 0]   resetn;     // reset
    bit     [0       : 0]   inc;        // counter increment
    bit     [0       : 0]   dec;        // counter decrement
    logic   [width-1 : 0]   c_out;      // counter out

    counter 
    #(
        .width  ( width     )
    )
    counter_0
    (
        .clk    ( clk       ),  // clock
        .resetn ( resetn    ),  // reset
        .inc    ( inc       ),  // counter increment
        .dec    ( dec       ),  // counter decrement
        .c_out  ( c_out     )   // counter out
    );
    // clock generation
    initial
    begin
        forever
            #(T/2) clk = ~clk;
    end
    // reset generation
    initial
    begin
        repeat(resetn_delay) @(posedge clk);
        resetn = '1;
    end
    // stop 
    initial
    begin
        @(posedge resetn);
        repeat(repeat_cycles) @(posedge clk);
        $stop;
    end
    //  
    initial
    begin
        inc = '1;
        dec = '0;
    end

endmodule : counter_tb
