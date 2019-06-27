/*
*  File            :   register_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.27
*  Language        :   SystemVerilog
*  Description     :   This is testbench for register
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module register_tb();

    timeprecision       1ns;
    timeunit            1ns;
    
    parameter           T = 10,
                        resetn_delay = 7,
                        repeat_cycles = 400;

    localparam          width = 8;

    integer                 error_c = 0;

    //reset and clock
    bit     [0       : 0]   clk;        // clock
    bit     [0       : 0]   resetna;    // reset async
    bit     [0       : 0]   resetns;    // reset sync
    //register side
    logic   [width-1 : 0]   datai;      // input data
    logic   [width-1 : 0]   datao;      // output data
    logic   [0       : 0]   we;         // write enable

    register 
    #(
        .width      ( width     )   // data width
    )
    register_0
    (
        //reset and clock
        .clk        ( clk       ),  // clock
        .resetna    ( resetna   ),  // reset async
        .resetns    ( resetns   ),  // reset sync
        //register side
        .datai      ( datai     ),  // input data
        .datao      ( datao     ),  // output data
        .we         ( we        )   // write enable
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
        resetna = '1;
        resetns = '1;
    end
    //  
    initial
    begin
        datai = '0;
        we = '0;
        @(posedge resetna);
        @(posedge clk);
        $display("Testing sync reset");
        $display("[ Start ]");
        repeat(repeat_cycles)
        begin
            datai = $random();
            we = $random();
            resetns = $random();
            @(posedge clk);
        end
        $display("[ Stop  ]");
        datai = '0;
        we = '0;
        $stop;
    end

endmodule : register_tb
