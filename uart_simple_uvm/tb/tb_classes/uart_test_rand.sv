/*
*  File            :   uart_test_rand.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.09
*  Language        :   SystemVerilog
*  Description     :   This is uart enviroment class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef UART_TEST_RAND__SV
`define UART_TEST_RAND__SV

class uart_test_rand extends uvm_test;

    `uvm_component_utils(uart_test_rand);

    virtual uart_if         uart_if_;
    // test classes creation
    uart_generator_rand     uart_generator_;
    uart_driver             uart_driver_;
    uart_monitor            uart_monitor_;
    uart_scoreboard         uart_scoreboard_;
    uart_coverage           uart_coverage_;

    uvm_tlm_fifo #(uart_cd) uart_gen2drv;
    uvm_tlm_fifo #(uart_cd) uart_gen2scb;
    uvm_tlm_fifo #(uart_cd) uart_mon2scb;

    extern function      new( string name, uvm_component parent );
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task          run_phase(uvm_phase phase);
    extern task          print_info();

endclass : uart_test_rand

function uart_test_rand::new( string name, uvm_component parent );
    super.new(name,parent);
        if(!uvm_config_db #(virtual uart_if)::get(null, "*","uart_if_", uart_if_))
    $fatal("Failed to get uart_if_");
    
endfunction : new

function void uart_test_rand::build_phase(uvm_phase phase);
    // UVM ports
    uart_gen2drv            = new( "[ uart_gen2drv    ]" , this );
    uart_mon2scb            = new( "[ uart_mon2scb    ]" , this );
    uart_gen2scb            = new( "[ uart_gen2scb    ]" , this );
    // UVM components
    uart_generator_         = new( "[ UART generator  ]" , this );
    uart_driver_            = new( "[ UART driver     ]" , this );
    uart_monitor_           = new( "[ UART monitor    ]" , this );
    uart_scoreboard_        = new( "[ UART scoreboard ]" , this );
    uart_coverage_          = new( "[ UART coverage   ]" , this );

endfunction : build_phase

function void uart_test_rand::connect_phase(uvm_phase phase);
    uart_driver_        .drv_port.connect(uart_gen2drv.get_export);
    uart_generator_     .drv_port.connect(uart_gen2drv.put_export);
    uart_generator_     .scb_port.connect(uart_gen2scb.put_export);
    uart_monitor_       .mon_port.connect(uart_mon2scb.put_export);
    uart_scoreboard_    .mon_port.connect(uart_mon2scb.get_export);
    uart_scoreboard_    .gen_port.connect(uart_gen2scb.get_export);

endfunction : connect_phase

task uart_test_rand::run_phase(uvm_phase phase);
begin

    phase.raise_objection(this);

    fork : sim_fork
        uart_if_.make_reset();
        uart_if_.make_clock();
    join

    phase.drop_objection(this);

end
endtask : run_phase

task uart_test_rand::print_info();
    $display("Simulation stop");
endtask : print_info

`endif // UART_TEST_RAND__SV
