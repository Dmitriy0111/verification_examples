/*
*  File            :   pwm_monitor.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.15
*  Language        :   SystemVerilog
*  Description     :   This is pwm monitor class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "../../rtl/periphery/pwm/pwm.svh"

import test_pkg::*;

class pwm_monitor;

    virtual pwm_if     pwm_if_;

    string              name = "";

    function new(string name="");
        this.name = name;
    endfunction : new

    function build_phase(virtual pwm_if pwm_if_);
        this.pwm_if_ = pwm_if_;
    endfunction : build_phase

    task run_phase();
    endtask : run_phase

endclass : pwm_monitor
