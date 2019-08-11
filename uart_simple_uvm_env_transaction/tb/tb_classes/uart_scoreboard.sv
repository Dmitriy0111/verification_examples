/*
*  File            :   uart_scoreboard.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.28
*  Language        :   SystemVerilog
*  Description     :   This is uart scoreboard class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef UART_SCOREBOARD__SV
`define UART_SCOREBOARD__SV

`uvm_analysis_imp_decl(_drv_rec)
`uvm_analysis_imp_decl(_mon_rec)

// class uart monitor
class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)

    uvm_analysis_imp_drv_rec    #(uart_cd, uart_scoreboard)     drv2scb_ap;
    uvm_analysis_imp_mon_rec    #(uart_cd, uart_scoreboard)     mon2scb_ap;

    virtual uart_if             uart_if_;

    integer                     cycle = 0;
    integer                     rep_c = -1;

    uart_cd                     uart_cd_from_driver[$];
    uart_cd                     uart_cd_from_monitor[$];

    extern function      new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task          print_info( uart_cd uart_cd_ );
    extern task          run_phase(uvm_phase phase);
    extern task          compare_data();
    extern function void write_drv_rec(uart_cd t);
    extern function void write_mon_rec(uart_cd t);

endclass : uart_scoreboard

function uart_scoreboard::new(string name, uvm_component parent);
    super.new(name, parent);
    drv2scb_ap = new("drv2scb_ap", this);
    mon2scb_ap = new("mon2scb_ap", this);
endfunction : new

function void uart_scoreboard::build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual uart_if)::get(null, "*","uart_if_", uart_if_))
        `uvm_fatal(this.get_name(), "Failed to get uart_if_")
endfunction : build_phase

task uart_scoreboard::print_info( uart_cd uart_cd_ );
    `uvm_info(this.get_name(), $sformatf("| Cycle = 0x%h | Tx data = 0x%h |\n" , cycle , uart_cd_.tx_data), UVM_MEDIUM)
endtask : print_info

task uart_scoreboard::run_phase(uvm_phase phase);
    forever
        compare_data();

endtask : run_phase

task uart_scoreboard::compare_data();

    @( ( uart_cd_from_monitor.size != 0 ) && ( uart_cd_from_driver.size != 0 ) );
    cycle++;
    if( uart_cd_from_monitor.pop_front().tx_data == uart_cd_from_driver.pop_front().tx_data )
        `uvm_info(this.get_name(), $sformatf("| Test pass | cycle = 0x%h |", cycle), UVM_MEDIUM)
    else
        `uvm_info(this.get_name(), $sformatf("| Test fail | cycle = 0x%h |", cycle), UVM_MEDIUM)
    if( cycle == 20 )
        $stop;
endtask : compare_data

function void uart_scoreboard::write_drv_rec(uart_cd t);
    print_info(t);
    uart_cd_from_driver.push_front(t);
endfunction : write_drv_rec

function void uart_scoreboard::write_mon_rec(uart_cd t);
    print_info(t);
    uart_cd_from_monitor.push_front(t);
endfunction : write_mon_rec

`endif // UART_SCOREBOARD__SV
