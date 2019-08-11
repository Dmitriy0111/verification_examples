/*
*  File            :   uart_test_rand.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.09
*  Language        :   SystemVerilog
*  Description     :   This is uart enviroment class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef UART_TEST_RAND__SV
`define UART_TEST_RAND__SV

// class uart enviroment
class uart_test_rand extends uvm_test;
    `uvm_component_utils(uart_test_rand);

    uart_enviroment       uart_enviroment_;

    extern function      new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);

endclass : uart_test_rand

function uart_test_rand::new (string name, uvm_component parent);
    super.new(name,parent);
endfunction : new

function void uart_test_rand::build_phase(uvm_phase phase);
    uart_base_generator::type_id::set_type_override(uart_generator_rand::get_type());
    uart_enviroment_ = uart_enviroment::type_id::create("uart_enviroment_",this);
endfunction : build_phase

`endif // UART_TEST_RAND__SV
