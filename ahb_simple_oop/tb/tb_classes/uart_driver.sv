/*
*  File            :   uart_driver.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.16
*  Language        :   SystemVerilog
*  Description     :   This is uart driver class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef UART_DRIVER__SV
`define UART_DRIVER__SV

class uart_driver #(parameter string if_name = "") extends uvm_component;
    `uvm_component_utils(uart_driver)

    uvm_get_port    #(logic [15 : 0])   drv_simple2uart_drv_port;

    virtual uart_if     uart_if_;

    string              name = "";

    integer             cycle = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        this.name = name;
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual uart_if)::get(null, "*",if_name, uart_if_))
            $fatal("Failed to get %s",if_name);
        drv_simple2uart_drv_port = new("drv_simple2uart_drv_port", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        logic   [7  : 0]    tx_data;
        logic   [15 : 0]    baud_rate;
        uart_if_.uart_rx = '1;
        repeat(40)
        begin
            drv_simple2uart_drv_port.get(baud_rate);
            cycle++;
            tx_data = $urandom_range(0,255);
            $display("[ Info  ] | %h | %s | Transmitted data = 0x%x\n" , cycle , name , tx_data);
            send_uart_symbol(tx_data, baud_rate);
        end
    endtask : run_phase

    task send_uart_symbol(logic [7 : 0] tx_data, integer baud_rate);
        // START
        uart_if_.uart_rx = '0;
        repeat(baud_rate) @(posedge uart_if_.clk);
        // SEND SYMBOL
        repeat(8)
        begin
            uart_if_.uart_rx = tx_data[0];
            tx_data = tx_data >> 1;
            repeat(baud_rate) @(posedge uart_if_.clk);
        end
        // STOP
        uart_if_.uart_rx = '1;
        repeat(baud_rate) @(posedge uart_if_.clk);
    endtask : send_uart_symbol

endclass : uart_driver

`endif // UART_DRIVER__SV
