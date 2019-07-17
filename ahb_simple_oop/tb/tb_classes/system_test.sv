/*
*  File            :   system_test.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.16
*  Language        :   SystemVerilog
*  Description     :   This is system test class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::*;

class system_test extends uvm_test;
    `uvm_component_utils(system_test);

    // test classes creation
    c_r_generator       #( "s_if_0"    , 10 , 7 )   c_r_generator_;
    gpio_driver         #( "gpio_if_0"          )   gpio_driver_0;
    gpio_driver         #( "gpio_if_1"          )   gpio_driver_1;
    gpio_monitor        #( "gpio_if_0"          )   gpio_monitor_0;
    gpio_monitor        #( "gpio_if_1"          )   gpio_monitor_1;
    system_driver       #( "s_if_0"             )   system_driver_;
    uart_monitor        #( "uart_if_0"          )   uart_monitor_;
    uart_driver         #( "uart_if_0"          )   uart_driver_;
    system_scoreboard                               system_scoreboard_;
    pwm_monitor         #( "pwm_if_0"           )   pwm_monitor_;
    system_coverage     #( "s_if_0"             )   system_coverage_;

    uvm_tlm_fifo    #(logic [7  : 0])   uart_mon2scb_tlm;
    uvm_tlm_fifo    #(pwm_t         )   pwm_mon2scb_tlm;
    uvm_tlm_fifo    #(logic [15 : 0])   drv_simple2uart_mon_tlm;
    uvm_tlm_fifo    #(logic [15 : 0])   drv_simple2uart_drv_tlm;

    function new( string name, uvm_component parent );
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        // UVM ports
        uart_mon2scb_tlm        = new( "[ uart_mon2scb_tlm        ]" , this );
        pwm_mon2scb_tlm         = new( "[ pwm_mon2scb_tlm         ]" , this );
        drv_simple2uart_mon_tlm = new( "[ drv_simple2uart_mon_tlm ]" , this );
        drv_simple2uart_drv_tlm = new( "[ drv_simple2uart_drv_tlm ]" , this );
        // UVM components
        c_r_generator_          = new( "[ CR     generator  ]" , this );
        system_driver_          = new( "[ SYSTEM driver     ]" , this );
        uart_monitor_           = new( "[ UART   monitor    ]" , this );
        uart_driver_            = new( "[ UART   driver     ]" , this );
        system_scoreboard_      = new( "[ SYSTEM scoreboard ]" , this );
        pwm_monitor_            = new( "[ PWM    monitor    ]" , this );
        gpio_driver_0           = new( "[ GPIO   driver 0   ]" , this );
        gpio_driver_1           = new( "[ GPIO   driver 1   ]" , this );
        gpio_monitor_0          = new( "[ GPIO   monitor 0  ]" , this );
        gpio_monitor_1          = new( "[ GPIO   monitor 1  ]" , this );
        system_coverage_        = new( "[ SYSTEM coverage   ]" , this );

    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        system_driver_      .drv_simple2uart_mon_port   .connect( drv_simple2uart_mon_tlm.put_export );
        system_driver_      .drv_simple2uart_drv_port   .connect( drv_simple2uart_drv_tlm.put_export );

        pwm_monitor_        .pwm_mon2scb_port           .connect( pwm_mon2scb_tlm.put_export );

        uart_monitor_       .drv_simple2uart_mon_port   .connect( drv_simple2uart_mon_tlm.get_export );
        uart_monitor_       .uart_mon2scb_port          .connect( uart_mon2scb_tlm.put_export        );

        uart_driver_        .drv_simple2uart_drv_port   .connect( drv_simple2uart_drv_tlm.get_export );

        system_scoreboard_  .uart_mon2scb_port          .connect( uart_mon2scb_tlm.get_export );
        system_scoreboard_  .pwm_mon2scb_port           .connect( pwm_mon2scb_tlm.get_export  );
    endfunction : connect_phase

endclass : system_test
