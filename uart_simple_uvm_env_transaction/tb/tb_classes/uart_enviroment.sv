/*
*  File            :   uart_enviroment.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.10
*  Language        :   SystemVerilog
*  Description     :   This is uart enviroment class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef UART_ENVIROMENT__SV
`define UART_ENVIROMENT__SV

// class uart driver
class uart_enviroment extends uvm_env;
    `uvm_component_utils(uart_enviroment);

    // test classes creation
    uart_base_generator     uart_gen;
    uart_driver             uart_drv;
    uart_monitor            uart_mon;
    uart_scoreboard         uart_scb;
    uart_coverage           uart_cov;
    clk_rst_generator       cr_gen;

    uvm_tlm_fifo #(uart_cd) uart_gen2drv;

    string                      name = "";

    integer                     cycle = 0;
    integer                     rep_c = -1;

    extern function      new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass : uart_enviroment

function uart_enviroment::new (string name, uvm_component parent);
    super.new(name,parent);
endfunction : new

function void uart_enviroment::build_phase(uvm_phase phase);
    // UVM ports
    uart_gen2drv            = new( "[ uart_gen2drv    ]" , this );
    // UVM components
    uart_gen = uart_base_generator   ::type_id::create( "[ UART generator  ]" , this );
    uart_drv = uart_driver           ::type_id::create( "[ UART driver     ]" , this );
    uart_mon = uart_monitor          ::type_id::create( "[ UART monitor    ]" , this );
    uart_scb = uart_scoreboard       ::type_id::create( "[ UART scoreboard ]" , this );
    uart_cov = uart_coverage         ::type_id::create( "[ UART coverage   ]" , this );
    cr_gen   = clk_rst_generator     ::type_id::create( "[ System gen      ]" , this );

endfunction : build_phase

function void uart_enviroment::connect_phase(uvm_phase phase);
    uart_drv.drv_port.connect(uart_gen2drv.get_export);
    uart_gen.drv_port.connect(uart_gen2drv.put_export);
    uart_mon.mon_ap.connect(uart_cov.analysis_export);
    uart_mon.mon_ap.connect(uart_scb.mon2scb_ap);
    uart_drv.drv_ap.connect(uart_scb.drv2scb_ap);
endfunction : connect_phase

`endif // UART_ENVIROMENT__SV
