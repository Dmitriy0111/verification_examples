/*
*  File            :   uart_coverage.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.11
*  Language        :   SystemVerilog
*  Description     :   This is uart coverage class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef UART_COVERAGE__SV
`define UART_COVERAGE__SV

class uart_coverage extends uvm_component;
    `uvm_component_utils(uart_coverage)

    virtual uart_if             uart_if_;

    string                      name = "";

    integer                     cycle = 0;
    integer                     rep_c = -1;
    integer                     work_freq = 50000000;

    integer                     comp_l[5] = { work_freq/9600 , work_freq/19200 , work_freq/38400 , work_freq/57600 , work_freq/115200 };

    covergroup uart_if_cg with function sample();
        stop_sel_cp     : coverpoint uart_if_.stop_sel
            {
                bins stop_sel_bin[]        = { [0 : 3] };
            }
        comp_cp     : coverpoint uart_if_.comp
            {
                bins standart_comp_bin[] = comp_l;
            }
        tx_data_cp      : coverpoint uart_if_.tx_data
            {
                bins tx_data_bins[16]      = { [0 : 255] };
            }
        cross stop_sel_cp , comp_cp;
    endgroup : uart_if_cg

    extern function      new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task          run_phase(uvm_phase phase);
    extern task          print_info();

endclass : uart_coverage

function uart_coverage::new(string name, uvm_component parent);
    super.new(name, parent);
    uart_if_cg = new();
    this.name = name;
endfunction : new

function void uart_coverage::build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual uart_if)::get(null, "*","uart_if_", uart_if_))
        $fatal("Failed to get uart_if_");
endfunction : build_phase

task uart_coverage::run_phase(uvm_phase phase);
    phase.raise_objection(this);
    repeat(20)//forever
    begin
        @(posedge uart_if_.req_ack);
        @(posedge uart_if_.clk);
        cycle++;
        uart_if_cg.sample();
        print_info();
    end
    phase.drop_objection(this);
endtask : run_phase

task uart_coverage::print_info();
    $display("[ Info  ] | %h | %s | Coverage   | %2.2f%%"  , cycle , name , uart_if_cg.get_coverage() );
endtask : print_info

`endif // UART_COVERAGE__SV
