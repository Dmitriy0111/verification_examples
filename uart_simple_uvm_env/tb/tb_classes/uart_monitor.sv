/*
*  File            :   uart_monitor.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.28
*  Language        :   SystemVerilog
*  Description     :   This is uart monitor class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`ifndef UART_MONITOR__SV
`define UART_MONITOR__SV

class uart_monitor extends uvm_component;
    `uvm_component_utils(uart_monitor)

    uvm_put_port    #(uart_cd)  mon_port;

    virtual uart_if             uart_if_;

    string                      name = "";

    integer                     cycle = 0;
    integer                     rep_c = -1;

    extern function      new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task          print_info( uart_cd uart_cd_ );
    extern task          run_phase(uvm_phase phase);

endclass : uart_monitor

function uart_monitor::new(string name, uvm_component parent);
    super.new(name, parent);
    this.name = name;
endfunction : new

function void uart_monitor::build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual uart_if)::get(null, "*","uart_if_", uart_if_))
        $fatal("Failed to get uart_if_");
    mon_port = new("mon_port",this);
endfunction : build_phase

task uart_monitor::print_info( uart_cd uart_cd_ );
    $display("[ Info  ] | %h | %s | Tx data    | 0x%h\n" , cycle , name , uart_cd_.tx_data);
endtask : print_info

task uart_monitor::run_phase(uvm_phase phase);

    uart_cd     uart_cd_;
    integer     uart_tx_c;

    uart_tx_c = 0;

    repeat(20)//forever
    begin
        @(negedge uart_if_.uart_tx);
        repeat(uart_if_.comp) @(posedge uart_if_.clk);    // start
        repeat(8)                       // data
        begin
            repeat(uart_if_.comp)
            begin
                uart_tx_c += uart_if_.uart_tx;
                @(posedge uart_if_.clk);
            end
            uart_cd_.tx_data = { ( uart_tx_c > ( uart_if_.comp >> 1 ) ) , uart_cd_.tx_data[7 : 1] };
            uart_tx_c = '0;
        end
        repeat(uart_if_.stop_sel)
        begin
            repeat( uart_if_.comp / 2 )
            begin
                if( uart_if_.uart_tx == '0 )
                    uart_tx_c++;
                @(posedge uart_if_.clk);
            end
        end
        cycle++;
        if( uart_tx_c > ( uart_if_.comp / 10 ) )
            $display("[ Error ] | %h | %s | Stop bits count error!", cycle, name );
        this.print_info(uart_cd_);
        mon_port.put(uart_cd_);
    end

endtask : run_phase

`endif // UART_MONITOR__SV
