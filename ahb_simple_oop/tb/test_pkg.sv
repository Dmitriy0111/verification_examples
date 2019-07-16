/*
*  File            :   test_pkg.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.28
*  Language        :   SystemVerilog
*  Description     :   This is uart package
*  Copyright(c)    :   2019 Vlasov D.V.
*/

package test_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

    typedef struct 
    {
        real        pwm_dc;     // pwm duty cycle
        integer     pwm_c;      // pwm counter
    } pwm_t;

    `include "tb_classes/c_r_generator.sv"
    `include "tb_classes/uart_driver.sv"
    `include "tb_classes/uart_monitor.sv"
    `include "tb_classes/gpio_monitor.sv"
    `include "tb_classes/gpio_driver.sv"
    `include "tb_classes/pwm_monitor.sv"
    `include "tb_classes/system_scoreboard.sv"
    `include "tb_classes/system_driver.sv"
    `include "tb_classes/system_coverage.sv"
    `include "tb_classes/system_test.sv"

endpackage : test_pkg