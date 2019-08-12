/*
*  File            :   pwm_monitor.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.16
*  Language        :   SystemVerilog
*  Description     :   This is pwm monitor class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef PWM_MONITOR__SV
`define PWM_MONITOR__SV

class pwm_monitor #(parameter string if_name = "") extends uvm_component;
    `uvm_component_utils(pwm_monitor)
    // uvm ports
    uvm_put_port    #(pwm_t)    pwm_mon2scb_port;
    // interface
    virtual pwm_if              pwm_if_;
    // current name
    string                      name = "";
    // current cycle variable
    integer                     cycle = 0;
    // class constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        this.name = name;
    endfunction : new
    // uvm build phase
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual pwm_if)::get(null, "*",if_name, pwm_if_))
            $fatal("Failed to get %s",if_name);
        pwm_mon2scb_port = new("pwm_mon2scb_port", this);
    endfunction : build_phase

    // task for finding pwm duty cycle
    task pwm_dc_find();
        integer pwm_c;
        real pwm_dc;
        pwm_c = 0;
        repeat(2**8-1)
        begin
            @(posedge pwm_if_.clk);
            pwm_c += pwm_if_.pwm;
        end
        pwm_dc = pwm_c * 100.0 / (2**8-1);
        pwm_mon2scb_port.put( { pwm_dc , pwm_c } );
        cycle++;
        $display("[ Info  ] | %h | %s | pwm_c = 0x%h, pwm_dc = %2.2f%%\n" , cycle , name , pwm_c, pwm_dc);
    endtask : pwm_dc_find

    task run_phase(uvm_phase phase);
        forever
            pwm_dc_find();
    endtask : run_phase

endclass : pwm_monitor

`endif // PWM_MONITOR__SV
