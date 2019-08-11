/*
*  File            :   clk_rst_generator.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.09
*  Language        :   SystemVerilog
*  Description     :   This is uart generator class for uart transmitter unit (with random)
*  Copyright(c)    :   2019 Vlasov D.V.
*/

// class uart generator
class clk_rst_generator extends uvm_component;
    `uvm_component_utils(clk_rst_generator)

    virtual uart_if             uart_if_;

    string                      name = "";

    function new (string name, uvm_component parent);
        super.new(name, parent);
        this.name = name;
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual uart_if)::get(null, "*","uart_if_", uart_if_))
            `uvm_fatal(this.get_name(), "Failed to get uart_if_")
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        $display("[ Info  ] | %h | %s | Starting clock and reset generation" , 0 , name);
        fork : sim_fork
            uart_if_.make_reset();
            uart_if_.make_clock();
        join
        phase.drop_objection(this);
    endtask : run_phase

endclass : clk_rst_generator