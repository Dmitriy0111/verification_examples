/*
*  File            :   cdc.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.11
*  Language        :   SystemVerilog
*  Description     :   This is cross domain crossing module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

module cdc
(
    input   logic   [0 : 0]     resetn_1,   // first reset
    input   logic   [0 : 0]     resetn_2,   // second reset
    input   logic   [0 : 0]     clk_1,      // first clock
    input   logic   [0 : 0]     clk_2,      // second clock
    input   logic   [0 : 0]     we_1,       // first write enable
    input   logic   [0 : 0]     we_2,       // second write enable
    input   logic   [0 : 0]     data_1_in,  // first data input
    input   logic   [0 : 0]     data_2_in,  // second data input
    output  logic   [0 : 0]     data_1_out, // first data output
    output  logic   [0 : 0]     data_2_out, // second data output
    output  logic   [0 : 0]     wait_1,     // first wait
    output  logic   [0 : 0]     wait_2      // second wait
);

    logic   [0 : 0]     int_reg1;   // internal register 1
    logic   [0 : 0]     int_reg2;   // internal register 2
    logic   [0 : 0]     req_1;      // request 1
    logic   [0 : 0]     ack_1;      // request acknowledge 1
    logic   [0 : 0]     req_2;      // request 2
    logic   [0 : 0]     ack_2;      // request acknowledge 2

    assign wait_1 = req_1 || ack_2;
    assign wait_2 = req_2 || ack_1;

    assign data_1_out = int_reg1;
    assign data_2_out = int_reg2;

    always_ff @(posedge clk_1) 
    begin : write2first_reg
        if( !resetn_1 )
            int_reg1 <= '0;
        else
        begin
            if( we_1 )
                int_reg1 <= data_1_in;
            else if( req_2 )
                int_reg1 <= int_reg2;
        end
    end

    always_ff @(posedge clk_1) 
    begin : answer_first
        if( !resetn_1 )
            ack_1 <= '0;
        else 
            ack_1 <= req_2;
    end

    always_ff @(posedge clk_1) 
    begin : request_first
        if( !resetn_1 )
            req_1 <= '0;
        else 
        begin
            if( we_1 )
                req_1 <= '1;
            if( ack_2 == '1 )
                req_1 <= '0;
        end
    end

    always_ff @(posedge clk_2) 
    begin : write2second_reg
        if( !resetn_2 )
            int_reg2 <= '0;
        begin
            if( we_2 )
                int_reg2 <= data_2_in;
            if( req_1 )
                int_reg2 <= int_reg1;
        end
    end

    always_ff @(posedge clk_2) 
    begin : answer_second
        if( !resetn_2 )
            ack_2 <= '0;
        else 
            ack_2 <= req_1;
    end

    always_ff @(posedge clk_2) 
    begin : request_second
        if( !resetn_2 )
            req_2 <= '0;
        else 
        begin
            if( we_2 )
                req_2 <= '1;
            if( ack_1 == '1 )
                req_2 <= '0;
        end
    end

endmodule : cdc
