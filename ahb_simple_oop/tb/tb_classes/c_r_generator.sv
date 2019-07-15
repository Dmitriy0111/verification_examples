/*
*  File            :   c_r_generator.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.15
*  Language        :   SystemVerilog
*  Description     :   This is clock reset generator class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import test_pkg::*;

class c_r_generator #(parameter T = 0, resetn_delay = 0);

    virtual simple_if   s_if_0;

    string              name = "";

    function new(string name="");
        this.name = name;
    endfunction : new

    function build_phase(virtual simple_if s_if_0);
        this.s_if_0 = s_if_0;
    endfunction : build_phase

    task run_phase();
        fork
            // generate clock
            begin
                s_if_0.clk = '0;
                forever
                    #(T/2) s_if_0.clk = !s_if_0.clk;
            end
            // generate reset
            begin
                s_if_0.resetn = '0;
                repeat( resetn_delay ) @(posedge s_if_0.clk);
                s_if_0.resetn = '1;
            end
        join
    endtask : run_phase

endclass : c_r_generator
