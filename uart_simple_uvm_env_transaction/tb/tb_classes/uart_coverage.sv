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

// class uart generator
class uart_coverage extends uvm_subscriber #(uart_cd);
    `uvm_component_utils(uart_coverage)

    string      name = "";

    uart_cd     uart_cd_cov;

    integer     cycle = 0;
    integer     rep_c = -1;
    integer     work_freq = 50000000;

    integer     comp_l[5] = { work_freq/9600 , work_freq/19200 , work_freq/38400 , work_freq/57600 , work_freq/115200 };

    covergroup uart_cg with function sample();
        stop_sel_cp     : coverpoint uart_cd_cov.stop_sel
            {
                bins stop_sel_bin[]        = { [0 : 3] };
            }
        comp_cp     : coverpoint uart_cd_cov.comp
            {
                bins standart_comp_bin[] = comp_l;
            }
        tx_data_cp      : coverpoint uart_cd_cov.tx_data
            {
                bins tx_data_bins[16]      = { [0 : 255] };
            }
        cross stop_sel_cp , comp_cp;
    endgroup : uart_cg

    extern function      new(string name, uvm_component parent);
    extern function void write(uart_cd t);
    extern task          print_info();

endclass : uart_coverage

function uart_coverage::new(string name, uvm_component parent);
    super.new(name, parent);
    uart_cg = new();
endfunction : new

function void uart_coverage::write(uart_cd t);
    uart_cd_cov = t;
    cycle++;
    uart_cg.sample();
    print_info();
endfunction : write

task uart_coverage::print_info();
    `uvm_info(this.get_name(), $sformatf("[ Info  ] | %h | Coverage   | %2.2f%%", cycle, uart_cg.get_coverage()), UVM_MEDIUM)
endtask : print_info

`endif //UART_COVERAGE__SV
