/*
*  File            :   system_driver.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.16
*  Language        :   SystemVerilog
*  Description     :   This is system driver class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef SYSTEM_DRIVER__SV
`define SYSTEM_DRIVER__SV

class system_driver #(parameter string if_name = "") extends uvm_component;
    `uvm_component_utils(system_driver)

    // uvm ports for connecting testbench classes
    uvm_put_port    #(logic [15 : 0])   drv_simple2uart_mon_port;
    uvm_put_port    #(logic [15 : 0])   drv_simple2uart_drv_port;

    virtual simple_if           s_if_;

    string                      name = "";

    integer                     cycle = 0;
    integer                     rep_c = -1;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        this.name = name;
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual simple_if)::get(null, "*",if_name, s_if_))
            $fatal("Failed to get %s",if_name);
        drv_simple2uart_mon_port = new("drv_simple2uart_mon_port", this);
        drv_simple2uart_drv_port = new("drv_simple2uart_drv_port", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        logic   [15 : 0]    set_baudrate;
        integer             rand_baudrate;
        logic   [7  : 0]    rand_tx_data;
        logic   [7  : 0]    pwm_c;
        logic   [7  : 0]    gpo_v;
        logic   [7  : 0]    gpd_v;
        $display("Testing uart_0");
        $display("Start work with uart transmitter");
        repeat(40)
        begin
            cycle++;
            write_data( UART_ADDR_S | UART_CR_R , 1'b1 << UART_TX_EN  , '0);
            case( $urandom_range(0,4) )
                0       :   rand_baudrate = 9600;
                1       :   rand_baudrate = 19200;
                2       :   rand_baudrate = 38400;
                3       :   rand_baudrate = 57600;
                4       :   rand_baudrate = 115200;
                default :   rand_baudrate = 9600;
            endcase
            set_baudrate = 50000000 / rand_baudrate;
            $display("[ Info  ] | %h | %s | New uart baudrate = 0x%x\n" , cycle , name , set_baudrate);
            write_data( UART_ADDR_S | UART_DR_R , set_baudrate  , '0);
            drv_simple2uart_mon_port.put(set_baudrate);
            rand_tx_data = $urandom_range(0,255);
            $display("[ Info  ] | %h | %s | Tx data = 0x%h\n" , cycle , name , rand_tx_data , '0);
            write_data( UART_ADDR_S | UART_TX_R , rand_tx_data , '0 );
            write_data( UART_ADDR_S | UART_CR_R , ( 1'b1 << UART_TX_EN ) | ( 1'b1 << UART_TX_REQ )  , '0);
            do
            begin
                read_data( UART_ADDR_S | UART_CR_R );
            end
            while( ( s_if_.rd & ( 1'b1 << UART_TX_REQ ) ) != '0 );
        end
        $display("Start work with uart receiver");
        repeat(40)
        begin
            cycle++;
            write_data( UART_ADDR_S | UART_CR_R , 1'b1 << UART_RX_EN  , '0);
            case( $urandom_range(0,4) )
                0       :   rand_baudrate = 9600;
                1       :   rand_baudrate = 19200;
                2       :   rand_baudrate = 38400;
                3       :   rand_baudrate = 57600;
                4       :   rand_baudrate = 115200;
                default :   rand_baudrate = 9600;
            endcase
            set_baudrate = 50000000 / rand_baudrate;
            $display("[ Info  ] | %h | %s | New uart baudrate = 0x%x\n" , cycle , name , set_baudrate);
            write_data( UART_ADDR_S | UART_DR_R , set_baudrate  , '0);
            drv_simple2uart_drv_port.put(set_baudrate);
            do
            begin
                read_data( UART_ADDR_S | UART_CR_R );
            end
            while( ( s_if_.rd & ( 1'b1 << UART_RX_VAL ) ) == '0 );
            read_data( UART_ADDR_S | UART_RX_R );
            $display("[ Info  ] | %h | %s | Received data = 0x%x\n" , cycle , name , s_if_.rd);
            write_data( UART_ADDR_S | UART_CR_R , 1'b1 << UART_RX_EN  , '0);
        end
        $display("Start work with pwm");
        repeat(40)
        begin
            cycle++;
            pwm_c = $urandom_range(0,255);
            write_data( PWM_ADDR_S | PWM_C_R , pwm_c  , '0);
            $display("[ Info  ] | %h | %s | pwm_c = 0x%h, pwm_dc = %2.2f%%\n" , cycle , name , pwm_c, pwm_c * 100.0 / 256 );
            repeat( 512 ) @( posedge s_if_.clk);
        end
        $display("Start work with gpio_0");
        repeat(40)
        begin
            gpo_v = $urandom_range(0,255);
            write_data( GPIO_0_ADDR_S | GPIO_GPO_R , gpo_v  , '0);
        end
        repeat(40)
        begin
            gpd_v = $urandom_range(0,255);
            write_data( GPIO_0_ADDR_S | GPIO_GPD_R , gpd_v  , '0);
        end

        $display("Start work with gpio_1");
        repeat(40)
        begin
            gpo_v = $urandom_range(0,255);
            write_data( GPIO_1_ADDR_S | GPIO_GPO_R , gpo_v  , '0);
        end
        repeat(40)
        begin
            gpd_v = $urandom_range(0,255);
            write_data( GPIO_1_ADDR_S | GPIO_GPD_R , gpd_v  , '0);
        end

        $stop;

    endtask : run_phase

    // task for writing data with simple interface
    task write_data(logic [31 : 0] w_addr, logic [31 : 0] w_data, bit disp = '1 );
        if(disp)
            $display("Write data 0x%h at addr 0x%h", w_data, w_addr );
        s_if_.addr = w_addr;
        s_if_.wd = w_data;
        s_if_.we = '1;
        s_if_.size = 2'b10;
        s_if_.req = '1;
        @(posedge s_if_.req_ack);
        @(posedge s_if_.clk);
        s_if_.req = '0;
        @(posedge s_if_.clk);
    endtask : write_data

    // task for reading data with simple interface
    task read_data(logic [31 : 0] r_addr);
        s_if_.addr = r_addr;
        s_if_.we = '0;
        s_if_.req = '1;
        @(posedge s_if_.req_ack);
        s_if_.req = '0;
        @(posedge s_if_.clk);
    endtask : read_data

endclass : system_driver

`endif // SYSTEM_DRIVER__SV
