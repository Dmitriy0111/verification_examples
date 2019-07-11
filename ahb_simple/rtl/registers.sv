/*
*  File            :   register.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.11
*  Language        :   SystemVerilog
*  Description     :   This is file with registers modules
*  Copyright(c)    :   2019 Vlasov D.V.
*/

// simple register with reset and clock 
module register
#(
    parameter                       width = 1
)(
    input   logic   [0       : 0]   clk,    // clk
    input   logic   [0       : 0]   resetn, // resetn
    input   logic   [width-1 : 0]   datai,  // input data
    output  logic   [width-1 : 0]   datao   // output data
);

    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            datao <= '0;
        else
            datao <= datai;

endmodule : register

// register with write enable input
module register_we
#(
    parameter                       width = 1
)(
    input   logic   [0       : 0]   clk,    // clk
    input   logic   [0       : 0]   resetn, // resetn
    input   logic   [0       : 0]   we,     // write enable
    input   logic   [width-1 : 0]   datai,  // input data
    output  logic   [width-1 : 0]   datao   // output data
);

    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            datao <= '0;
        else if( we )
            datao <= datai;

endmodule : register_we

// register with write enable input and not zero reset value
module register_we_r
#(
    parameter                       width = 1,
                                    rst_val = '0
)(
    input   logic   [0       : 0]   clk,    // clk
    input   logic   [0       : 0]   resetn, // resetn
    input   logic   [0       : 0]   we,     // write enable
    input   logic   [width-1 : 0]   datai,  // input data
    output  logic   [width-1 : 0]   datao   // output data
);

    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            datao <= rst_val;
        else if( we )
            datao <= datai;

endmodule : register_we_r

// register with clr input
module register_clr
#(
    parameter                       width = 1
)(
    input   logic   [0       : 0]   clk,    // clk
    input   logic   [0       : 0]   resetn, // resetn
    input   logic   [0       : 0]   clr,    // clear register
    input   logic   [width-1 : 0]   datai,  // input data
    output  logic   [width-1 : 0]   datao   // output data
);

    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            datao <= '0;
        else
            datao <= clr ? '0 : datai;

endmodule : register_clr

// register with clr and we input's
module register_we_clr
#(
    parameter                       width = 1
)(
    input   logic   [0       : 0]   clk,    // clk
    input   logic   [0       : 0]   resetn, // resetn
    input   logic   [0       : 0]   we,     // write enable
    input   logic   [0       : 0]   clr,    // clear register
    input   logic   [width-1 : 0]   datai,  // input data
    output  logic   [width-1 : 0]   datao   // output data
);

    always_ff @(posedge clk, negedge resetn)
        if( !resetn )
            datao <= '0;
        else if( we )
            datao <= clr ? '0 : datai;

endmodule : register_we_clr
