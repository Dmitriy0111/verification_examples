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

class uart_scoreboard extends uvm_component;
    `uvm_component_utils(uart_scoreboard)

    uvm_get_port    #(uart_cd)  mon_port;
    uvm_get_port    #(uart_cd)  gen_port;

    virtual uart_if             uart_if_;

    string                      name = "";

    integer                     cycle = 0;
    integer                     rep_c = -1;

    uart_cd                     uart_cd_from_generator[$];
    uart_cd                     uart_cd_from_monitor[$];

    extern function      new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task          print_info( uart_cd uart_cd_ );
    extern task          run_phase(uvm_phase phase);
    extern task          rec_from_uart_generator();
    extern task          rec_from_uart_monitor();
    extern task          compare_data();
        
endclass : uart_scoreboard

function uart_scoreboard::new(string name, uvm_component parent);
    super.new(name, parent);
    this.name = name;
endfunction : new

function void uart_scoreboard::build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual uart_if)::get(null, "*","uart_if_", uart_if_))
        $fatal("Failed to get uart_if_");
    mon_port = new("mon_port",this);
    gen_port = new("gen_port",this);
endfunction : build_phase

task uart_scoreboard::print_info( uart_cd uart_cd_ );
    $display("[ Info  ] | %h | %s | Tx data    | 0x%h\n" , cycle , name , uart_cd_.tx_data);
endtask : print_info

task uart_scoreboard::run_phase(uvm_phase phase);

    forever
    fork : scb_fork
        rec_from_uart_generator();
        rec_from_uart_monitor();
        compare_data();
    join

endtask : run_phase

task uart_scoreboard::rec_from_uart_generator();
    uart_cd uart_cd_0;
    gen_port.get(uart_cd_0);
    print_info(uart_cd_0);
    uart_cd_from_generator.push_front(uart_cd_0);
    
endtask : rec_from_uart_generator

task uart_scoreboard::rec_from_uart_monitor();
    uart_cd uart_cd_1;
    mon_port.get(uart_cd_1);
    print_info(uart_cd_1);
    uart_cd_from_monitor.push_front(uart_cd_1);
    
endtask : rec_from_uart_monitor

task uart_scoreboard::compare_data();

    @( ( uart_cd_from_monitor.size != 0 ) && ( uart_cd_from_generator.size != 0 ) );
    cycle++;
    if( uart_cd_from_monitor.pop_front().tx_data == uart_cd_from_generator.pop_front().tx_data )
        $display("[ Info  ] | %h | %s | test pass\n" , cycle , name );
    else
        $display("[ Error ] | %h | %s | test fail\n" , cycle , name );
    if( cycle == 20 )
        $stop;
endtask : compare_data

`endif // UART_SCOREBOARD__SV
