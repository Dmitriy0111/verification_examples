/*
*  File            :   uart_base_generator.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.10
*  Language        :   SystemVerilog
*  Description     :   This is uart base generator class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef UART_BASE_GENERATOR__SV
`define UART_BASE_GENERATOR__SV

virtual class uart_base_generator extends uvm_component;
    `uvm_component_utils(uart_base_generator)

    uvm_put_port    #(uart_cd)  drv_port;
    uvm_put_port    #(uart_cd)  scb_port;

    virtual uart_if             uart_if_;

    string                      name = "";

    integer                     cycle = 0;
    integer                     rep_c = -1;

    uart_transactor             uart_transactor_;
    uart_cd                     uart_cd_;

    extern function      new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task          run_phase(uvm_phase phase);
    pure virtual function uart_cd get_data();

endclass : uart_base_generator

function uart_base_generator::new(string name, uvm_component parent);
    super.new(name, parent);
    this.name = name;
endfunction : new

function void uart_base_generator::build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual uart_if)::get(null, "*","uart_if_", uart_if_))
        $fatal("Failed to get uart_if_");
    drv_port = new("drv_port",this);
    scb_port = new("scb_port",this);
endfunction : build_phase

task uart_base_generator::run_phase(uvm_phase phase);
    phase.raise_objection(this);
    repeat(20)//forever
    begin
        uart_cd_ = get_data();
        drv_port.put(uart_cd_);
        scb_port.put(uart_cd_);
        @(posedge uart_if_.clk);
    end
    phase.drop_objection(this);
endtask : run_phase

`endif // UART_BASE_GENERATOR__SV
