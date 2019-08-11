/*
*  File            :   uart_generator_rand.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.09
*  Language        :   SystemVerilog
*  Description     :   This is uart generator class for uart transmitter unit (with random)
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef UART_GENERATOR_RAND__SV
`define UART_GENERATOR_RAND__SV

// class uart generator
class uart_generator_rand extends uart_base_generator;
    `uvm_component_utils(uart_generator_rand)

    extern function         new(string name, uvm_component parent);
    extern function void    build_phase(uvm_phase phase);
    extern function void    settings();
    extern task             print_info();
    extern function uart_cd get_data();

endclass : uart_generator_rand

function uart_generator_rand::new (string name, uvm_component parent);
    super.new(name, parent);
endfunction : new

function void uart_generator_rand::build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual uart_if)::get(null, "*","uart_if_", uart_if_))
        `uvm_fatal(this.get_name(), "Failed to get uart_if_")
    drv_port = new("drv_port",this);
    uart_transactor_ = new(50000000, "[ UART transactor ]");
    uart_transactor_.en_real_br;
endfunction : build_phase

function void uart_generator_rand::settings();
endfunction : settings

task uart_generator_rand::print_info();
    `uvm_info   (
                    this.get_name(), 
                    $sformatf("| Work freq = %1d | Tx data = 0x%h | Baudrate = %1d | comp = %1d | Stop bits = %s | Coverage = %2.2f |", uart_transactor_.work_freq,
                                                                                                                                        uart_transactor_.tx_data,
                                                                                                                                        uart_transactor_.work_freq / uart_transactor_.comp,
                                                                                                                                        uart_transactor_.comp,
                                                                                                                                        uart_transactor_.stop_sel == 2'b00 ? "0.5 bits" : 
                                                                                                                                        uart_transactor_.stop_sel == 2'b01 ? "1 bit   " : 
                                                                                                                                        uart_transactor_.stop_sel == 2'b10 ? "1.5 bits" : 
                                                                                                                                                                             "2 bits  ",
                                                                                                                                        uart_transactor_.get_cov()), 
                    UVM_MEDIUM
                )
endtask : print_info

function uart_cd uart_generator_rand::get_data();

    uart_cd ret_data;

    uart_transactor_.rand_make();
    cycle++;
    this.print_info();
    ret_data.tx_data = uart_transactor_.tx_data;
    ret_data.stop_sel = uart_transactor_.stop_sel;
    ret_data.comp = uart_transactor_.comp;

    return ret_data;

endfunction : get_data

`endif // UART_GENERATOR_RAND__SV
