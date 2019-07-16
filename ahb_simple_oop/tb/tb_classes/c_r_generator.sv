/*
*  File            :   c_r_generator.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.16
*  Language        :   SystemVerilog
*  Description     :   This is clock reset generator class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::*;

class c_r_generator #(parameter string if_name = "", parameter T = 0, resetn_delay = 0) extends uvm_component;
    `uvm_component_utils(c_r_generator)

    virtual simple_if   s_if_;

    string              name = "";

    function new (string name, uvm_component parent);
        super.new(name, parent);
        this.name = name;
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual simple_if)::get(null, "*",if_name, s_if_))
            $fatal("Failed to get %s",if_name);
    endfunction : build_phase

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        forever
        fork
            // generate clock
            begin
                s_if_.clk = '0;
                forever
                    #(T/2) s_if_.clk = !s_if_.clk;
            end
            // generate reset
            begin
                s_if_.resetn = '0;
                repeat( resetn_delay ) @(posedge s_if_.clk);
                s_if_.resetn = '1;
            end
        join

        phase.drop_objection(this);
    endtask : run_phase

endclass : c_r_generator
