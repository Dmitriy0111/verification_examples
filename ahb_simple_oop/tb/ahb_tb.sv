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

class gpio_model #(parameter gpio_w = 8, addr_w = 4, reg_n = 3, parameter string name = "gpio_");

    string  module_name = name;

    typedef struct
    {
        string                  r_n;    // register name
        logic   [addr_w-1 : 0]  r_a;    // register address
        logic   [gpio_w-1 : 0]  r_v;    // register value
    } gpio_r;  // uart control reg

    gpio_r      gpio_r_ [] = new[reg_n];

    function new(string n_l [], logic [addr_w-1 : 0] a_l []);
        foreach(gpio_r_[i])
        begin
            gpio_r_[i].r_a = a_l[i];
            gpio_r_[i].r_n = n_l[i];
        end
    endfunction : new

    function logic [gpio_w-1 : 0] get_rv(logic [addr_w-1 : 0] r_a);
        logic   [gpio_w-1 : 0]  ret_v;

        ret_v = 'x;

        foreach(gpio_r_[i])
            if( gpio_r_[i].r_a == r_a )
                ret_v = gpio_r_[i].r_v;

        return ret_v;
    endfunction : get_rv

    task set_rv(logic [addr_w-1 : 0] r_a, logic [gpio_w-1 : 0] s_v);
        foreach(gpio_r_[i])
            if( gpio_r_[i].r_a == r_a )
                gpio_r_[i].r_v = s_v;
    endtask : set_rv

endclass : gpio_model

class ahb_gpio_model #(parameter gpio_w = 8, addr_w = 4, reg_n = 3, parameter string name = "ahb_gpio_");
    gpio_model  #(8, 32, 3, "gpio_0") gpio_0;
endclass : ahb_gpio_model

//class pwm_model #(parameter pwm_width = 8);
//
//    logic   [pwm_width-1 : 0]   pwm_c;
//
//    function new(logic [pwm_width-1 : 0] pwm_c_i);
//        pwm_c = pwm_c_i;
//    endfunction : new
//
//    function logic [pwm_width-1 : 0] get_c();
//        return pwm_c;
//    endfunction : get_c
//    
//    task set_c(logic [pwm_width-1 : 0] pwm_c_i);
//        pwm_c = pwm_c_i;
//    endtask : set_c
//
//endclass : pwm_model

