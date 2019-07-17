/*
*  File            :   ahb_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.11
*  Language        :   SystemVerilog
*  Description     :   This is simple testbench for AHB master ( with simple interface ) to AHB slaves
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "../rtl/system_settings.svh"
`include "../rtl/periphery/gpio/gpio.svh"
`include "../rtl/periphery/pwm/pwm.svh"
`include "../rtl/periphery/uart/uart.svh"

module ahb_tb();

    timeprecision       1ns;
    timeunit            1ns;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import test_pkg::*;

    // testbench settigns
    parameter           T = 10,
                        resetn_delay = 7,
                        repeat_cycles = 400,
                        work_freq = 500000000,
                        test_c = 2;

    parameter           slave_c = SLAVE_COUNT,
                        gpio_w = 8,
                        pwm_width = 8;

    ahb_if      #(slave_c)      ahb_ic_0();

    simple_if                   s_if_0();

    gpio_if     #(gpio_w)       gpio_if_0();
    gpio_if     #(gpio_w)       gpio_if_1();
    pwm_if                      pwm_if_0();
    uart_if                     uart_if_0();

    ahb_top 
    #(
        .slave_c        ( slave_c                   )
    )
    ahb_top_0
    (
        // AHB slaves side
        .hclk           ( ahb_ic_0.hclk             ),
        .hresetn        ( ahb_ic_0.hresetn          ),
        .haddr_s        ( ahb_ic_0.haddr            ),      // AHB - Slave HADDR 
        .hwdata_s       ( ahb_ic_0.hwdata           ),      // AHB - Slave HWDATA 
        .hrdata_s       ( ahb_ic_0.hrdata           ),      // AHB - Slave HRDATA 
        .hwrite_s       ( ahb_ic_0.hwrite           ),      // AHB - Slave HWRITE 
        .htrans_s       ( ahb_ic_0.htrans           ),      // AHB - Slave HTRANS 
        .hsize_s        ( ahb_ic_0.hsize            ),      // AHB - Slave HSIZE 
        .hburst_s       ( ahb_ic_0.hburst           ),      // AHB - Slave HBURST 
        .hresp_s        ( ahb_ic_0.hresp            ),      // AHB - Slave HRESP 
        .hready_s       ( ahb_ic_0.hready           ),      // AHB - Slave HREADYOUT 
        .hsel_s         ( ahb_ic_0.hsel             ),      // AHB - Slave HSEL
        // core side
        .clk            ( s_if_0.clk                ),      // clk
        .resetn         ( s_if_0.resetn             ),      // resetn
        .addr           ( s_if_0.addr               ),      // address memory
        .rd             ( s_if_0.rd                 ),      // read memory
        .wd             ( s_if_0.wd                 ),      // write memory
        .we             ( s_if_0.we                 ),      // write enable signal
        .size           ( s_if_0.size               ),      // size for load/store instructions
        .req            ( s_if_0.req                ),      // request memory signal
        .req_ack        ( s_if_0.req_ack            )       // request acknowledge memory signal
    );
    // Creating one ahb_gpio_0
    ahb_gpio 
    #(
        .gpio_w         ( gpio_w                    ) 
    )
    ahb_gpio_0
    (
        // clock and reset
        .hclk           ( ahb_ic_0.hclk             ),      // hclock
        .hresetn        ( ahb_ic_0.hresetn          ),      // hresetn
        // Slaves side
        .haddr_s        ( ahb_ic_0.haddr    [0]     ),      // AHB - GPIO-slave HADDR
        .hwdata_s       ( ahb_ic_0.hwdata   [0]     ),      // AHB - GPIO-slave HWDATA
        .hrdata_s       ( ahb_ic_0.hrdata   [0]     ),      // AHB - GPIO-slave HRDATA
        .hwrite_s       ( ahb_ic_0.hwrite   [0]     ),      // AHB - GPIO-slave HWRITE
        .htrans_s       ( ahb_ic_0.htrans   [0]     ),      // AHB - GPIO-slave HTRANS
        .hsize_s        ( ahb_ic_0.hsize    [0]     ),      // AHB - GPIO-slave HSIZE
        .hburst_s       ( ahb_ic_0.hburst   [0]     ),      // AHB - GPIO-slave HBURST
        .hresp_s        ( ahb_ic_0.hresp    [0]     ),      // AHB - GPIO-slave HRESP
        .hready_s       ( ahb_ic_0.hready   [0]     ),      // AHB - GPIO-slave HREADYOUT
        .hsel_s         ( ahb_ic_0.hsel     [0]     ),      // AHB - GPIO-slave HSEL
        // gpio_side
        .gpi            ( gpio_if_0.gpi             ),      // GPIO input
        .gpo            ( gpio_if_0.gpo             ),      // GPIO output
        .gpd            ( gpio_if_0.gpd             )       // GPIO direction
    );
    // Creating one ahb_gpio_1
    ahb_gpio 
    #(
        .gpio_w         ( gpio_w                    ) 
    )
    ahb_gpio_1
    (
        // clock and reset
        .hclk           ( ahb_ic_0.hclk             ),      // hclock
        .hresetn        ( ahb_ic_0.hresetn          ),      // hresetn
        // Slaves side
        .haddr_s        ( ahb_ic_0.haddr    [1]     ),      // AHB - GPIO-slave HADDR
        .hwdata_s       ( ahb_ic_0.hwdata   [1]     ),      // AHB - GPIO-slave HWDATA
        .hrdata_s       ( ahb_ic_0.hrdata   [1]     ),      // AHB - GPIO-slave HRDATA
        .hwrite_s       ( ahb_ic_0.hwrite   [1]     ),      // AHB - GPIO-slave HWRITE
        .htrans_s       ( ahb_ic_0.htrans   [1]     ),      // AHB - GPIO-slave HTRANS
        .hsize_s        ( ahb_ic_0.hsize    [1]     ),      // AHB - GPIO-slave HSIZE
        .hburst_s       ( ahb_ic_0.hburst   [1]     ),      // AHB - GPIO-slave HBURST
        .hresp_s        ( ahb_ic_0.hresp    [1]     ),      // AHB - GPIO-slave HRESP
        .hready_s       ( ahb_ic_0.hready   [1]     ),      // AHB - GPIO-slave HREADYOUT
        .hsel_s         ( ahb_ic_0.hsel     [1]     ),      // AHB - GPIO-slave HSEL
        // gpio_side
        .gpi            ( gpio_if_1.gpi             ),      // GPIO input
        .gpo            ( gpio_if_1.gpo             ),      // GPIO output
        .gpd            ( gpio_if_1.gpd             )       // GPIO direction
    );
    // creating AHB PWM module
    ahb_pwm
    #(
        .pwm_width      ( pwm_width                 )
    )
    ahb_pwm_0
    (
        // clock and reset
        .hclk           ( ahb_ic_0.hclk             ),      // hclk
        .hresetn        ( ahb_ic_0.hresetn          ),      // hresetn
        // Slaves side
        .haddr_s        ( ahb_ic_0.haddr    [2]     ),      // AHB - PWM-slave HADDR
        .hwdata_s       ( ahb_ic_0.hwdata   [2]     ),      // AHB - PWM-slave HWDATA
        .hrdata_s       ( ahb_ic_0.hrdata   [2]     ),      // AHB - PWM-slave HRDATA
        .hwrite_s       ( ahb_ic_0.hwrite   [2]     ),      // AHB - PWM-slave HWRITE
        .htrans_s       ( ahb_ic_0.htrans   [2]     ),      // AHB - PWM-slave HTRANS
        .hsize_s        ( ahb_ic_0.hsize    [2]     ),      // AHB - PWM-slave HSIZE
        .hburst_s       ( ahb_ic_0.hburst   [2]     ),      // AHB - PWM-slave HBURST
        .hresp_s        ( ahb_ic_0.hresp    [2]     ),      // AHB - PWM-slave HRESP
        .hready_s       ( ahb_ic_0.hready   [2]     ),      // AHB - PWM-slave HREADYOUT
        .hsel_s         ( ahb_ic_0.hsel     [2]     ),      // AHB - PWM-slave HSEL
        // pmw_side
        .pwm_clk        ( pwm_if_0.clk              ),      // PWM_clk
        .pwm_resetn     ( pwm_if_0.resetn           ),      // PWM_resetn
        .pwm            ( pwm_if_0.pwm              )       // PWM output signal
    );
    // Creating one ahb_gpio_0
    ahb_uart 
    ahb_uart_0
    (
        // clock and reset
        .hclk           ( ahb_ic_0.hclk             ),      // hclock
        .hresetn        ( ahb_ic_0.hresetn          ),      // hresetn
        // Slaves side
        .haddr_s        ( ahb_ic_0.haddr    [3]     ),      // AHB - UART-slave HADDR
        .hwdata_s       ( ahb_ic_0.hwdata   [3]     ),      // AHB - UART-slave HWDATA
        .hrdata_s       ( ahb_ic_0.hrdata   [3]     ),      // AHB - UART-slave HRDATA
        .hwrite_s       ( ahb_ic_0.hwrite   [3]     ),      // AHB - UART-slave HWRITE
        .htrans_s       ( ahb_ic_0.htrans   [3]     ),      // AHB - UART-slave HTRANS
        .hsize_s        ( ahb_ic_0.hsize    [3]     ),      // AHB - UART-slave HSIZE
        .hburst_s       ( ahb_ic_0.hburst   [3]     ),      // AHB - UART-slave HBURST
        .hresp_s        ( ahb_ic_0.hresp    [3]     ),      // AHB - UART-slave HRESP
        .hready_s       ( ahb_ic_0.hready   [3]     ),      // AHB - UART-slave HREADYOUT
        .hsel_s         ( ahb_ic_0.hsel     [3]     ),      // AHB - UART-slave HSEL
        // UART side
        .uart_tx        ( uart_if_0.uart_tx         ),      // UART tx wire
        .uart_rx        ( uart_if_0.uart_rx         )       // UART rx wire
    );
    // connecting uart_0 interface
    assign uart_if_0.clk            = s_if_0.clk;
    assign uart_if_0.resetn         = s_if_0.resetn;
    // connecting pwm_0 interface
    assign pwm_if_0.clk             = s_if_0.clk;
    assign pwm_if_0.resetn          = s_if_0.resetn;
    // connecting gpio_0 interface
    assign gpio_if_0.clk            = s_if_0.clk;
    assign gpio_if_0.resetn         = s_if_0.resetn;
    // connecting gpio_1 interface
    assign gpio_if_1.clk            = s_if_0.clk;
    assign gpio_if_1.resetn         = s_if_0.resetn;

    // start simulation
    initial
    begin
        uvm_config_db #( virtual simple_if )::set(null, "*", "s_if_0"    , s_if_0    );
        uvm_config_db #( virtual gpio_if   )::set(null, "*", "gpio_if_0" , gpio_if_0 );
        uvm_config_db #( virtual gpio_if   )::set(null, "*", "gpio_if_1" , gpio_if_1 );
        uvm_config_db #( virtual pwm_if    )::set(null, "*", "pwm_if_0"  , pwm_if_0  );
        uvm_config_db #( virtual uart_if   )::set(null, "*", "uart_if_0" , uart_if_0 );
        run_test();
        $stop();
    end

endmodule : ahb_tb
