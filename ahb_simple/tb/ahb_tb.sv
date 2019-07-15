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
    // testbench settigns
    parameter           T = 10,
                        resetn_delay = 7,
                        repeat_cycles = 400,
                        work_freq = 500000000,
                        test_c = 20;

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

    // clock and reset
    logic                  [0         : 0]  clk;        // clk
    logic                  [0         : 0]  resetn;     // resetn
    // PWM clock and reset
    logic                  [0         : 0]  pwm_clk;    // pwm clk
    logic                  [0         : 0]  pwm_resetn; // pwm resetn
    // GPIO 0
    logic                  [gpio_w-1  : 0]  gpi_0;      // gpio 0 input
    logic                  [gpio_w-1  : 0]  gpo_0;      // gpio 0 output
    logic                  [gpio_w-1  : 0]  gpd_0;      // gpio 0 direction
    // GPIO 1
    logic                  [gpio_w-1  : 0]  gpi_1;      // gpio 1 input
    logic                  [gpio_w-1  : 0]  gpo_1;      // gpio 1 output
    logic                  [gpio_w-1  : 0]  gpd_1;      // gpio 1 direction
    // PWM
    logic                  [0         : 0]  pwm;        // pwm output
    // UART
    logic                  [0         : 0]  uart_tx;    // uart tx wire
    logic                  [0         : 0]  uart_rx;    // uart rx wire
    // AHB slaves side
    logic   [slave_c-1 : 0][31        : 0]  haddr_s;    // AHB - Slave HADDR 
    logic   [slave_c-1 : 0][31        : 0]  hwdata_s;   // AHB - Slave HWDATA 
    logic   [slave_c-1 : 0][31        : 0]  hrdata_s;   // AHB - Slave HRDATA 
    logic   [slave_c-1 : 0][0         : 0]  hwrite_s;   // AHB - Slave HWRITE 
    logic   [slave_c-1 : 0][1         : 0]  htrans_s;   // AHB - Slave HTRANS 
    logic   [slave_c-1 : 0][2         : 0]  hsize_s;    // AHB - Slave HSIZE 
    logic   [slave_c-1 : 0][2         : 0]  hburst_s;   // AHB - Slave HBURST 
    logic   [slave_c-1 : 0][1         : 0]  hresp_s;    // AHB - Slave HRESP 
    logic   [slave_c-1 : 0][0         : 0]  hready_s;   // AHB - Slave HREADYOUT 
    logic   [slave_c-1 : 0][0         : 0]  hsel_s;     // AHB - Slave HSEL
    // core side
    logic                  [31        : 0]  addr;       // address memory
    logic                  [31        : 0]  rd;         // read memory
    logic                  [31        : 0]  wd;         // write memory
    logic                  [0         : 0]  we;         // write enable signal
    logic                  [1         : 0]  size;       // size for load/store instructions
    logic                  [0         : 0]  req;        // request memory signal
    logic                  [0         : 0]  req_ack;    // request acknowledge memory signal

    ahb_top 
    #(
        .slave_c        ( slave_c       )
    )
    ahb_top_0
    (
        .clk            ( clk           ),      // clk
        .resetn         ( resetn        ),      // resetn
        // AHB slaves side
        .haddr_s        ( haddr_s       ),      // AHB - Slave HADDR 
        .hwdata_s       ( hwdata_s      ),      // AHB - Slave HWDATA 
        .hrdata_s       ( hrdata_s      ),      // AHB - Slave HRDATA 
        .hwrite_s       ( hwrite_s      ),      // AHB - Slave HWRITE 
        .htrans_s       ( htrans_s      ),      // AHB - Slave HTRANS 
        .hsize_s        ( hsize_s       ),      // AHB - Slave HSIZE 
        .hburst_s       ( hburst_s      ),      // AHB - Slave HBURST 
        .hresp_s        ( hresp_s       ),      // AHB - Slave HRESP 
        .hready_s       ( hready_s      ),      // AHB - Slave HREADYOUT 
        .hsel_s         ( hsel_s        ),      // AHB - Slave HSEL
        // core side
        .addr           ( addr          ),      // address memory
        .rd             ( rd            ),      // read memory
        .wd             ( wd            ),      // write memory
        .we             ( we            ),      // write enable signal
        .size           ( size          ),      // size for load/store instructions
        .req            ( req           ),      // request memory signal
        .req_ack        ( req_ack       )       // request acknowledge memory signal
    );
    // Creating one ahb_gpio_0
    ahb_gpio 
    #(
        .gpio_w         ( gpio_w        ) 
    )
    ahb_gpio_0
    (
        // clock and reset
        .hclk           ( clk           ),      // hclock
        .hresetn        ( resetn        ),      // hresetn
        // Slaves side
        .haddr_s        ( haddr_s   [0] ),      // AHB - GPIO-slave HADDR
        .hwdata_s       ( hwdata_s  [0] ),      // AHB - GPIO-slave HWDATA
        .hrdata_s       ( hrdata_s  [0] ),      // AHB - GPIO-slave HRDATA
        .hwrite_s       ( hwrite_s  [0] ),      // AHB - GPIO-slave HWRITE
        .htrans_s       ( htrans_s  [0] ),      // AHB - GPIO-slave HTRANS
        .hsize_s        ( hsize_s   [0] ),      // AHB - GPIO-slave HSIZE
        .hburst_s       ( hburst_s  [0] ),      // AHB - GPIO-slave HBURST
        .hresp_s        ( hresp_s   [0] ),      // AHB - GPIO-slave HRESP
        .hready_s       ( hready_s  [0] ),      // AHB - GPIO-slave HREADYOUT
        .hsel_s         ( hsel_s    [0] ),      // AHB - GPIO-slave HSEL
        //gpio_side
        .gpi            ( gpi_0         ),      // GPIO input
        .gpo            ( gpo_0         ),      // GPIO output
        .gpd            ( gpd_0         )       // GPIO direction
    );
    // Creating one ahb_gpio_1
    ahb_gpio 
    #(
        .gpio_w         ( gpio_w        ) 
    )
    ahb_gpio_1
    (
        // clock and reset
        .hclk           ( clk           ),      // hclock
        .hresetn        ( resetn        ),      // hresetn
        // Slaves side
        .haddr_s        ( haddr_s   [1] ),      // AHB - GPIO-slave HADDR
        .hwdata_s       ( hwdata_s  [1] ),      // AHB - GPIO-slave HWDATA
        .hrdata_s       ( hrdata_s  [1] ),      // AHB - GPIO-slave HRDATA
        .hwrite_s       ( hwrite_s  [1] ),      // AHB - GPIO-slave HWRITE
        .htrans_s       ( htrans_s  [1] ),      // AHB - GPIO-slave HTRANS
        .hsize_s        ( hsize_s   [1] ),      // AHB - GPIO-slave HSIZE
        .hburst_s       ( hburst_s  [1] ),      // AHB - GPIO-slave HBURST
        .hresp_s        ( hresp_s   [1] ),      // AHB - GPIO-slave HRESP
        .hready_s       ( hready_s  [1] ),      // AHB - GPIO-slave HREADYOUT
        .hsel_s         ( hsel_s    [1] ),      // AHB - GPIO-slave HSEL
        //gpio_side
        .gpi            ( gpi_1         ),      // GPIO input
        .gpo            ( gpo_1         ),      // GPIO output
        .gpd            ( gpd_1         )       // GPIO direction
    );
    // creating AHB PWM module
    ahb_pwm
    #(
        .pwm_width      ( pwm_width     )
    )
    ahb_pwm_0
    (
        // clock and reset
        .hclk           ( clk           ),      // hclk
        .hresetn        ( resetn        ),      // hresetn
        // Slaves side
        .haddr_s        ( haddr_s   [2] ),      // AHB - PWM-slave HADDR
        .hwdata_s       ( hwdata_s  [2] ),      // AHB - PWM-slave HWDATA
        .hrdata_s       ( hrdata_s  [2] ),      // AHB - PWM-slave HRDATA
        .hwrite_s       ( hwrite_s  [2] ),      // AHB - PWM-slave HWRITE
        .htrans_s       ( htrans_s  [2] ),      // AHB - PWM-slave HTRANS
        .hsize_s        ( hsize_s   [2] ),      // AHB - PWM-slave HSIZE
        .hburst_s       ( hburst_s  [2] ),      // AHB - PWM-slave HBURST
        .hresp_s        ( hresp_s   [2] ),      // AHB - PWM-slave HRESP
        .hready_s       ( hready_s  [2] ),      // AHB - PWM-slave HREADYOUT
        .hsel_s         ( hsel_s    [2] ),      // AHB - PWM-slave HSEL
        // pmw_side
        .pwm_clk        ( pwm_clk       ),      // PWM_clk
        .pwm_resetn     ( pwm_resetn    ),      // PWM_resetn
        .pwm            ( pwm           )       // PWM output signal
    );
    // Creating one ahb_gpio_0
    ahb_uart 
    ahb_uart_0
    (
        // clock and reset
        .hclk           ( clk           ),      // hclock
        .hresetn        ( resetn        ),      // hresetn
        // Slaves side
        .haddr_s        ( haddr_s   [3] ),      // AHB - UART-slave HADDR
        .hwdata_s       ( hwdata_s  [3] ),      // AHB - UART-slave HWDATA
        .hrdata_s       ( hrdata_s  [3] ),      // AHB - UART-slave HRDATA
        .hwrite_s       ( hwrite_s  [3] ),      // AHB - UART-slave HWRITE
        .htrans_s       ( htrans_s  [3] ),      // AHB - UART-slave HTRANS
        .hsize_s        ( hsize_s   [3] ),      // AHB - UART-slave HSIZE
        .hburst_s       ( hburst_s  [3] ),      // AHB - UART-slave HBURST
        .hresp_s        ( hresp_s   [3] ),      // AHB - UART-slave HRESP
        .hready_s       ( hready_s  [3] ),      // AHB - UART-slave HREADYOUT
        .hsel_s         ( hsel_s    [3] ),      // AHB - UART-slave HSEL
        // UART side
        .uart_tx        ( uart_tx       ),      // UART tx wire
        .uart_rx        ( uart_rx       )       // UART rx wire
    );

    assign pwm_clk = clk;
    assign pwm_resetn = resetn;

    // generate clock
    initial
    begin
        clk = '0;
        forever
            #(T/2) clk = !clk;
    end
    // generate reset
    initial
    begin
        resetn = '0;
        repeat( resetn_delay ) @(posedge clk);
        resetn = '1;
    end
    // verification
    initial
    begin
        wd = '0;
        we = '0;
        req = '0;
        addr = '0;
        size = '0;
        gpi_0 = '0;
        gpi_1 = '0;
        uart_rx = '1;
        @(posedge resetn);
        $display("Testing gpio_0");
        repeat(test_c)
        begin
            gpo_0_v = $urandom_range(0,255);
            write_data( GPIO_0_ADDR_S | GPIO_GPO_R , gpo_0_v , '0 );
            @(posedge clk);
            $display("Test %s, gpo_0 = 0x%h, wd = 0x%h", ( gpo_0 == wd ) ? "Pass" : "Fail" , gpo_0, wd);
        end
        repeat(test_c)
        begin
            gpd_0_v = $urandom_range(0,255);
            write_data( GPIO_0_ADDR_S | GPIO_GPD_R , gpd_0_v , '0 );
            @(posedge clk);
            $display("Test %s, gpd_0 = 0x%h, wd = 0x%h", ( gpd_0 == wd ) ? "Pass" : "Fail" , gpd_0, wd);
        end
        repeat(test_c)
        begin
            gpi_0 = $urandom_range(0, 2**gpio_w-1);
            read_data( GPIO_0_ADDR_S | GPIO_GPI_R );
            $display("Test %s, gpi_0 = 0x%h, rd = 0x%h", ( gpi_0 == rd ) ? "Pass" : "Fail" , gpi_0, rd);
        end
        $display("Testing gpio_1");
        repeat(test_c)
        begin
            gpo_1_v = $urandom_range(0,255);
            write_data( GPIO_1_ADDR_S | GPIO_GPO_R , gpo_1_v , '0 );
            @(posedge clk);
            $display("Test %s, gpo_1 = 0x%h, wd = 0x%h", ( gpo_1 == wd ) ? "Pass" : "Fail" , gpo_1, wd);
        end
        repeat(test_c)
        begin
            gpd_1_v = $urandom_range(0,255);
            write_data( GPIO_1_ADDR_S | GPIO_GPD_R , gpd_1_v , '0 );
            @(posedge clk);
            $display("Test %s, gpd_1 = 0x%h, wd = 0x%h", ( gpd_1 == wd ) ? "Pass" : "Fail" , gpd_1, wd);
        end
        repeat(test_c)
        begin
            gpi_1 = $urandom_range(0, 2**gpio_w-1);
            read_data( GPIO_1_ADDR_S | GPIO_GPI_R );
            $display("Test %s, gpi_1 = 0x%h, rd = 0x%h", ( gpi_1 == rd ) ? "Pass" : "Fail" , gpi_1, rd);
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
            while( ( rd & ( 1'b1 << UART_TX_REQ ) ) != '0 );
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
            while( ( rd & ( 1'b1 << UART_RX_VAL ) ) == '0 );
            read_data( UART_ADDR_S | UART_RX_R );
            $display("read data = 0x%h", rd);
            $display("Test %s", send_uart_v == rd ? "Pass" : "Fail" );
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
            @(posedge clk);
            wait(pwm_e_0.triggered);
        end
        repeat(10) @(posedge clk);
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
        @(posedge pwm_resetn);
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
        addr = w_addr;
        wd = w_data;
        we = '1;
        size = 2'b10;
        req = '1;
        @(posedge req_ack);
        @(posedge clk);
        req = '0;
        @(posedge clk);
    endtask : write_data
    // task for reading data with simple interface
    task read_data(logic [31 : 0] r_addr);
        addr = r_addr;
        we = '0;
        req = '1;
        @(posedge req_ack);
        req = '0;
        @(posedge clk);
    endtask : read_data
    // task for receiving data over uart
    task rec_uart();
        integer             uart_tx_c;
        logic   [7 : 0]     uart_rec_d;
        uart_tx_c = 0;
        @(negedge ahb_uart_0.uart_top_0.uart_tx);
        repeat(ahb_uart_0.uart_top_0.UDVR_0) @(posedge clk);    // start
        repeat(8)                       // data
        begin
            repeat(ahb_uart_0.uart_top_0.UDVR_0)
            begin
                uart_tx_c += ahb_uart_0.uart_top_0.uart_tx;
                @(posedge clk);
            end
            uart_rec_d = { ( uart_tx_c > ( ahb_uart_0.uart_top_0.UDVR_0 >> 1 ) ) , uart_rec_d[7 : 1] };
            uart_tx_c = '0;
        end
        repeat( ahb_uart_0.uart_top_0.UDVR_0 )
        begin
            if( ahb_uart_0.uart_top_0.uart_tx == '0 )
                uart_tx_c++;
            @(posedge clk);
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
        uart_rx = '0;
        repeat(ahb_uart_0.uart_top_0.UDVR_0) @(posedge clk);    // start
        repeat(8)                       // data
        begin
            uart_rx = symbol[0];
            symbol = symbol>>1;
            repeat(ahb_uart_0.uart_top_0.UDVR_0) @(posedge clk);
        end
        uart_rx = '1;
        repeat( ahb_uart_0.uart_top_0.UDVR_0 ) @(posedge clk);
    endtask : send_uart
    // task for finding pwm duty cycle
    task pwm_dc_find();
        integer count;
        real pwm_D;
        count = 0;
        repeat(2**pwm_width)
        begin
            @(posedge pwm_clk);
            count += pwm;
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
