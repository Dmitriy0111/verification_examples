/*
*  File            :   gpio_monitor.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.16
*  Language        :   SystemVerilog
*  Description     :   This is gpio monitor class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef GPIO_MONITOR__SV
`define GPIO_MONITOR__SV

class gpio_monitor #(parameter string if_name = "") extends uvm_component;
    `uvm_component_utils(gpio_monitor)

    virtual gpio_if     gpio_if_;

    string              name = "";

    function new(string name, uvm_component parent);
        super.new(name, parent);
        this.name = name;
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual gpio_if)::get(null, "*",if_name, gpio_if_))
            $fatal("Failed to get %s",if_name);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
    endtask : run_phase

endclass : gpio_monitor

`endif // GPIO_MONITOR__SV
