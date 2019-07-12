/*
*  File            :   pwm.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.11
*  Language        :   SystemVerilog
*  Description     :   This is PWM module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "pwm.svh"

module pwm
#(
    parameter                   pwm_width = 8
)(
    // clock and reset
    input   logic   [0  : 0]    clk,        // clk  
    input   logic   [0  : 0]    resetn,     // resetn
    // bus side
    input   logic   [31 : 0]    addr,       // address
    input   logic   [0  : 0]    we,         // write enable
    input   logic   [31 : 0]    wd,         // write data
    output  logic   [31 : 0]    rd,         // read data
    // pmw_side
    input   logic   [0  : 0]    pwm_clk,    // PWM clock input
    input   logic   [0  : 0]    pwm_resetn, // PWM reset input
    output  logic   [0  : 0]    pwm         // PWM output signal
);

    logic   [pwm_width-1 : 0]   pwm_i;      // internal counter register
    logic   [pwm_width-1 : 0]   pwm_c;      // internal compare register
    // write enable signals 
    logic   [0           : 0]   pwm_c_we;   // pwm compare write enable
    // assign write enable signals
    assign pwm_c_we = we && ( addr[0 +: 4] == PWM_C_R ); 

    assign pwm = ( pwm_i < pwm_c );
    assign rd  = { '0 , pwm_c };

    always_ff @(posedge pwm_clk, negedge pwm_resetn)
    begin : work_with_counter_pwm
        if( !pwm_resetn )
            pwm_i <= '0;
        else
            pwm_i <= pwm_i + 1'b1;
    end
    
    always_ff @(posedge clk, negedge resetn)
    begin : work_with_compare_pwm
        if( !resetn )
            pwm_c <= '0;
        else
            if( pwm_c_we )
                pwm_c <= wd;
    end

endmodule : pwm