class system_model;

    gpio_model  #(8, 32, 3, "gpio_0") gpio_0;
    gpio_model  #(8, 32, 3, "gpio_1") gpio_1;

    function new();
        gpio_0 = new(   
                        { "gpi"         , "gpo"         , "gpd"         },
                        { 32'h0000_0000 , 32'h0000_0004 , 32'h0000_0008 }
                    );
        gpio_1 = new(   
                        { "gpi"         , "gpo"         , "gpd"         },
                        { 32'h0001_0000 , 32'h0001_0004 , 32'h0001_0008 }
                    );
    endfunction : new

endclass : system_model

module ahb_tb();

    timeprecision       1ns;
    timeunit            1ns;

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

    integer                     cycle = 0;

    logic   [gpio_w-1 : 0]      gpo_0_v;
    logic   [gpio_w-1 : 0]      gpd_0_v;
    logic   [gpio_w-1 : 0]      gpo_1_v;
    logic   [gpio_w-1 : 0]      gpd_1_v;

    logic   [7 : 0]             uart_write_v;

    event                       uart_send_e_0;
    event                       uart_send_e_1;
    logic   [7 : 0]             send_uart_v;

    event                       pwm_e_0;
    event                       pwm_e_1;
    logic   [pwm_width-1 : 0]   pwm_D_rand;
    real                        pwm_D_rand_r;

    ahb_if      #(slave_c)      ahb_ic_0();

    simple_if                   s_if_0();

    gpio_if     #(gpio_w)       gpio_if_0();
    gpio_if     #(gpio_w)       gpio_if_1();
    pwm_if                      pwm_if_0();
    uart_if                     uart_if_0();

    c_r_generator   #(T, resetn_delay)  c_r_generator_0 = new("[ C_R_0  generator ]");
    uart_monitor                        uart_monitor_0  = new("[ UART_0 monitor   ]");
    gpio_monitor                        gpio_monitor_0  = new("[ GPIO_0 monitor   ]");
    gpio_monitor                        gpio_monitor_1  = new("[ GPIO_1 monitor   ]");
    pwm_monitor                         pwm_monitor_0   = new("[ UART_0 monitor   ]");

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

    initial
    begin
        fork
            c_r_generator_0.build_phase(s_if_0);
            gpio_monitor_0.build_phase(gpio_if_0);
            gpio_monitor_1.build_phase(gpio_if_1);
            uart_monitor_0.build_phase(uart_if_0);
            pwm_monitor_0.build_phase(pwm_if_0);
        join
        c_r_generator_0.run_phase();
    end
    // verification
    initial
    begin
        s_if_0.wd = '0;
        s_if_0.we = '0;
        s_if_0.req = '0;
        s_if_0.addr = '0;
        s_if_0.size = '0;
        gpio_if_0.gpi = '0;
        gpio_if_1.gpi = '0;
        uart_if_0.uart_rx = '1;
        @(posedge s_if_0.resetn);
        $display("Testing gpio_0");
        repeat(test_c)
        begin
            gpo_0_v = $urandom_range(0,255);
            write_data( GPIO_0_ADDR_S | GPIO_GPO_R , gpo_0_v , '0 );
            @(posedge s_if_0.clk);
            $display("Test %s, gpo_0 = 0x%h, wd = 0x%h", ( gpio_if_0.gpo == s_if_0.wd ) ? "Pass" : "Fail" , gpio_if_0.gpo, s_if_0.wd);
        end
        repeat(test_c)
        begin
            gpd_0_v = $urandom_range(0,255);
            write_data( GPIO_0_ADDR_S | GPIO_GPD_R , gpd_0_v , '0 );
            @(posedge s_if_0.clk);
            $display("Test %s, gpd_0 = 0x%h, wd = 0x%h", ( gpio_if_0.gpd == s_if_0.wd ) ? "Pass" : "Fail" , gpio_if_0.gpd, s_if_0.wd);
        end
        repeat(test_c)
        begin
            gpio_if_0.gpi = $urandom_range(0, 2**gpio_w-1);
            read_data( GPIO_0_ADDR_S | GPIO_GPI_R );
            $display("Test %s, gpi_0 = 0x%h, rd = 0x%h", ( gpio_if_0.gpi == s_if_0.rd ) ? "Pass" : "Fail" , gpio_if_0.gpi, s_if_0.rd);
        end
        $display("Testing gpio_1");
        repeat(test_c)
        begin
            gpo_1_v = $urandom_range(0,255);
            write_data( GPIO_1_ADDR_S | GPIO_GPO_R , gpo_1_v , '0 );
            @(posedge s_if_0.clk);
            $display("Test %s, gpo_1 = 0x%h, wd = 0x%h", ( gpio_if_1.gpo == s_if_0.wd ) ? "Pass" : "Fail" , gpio_if_1.gpo, s_if_0.wd);
        end
        repeat(test_c)
        begin
            gpd_1_v = $urandom_range(0,255);
            write_data( GPIO_1_ADDR_S | GPIO_GPD_R , gpd_1_v , '0 );
            @(posedge s_if_0.clk);
            $display("Test %s, gpd_1 = 0x%h, wd = 0x%h", ( gpio_if_1.gpd == s_if_0.wd ) ? "Pass" : "Fail" , gpio_if_1.gpd, s_if_0.wd);
        end
        repeat(test_c)
        begin
            gpio_if_0.gpi = $urandom_range(0, 2**gpio_w-1);
            read_data( GPIO_1_ADDR_S | GPIO_GPI_R );
            $display("Test %s, gpi_1 = 0x%h, rd = 0x%h", ( gpio_if_1.gpi == s_if_0.rd ) ? "Pass" : "Fail" , gpio_if_1.gpi, s_if_0.rd);
        end
        $display("Testing uart_0");
        $display("Start work with uart transmitter");
        repeat(test_c)
        begin
            $display("Start cycle = %d", cycle);
            write_data( UART_ADDR_S | UART_CR_R , 1'b1 << UART_TX_EN );
            write_data( UART_ADDR_S | UART_DR_R , work_freq / 115200 );
            uart_write_v = $urandom_range(0,255);
            write_data( UART_ADDR_S | UART_TX_R , uart_write_v );
            write_data( UART_ADDR_S | UART_CR_R , ( 1'b1 << UART_TX_EN ) | ( 1'b1 << UART_TX_REQ ) );
            do
            begin
                read_data( UART_ADDR_S | UART_CR_R );
            end
            while( ( s_if_0.rd & ( 1'b1 << UART_TX_REQ ) ) != '0 );
            cycle++;
        end
        cycle = 0;
        $display("Start work with uart receiver");
        write_data( UART_ADDR_S | UART_CR_R , 1'b1 << UART_RX_EN );
        repeat(test_c)
        begin
            -> uart_send_e_0;
            $display("Start cycle = %d", cycle);
            do
            begin
                read_data( UART_ADDR_S | UART_CR_R );
            end
            while( ( s_if_0.rd & ( 1'b1 << UART_RX_VAL ) ) == '0 );
            read_data( UART_ADDR_S | UART_RX_R );
            $display("read data = 0x%h", s_if_0.rd);
            $display("Test %s", send_uart_v == s_if_0.rd ? "Pass" : "Fail" );
            write_data( UART_ADDR_S | UART_CR_R , 1'b1 << UART_RX_EN );
            cycle++;
            wait(uart_send_e_1.triggered);
        end
        $display("Testing pwm_0");
        repeat(test_c)
        begin
            -> pwm_e_1;
            pwm_D_rand = $urandom_range(0,2**pwm_width-1);
            write_data( PWM_ADDR_S | PWM_C_R , pwm_D_rand );
            pwm_D_rand_r = ( pwm_D_rand ) * 100.0 / (2**pwm_width-1);
            @(posedge s_if_0.clk);
            wait(pwm_e_0.triggered);
        end
        repeat(10) @(posedge s_if_0.clk);
        $stop;
    end
    // 
    initial
    begin
        repeat(test_c)
        begin
            wait(uart_send_e_0.triggered);
            send_uart_v = $urandom_range(0,255);
            send_uart(send_uart_v);
            -> uart_send_e_1;
        end
    end
    // receiving uart data
    initial
    begin
        forever
            rec_uart();
    end
    // working with pwm
    initial
    begin
        @(posedge pwm_if_0.resetn);
        repeat(test_c)
        begin
            wait(pwm_e_1.triggered);
            pwm_dc_find();
            -> pwm_e_0;
        end
    end
    // task for writing data with simple interface
    task write_data(logic [31 : 0] w_addr, logic [31 : 0] w_data, bit disp = '1 );
        if(disp)
            $display("Write data 0x%h at addr 0x%h", w_data, w_addr );
        s_if_0.addr = w_addr;
        s_if_0.wd = w_data;
        s_if_0.we = '1;
        s_if_0.size = 2'b10;
        s_if_0.req = '1;
        @(posedge s_if_0.req_ack);
        @(posedge s_if_0.clk);
        s_if_0.req = '0;
        @(posedge s_if_0.clk);
    endtask : write_data
    // task for reading data with simple interface
    task read_data(logic [31 : 0] r_addr);
        s_if_0.addr = r_addr;
        s_if_0.we = '0;
        s_if_0.req = '1;
        @(posedge s_if_0.req_ack);
        s_if_0.req = '0;
        @(posedge s_if_0.clk);
    endtask : read_data
    // task for receiving data over uart
    task rec_uart();
        integer             uart_tx_c;
        logic   [7 : 0]     uart_rec_d;
        uart_tx_c = 0;
        @(negedge ahb_uart_0.uart_top_0.uart_tx);
        repeat(ahb_uart_0.uart_top_0.UDVR_0) @(posedge s_if_0.clk);    // start
        repeat(8)                       // data
        begin
            repeat(ahb_uart_0.uart_top_0.UDVR_0)
            begin
                uart_tx_c += ahb_uart_0.uart_top_0.uart_tx;
                @(posedge s_if_0.clk);
            end
            uart_rec_d = { ( uart_tx_c > ( ahb_uart_0.uart_top_0.UDVR_0 >> 1 ) ) , uart_rec_d[7 : 1] };
            uart_tx_c = '0;
        end
        repeat( ahb_uart_0.uart_top_0.UDVR_0 )
        begin
            if( ahb_uart_0.uart_top_0.uart_tx == '0 )
                uart_tx_c++;
            @(posedge s_if_0.clk);
        end
        if( uart_tx_c > ( ahb_uart_0.uart_top_0.UDVR_0 / 10 ) )
            $display("[ Error ] Stop bits count error!");
        $display("Received data = 0x%h", uart_rec_d);
        $display("Test %s", uart_write_v == uart_rec_d ? "Pass" : "Fail" );
        uart_tx_c = '0;
    endtask : rec_uart
    // task for sending data over uart
    task send_uart(logic [7 : 0] symbol);
        $display("Sending uart data = 0x%h", symbol);
        uart_if_0.uart_rx = '0;
        repeat(ahb_uart_0.uart_top_0.UDVR_0) @(posedge s_if_0.clk);    // start
        repeat(8)                       // data
        begin
            uart_if_0.uart_rx = symbol[0];
            symbol = symbol>>1;
            repeat(ahb_uart_0.uart_top_0.UDVR_0) @(posedge s_if_0.clk);
        end
        uart_if_0.uart_rx = '1;
        repeat( ahb_uart_0.uart_top_0.UDVR_0 ) @(posedge s_if_0.clk);
    endtask : send_uart
    // task for finding pwm duty cycle
    task pwm_dc_find();
        integer count;
        real pwm_D;
        count = 0;
        repeat(2**pwm_width)
        begin
            @(posedge pwm_if_0.clk);
            count += pwm_if_0.pwm;
        end
        pwm_D = count * 100.0 / (2**pwm_width-1);
        $display("Test %s, pwm_D_rand = %2.2f%%, pwm_D = %2.2f%%", abs_r( pwm_D - pwm_D_rand_r ) < 1.0 ? "Pass" : "Fail", pwm_D_rand_r , pwm_D );
    endtask : pwm_dc_find
    // 
    function real abs_r(real data);
        real ret_v;
        if( data < 0 )
            ret_v = - data;
        else
            ret_v = data;
        return ret_v;
    endfunction : abs_r

endmodule : ahb_tb
