/*
*  File            :   uart_enviroment.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.10
*  Language        :   SystemVerilog
*  Description     :   This is uart enviroment class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import uart_pkg::*;

// class uart driver
class uart_enviroment extends uvm_env;
    `uvm_component_utils(uart_enviroment);

    // test classes creation
    uart_base_generator     uart_generator_;
    uart_driver             uart_driver_;
    uart_monitor            uart_monitor_;
    uart_scoreboard         uart_scoreboard_;
    uart_coverage           uart_coverage_;
    clk_rst_generator       clk_rst_generator_;

    uvm_tlm_fifo #(uart_cd) uart_gen2drv;
    uvm_tlm_fifo #(uart_cd) uart_gen2scb;
    uvm_tlm_fifo #(uart_cd) uart_mon2scb;

    string                      name = "";

    integer                     cycle = 0;
    integer                     rep_c = -1;

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        // UVM ports
        uart_gen2drv            = new( "[ uart_gen2drv    ]" , this );
        uart_mon2scb            = new( "[ uart_mon2scb    ]" , this );
        uart_gen2scb            = new( "[ uart_gen2scb    ]" , this );
        // UVM components
        uart_generator_     = uart_base_generator   ::type_id::create( "[ UART generator  ]" , this );
        uart_driver_        = uart_driver           ::type_id::create( "[ UART driver     ]" , this );
        uart_monitor_       = uart_monitor          ::type_id::create( "[ UART monitor    ]" , this );
        uart_scoreboard_    = uart_scoreboard       ::type_id::create( "[ UART scoreboard ]" , this );
        uart_coverage_      = uart_coverage         ::type_id::create( "[ UART coverage   ]" , this );
        clk_rst_generator_  = clk_rst_generator     ::type_id::create( "[ System gen      ]" , this );

    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        uart_driver_        .drv_port.connect(uart_gen2drv.get_export);
        uart_generator_     .drv_port.connect(uart_gen2drv.put_export);
        uart_generator_     .scb_port.connect(uart_gen2scb.put_export);
        uart_monitor_       .mon_port.connect(uart_mon2scb.put_export);
        uart_scoreboard_    .mon_port.connect(uart_mon2scb.get_export);
        uart_scoreboard_    .gen_port.connect(uart_gen2scb.get_export);
    endfunction : connect_phase

endclass : uart_enviroment