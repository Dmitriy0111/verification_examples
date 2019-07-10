/*
*  File            :   uart_test_direct.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.09
*  Language        :   SystemVerilog
*  Description     :   This is uart enviroment class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import uart_pkg::*;

// class uart enviroment
class uart_test_direct extends uvm_test;
    `uvm_component_utils(uart_test_direct);

    uart_enviroment       uart_enviroment_;

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        uart_base_generator::type_id::set_type_override(uart_generator_direct::get_type());
        uart_enviroment_ = uart_enviroment::type_id::create("uart_enviroment_",this);
    endfunction : build_phase

endclass : uart_test_direct
