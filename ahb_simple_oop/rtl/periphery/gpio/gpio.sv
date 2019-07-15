/*
*  File            :   gpio.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.11
*  Language        :   SystemVerilog
*  Description     :   This is GPIO module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "gpio.svh"

module gpio
#(
    parameter                       gpio_w = 8
)
(
    // clock and reset
    input   logic   [0        : 0]  clk,    // clk  
    input   logic   [0        : 0]  resetn, // resetn
    // bus side
    input   logic   [31       : 0]  addr,   // address
    input   logic                   we,     // write enable
    input   logic   [31       : 0]  wd,     // write data
    output  logic   [31       : 0]  rd,     // read data
    // GPIO side
    input   logic   [gpio_w-1 : 0]  gpi,    // GPIO input
    output  logic   [gpio_w-1 : 0]  gpo,    // GPIO output
    output  logic   [gpio_w-1 : 0]  gpd     // GPIO direction
);
    // gpio input
    logic   [gpio_w-1 : 0]  gpio_i;     // gpio input
    // gpio output
    logic   [gpio_w-1 : 0]  gpio_o;     // gpio output
    // gpio direction
    logic   [gpio_w-1 : 0]  gpio_d;     // gpio direction
    // write enable signals 
    logic   [0        : 0]  gpo_we;     // gpio output write enable
    logic   [0        : 0]  gpd_we;     // gpio direction write enable
    // assign inputs/outputs
    assign gpo    = gpio_o;
    assign gpd    = gpio_d;
    assign gpio_i = gpi;
    // assign write enable signals
    assign gpo_we = we && ( addr[0 +: 4] == GPIO_GPO_R ); 
    assign gpd_we = we && ( addr[0 +: 4] == GPIO_GPD_R ); 
    // mux for routing one register value
    always_comb
    begin
        rd = gpio_i;
        casex( addr[0 +: 4] )
            GPIO_GPI_R  :  rd = gpio_i;
            GPIO_GPO_R  :  rd = gpio_o;
            GPIO_GPD_R  :  rd = gpio_d;
            default     : ;
        endcase
    end
    // writing value in gpio output register
    always_ff @(posedge clk, negedge resetn)
    begin : load_gpo
        if( !resetn )
            gpio_o <= '0;
        else
            if( gpo_we )
                gpio_o <= wd;
    end
    // writing value in gpio direction register
    always_ff @(posedge clk, negedge resetn)
    begin : load_gpd
        if( !resetn )
            gpio_d <= '0;
        else
            if( gpd_we )
                gpio_d <= wd;
    end

endmodule : gpio
