/*
*  File            :   test_pkg.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.28
*  Language        :   SystemVerilog
*  Description     :   This is uart package
*  Copyright(c)    :   2019 Vlasov D.V.
*/

package test_pkg;

`include "c_r_generator.sv"
`include "gpio_monitor.sv"
`include "pwm_monitor.sv"
`include "uart_monitor.sv"

endpackage : test_pkg