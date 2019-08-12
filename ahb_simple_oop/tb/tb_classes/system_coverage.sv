/*
*  File            :   system_coverage.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.16
*  Language        :   SystemVerilog
*  Description     :   This is system coverage class
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef SYSTEM_COVERAGE__SV
`define SYSTEM_COVERAGE__SV

class system_coverage #(parameter string if_name = "") extends uvm_component;
    `uvm_component_utils(system_coverage)

    virtual simple_if   s_if_;

    string              name = "";

    integer                     work_freq = 50000000;

    integer                     comp_l[5] = { work_freq/9600 , work_freq/19200 , work_freq/38400 , work_freq/57600 , work_freq/115200 };

    covergroup system_cg with function sample();
        system_addr_cp  : coverpoint s_if_.addr {
            bins    uart_cr_reg     = { UART_ADDR_S | UART_CR_R };
            bins    uart_tx_reg     = { UART_ADDR_S | UART_TX_R };
            bins    uart_rx_reg     = { UART_ADDR_S | UART_RX_R };
            bins    uart_dr_reg     = { UART_ADDR_S | UART_DR_R };

            bins    gpio_0_gpi_reg  = { GPIO_0_ADDR_S | GPIO_GPI_R };
            bins    gpio_0_gpo_reg  = { GPIO_0_ADDR_S | GPIO_GPO_R };
            bins    gpio_0_gpd_reg  = { GPIO_0_ADDR_S | GPIO_GPD_R };

            bins    gpio_1_gpi_reg  = { GPIO_1_ADDR_S | GPIO_GPI_R };
            bins    gpio_1_gpo_reg  = { GPIO_1_ADDR_S | GPIO_GPO_R };
            bins    gpio_1_gpd_reg  = { GPIO_1_ADDR_S | GPIO_GPD_R };

            bins    pwm_0_c_reg     = { PWM_ADDR_S | PWM_C_R };

            option.weight = 0;
        }

        uart_baudrate_cp    : coverpoint s_if_.wd {
            bins    b_9600      = {comp_l[0]};
            bins    b_19200     = {comp_l[1]};
            bins    b_38400     = {comp_l[2]};
            bins    b_57600     = {comp_l[3]};
            bins    b_115200    = {comp_l[4]};
            option.weight = 0;
        }
        
        uart_baudrate_cross : cross system_addr_cp , uart_baudrate_cp {
            bins    baud_9600       = binsof(uart_baudrate_cp) intersect {comp_l[0]} && binsof(system_addr_cp.uart_dr_reg);
            bins    baud_19200      = binsof(uart_baudrate_cp) intersect {comp_l[1]} && binsof(system_addr_cp.uart_dr_reg);
            bins    baud_38400      = binsof(uart_baudrate_cp) intersect {comp_l[2]} && binsof(system_addr_cp.uart_dr_reg);
            bins    baud_57600      = binsof(uart_baudrate_cp) intersect {comp_l[3]} && binsof(system_addr_cp.uart_dr_reg);
            bins    baud_115200     = binsof(uart_baudrate_cp) intersect {comp_l[4]} && binsof(system_addr_cp.uart_dr_reg);
            ignore_bins ib          = ! binsof(system_addr_cp.uart_dr_reg );                                                    // disable others cross bins
        }

        pwm_c_cp    : coverpoint s_if_.wd {
            bins    others  [16]    = { [0 : 255] };
            option.weight = 0;
        }

        pwm_c_cross : cross system_addr_cp, pwm_c_cp {
            ignore_bins ib      = ! binsof(system_addr_cp.pwm_0_c_reg );        // disable others cross bins
        }

        gpio_cp     : coverpoint s_if_.wd {
            bins    gpio_v  [8]     = { ['0 : 255] };
            option.weight = 0;
        }

        gpo_0_cross : cross system_addr_cp, gpio_cp {
            ignore_bins ib      = ! binsof(system_addr_cp.gpio_0_gpo_reg );     // disable others cross bins
        }

        gpd_0_cross : cross system_addr_cp, gpio_cp {
            ignore_bins ib      = ! binsof(system_addr_cp.gpio_0_gpd_reg );     // disable others cross bins
        }

        gpo_1_cross : cross system_addr_cp, gpio_cp {
            ignore_bins ib      = ! binsof(system_addr_cp.gpio_1_gpo_reg );     // disable others cross bins
        }

        gpd_1_cross : cross system_addr_cp, gpio_cp {
            ignore_bins ib      = ! binsof(system_addr_cp.gpio_1_gpd_reg );     // disable others cross bins
        }

    endgroup : system_cg

    function new(string name, uvm_component parent);
        super.new(name, parent);
        this.name = name;
        system_cg = new();
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual simple_if)::get(null, "*",if_name, s_if_))
            $fatal("Failed to get %s",if_name);
    endfunction : build_phase

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        forever
        begin
            @(posedge s_if_.req )
                system_cg.sample();
            @(posedge s_if_.req_ack);
        end

        phase.drop_objection(this);
    endtask : run_phase

endclass : system_coverage

`endif // SYSTEM_COVERAGE__SV
