/*
*  File            :   system_driver.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.16
*  Language        :   SystemVerilog
*  Description     :   This is system driver class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::*;

`include "../../rtl/periphery/uart/uart.svh"
`include "../rtl/system_settings.svh"

class system_driver #(parameter string if_name = "") extends uvm_component;
    `uvm_component_utils(system_driver)

    // uvm ports for connecting testbench classes
    uvm_put_port    #(logic [15 : 0])   drv_simple2uart_mon_port;

    virtual simple_if           s_if_;

    string                      name = "";

    integer                     cycle = 0;
    integer                     rep_c = -1;

    function new (string name, uvm_component parent);
        super.new(name, parent);
        this.name = name;
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual simple_if)::get(null, "*",if_name, s_if_))
            $fatal("Failed to get %s",if_name);
        drv_simple2uart_mon_port = new("drv_simple2uart_mon_port", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        logic   [15 : 0]    set_baudrate;
        integer             rand_baudrate;
        logic   [7  : 0]    rand_tx_data;
        $display("Testing uart_0");
        $display("Start work with uart transmitter");
        repeat(40)
        begin
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