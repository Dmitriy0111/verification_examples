/*
*  File            :   system_scoreboard.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.16
*  Language        :   SystemVerilog
*  Description     :   This is system scoreboard class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::*;

// class uart monitor
class system_scoreboard extends uvm_component;

    `uvm_component_utils(system_scoreboard)

    // uvm ports
    uvm_get_port    #(logic [7  : 0])   uart_mon2scb_port;
    uvm_get_port    #(pwm_t         )   pwm_mon2scb_port;

    string                      name = "";

    integer                     cycle = 0;
    integer                     rep_c = -1;

    logic   [7  : 0]            uart_monitor_q[$];
    pwm_t                       pwm_monitor_q[$];

    function new (string name, uvm_component parent);
        super.new(name, parent);
        this.name = name;
    endfunction : new

    function void build_phase(uvm_phase phase);
        uart_mon2scb_port = new("uart_mon2scb_port",this);
        pwm_mon2scb_port = new("pwm_mon2scb_port",this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);

        forever
        fork : scb_fork
            rec_from_pwm_monitor();
            rec_from_uart_monitor();
        join

    endtask : run_phase

    task rec_from_pwm_monitor();
        pwm_t               pwm_mon_v;
        pwm_mon2scb_port.get(pwm_mon_v);
        $display("[ Info  ] | %h | %s | pwm_c = 0x%h, pwm_dc = %2.2f%%\n" , cycle , name , pwm_mon_v.pwm_c , pwm_mon_v.pwm_dc );
        pwm_monitor_q.push_back(pwm_mon_v);
    endtask : rec_from_pwm_monitor

    task rec_from_uart_monitor();
        logic   [7  : 0]    uart_mon_v;
        uart_mon2scb_port.get(uart_mon_v);
        $display("[ Info  ] | %h | %s | uart_rec data = 0x%h\n" , cycle , name , uart_mon_v);
        uart_monitor_q.push_back(uart_mon_v);
    endtask : rec_from_uart_monitor

endclass : system_scoreboard