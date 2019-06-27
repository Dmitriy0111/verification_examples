/*
*  File            :   uart_transmitter_tb.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.27
*  Language        :   SystemVerilog
*  Description     :   This is testbench for uart_transmitter
*  Copyright(c)    :   2019 Vlasov D.V.
*/

typedef struct packed 
{
    logic       [7  : 0]    tx_data;
    logic       [15 : 0]    comp;
    logic       [1  : 0]    stop_sel;
} uart_cd;

class btc;  // base test class

    string                      name = "";

    mailbox                     mbx[];
    event                       synch[];

    integer                     cycle = 0;

endclass : btc

class gen_transactor_c extends btc;

    rand    logic   [7  : 0]    tx_data;
    rand    logic   [15 : 0]    comp;
    rand    logic   [1  : 0]    stop_sel;
    rand    integer             baudrate;
    rand    logic   [0  : 0]    real_br;

    integer                     work_freq;
    integer                     baudrate_l[5] = { 9600 , 19200 , 38400 , 57600 , 115200 };

    constraint tx_data_c
    {
        tx_data inside {[0 : 255]};
    }

    constraint stop_sel_c
    {
        stop_sel inside {[0 : 3]};
    }

    constraint real_br_on_c
    {
        real_br == '1;
    }

    constraint real_br_off_c
    {
        real_br == '0;
    }

    constraint comp_c
    {
        if( real_br == '1 )
            comp == work_freq / baudrate;
        else
            comp inside{ [6 : 65530] };
    }

    constraint baudrate_c
    {
        baudrate inside{ baudrate_l };
    }

    task edit_work_freq(integer new_work_freq);
        work_freq = new_work_freq;
    endtask : edit_work_freq

    task print_info();
        $display("[ Info] | %h | %s | Work freq  | %1d"  , cycle , name , work_freq);
        $display("[ Info] | %h | %s | Tx data    | 0x%h" , cycle , name , tx_data);
        $display("[ Info] | %h | %s | Baudrate   | %1d"  , cycle , name , real_br ? baudrate : work_freq / comp );
        $display("[ Info] | %h | %s | comp       | %1d"  , cycle , name , comp);
        $display("[ Info] | %h | %s | Stop bits  | %s\n" , cycle , name , stop_sel == 2'b00 ? "0.5 bits" : 
                                                                          stop_sel == 2'b01 ? "1 bit   " : 
                                                                          stop_sel == 2'b10 ? "1.5 bits" : 
                                                                                              "2 bits  " );
    endtask : print_info

    task en_real_br();
        this.real_br_off_c.constraint_mode(0);
        this.real_br_on_c.constraint_mode(1);
    endtask : en_real_br

    task dis_real_br();
        this.real_br_off_c.constraint_mode(1);
        this.real_br_on_c.constraint_mode(0);
    endtask : dis_real_br

    task rand_make();
        cycle++;
        assert(this.randomize()) else $display("[Error] | %h | %s | Generation random transaction failed", cycle , name );
        uart_transactor_cg.sample;
    endtask : rand_make

    covergroup uart_transactor_cg with function sample();
        stop_sel_cp : coverpoint stop_sel
            {
                bins stop_sel_bin[]        = { [0 : 3] };
            }
        baudrate_cp : coverpoint baudrate
            {
                bins standart_baudrate_bin[] = baudrate_l;
            }
        tx_data_cp : coverpoint tx_data
            {
                bins tx_data_bins[16]      = { [0 : 255] };
            }
        cross stop_sel_cp , baudrate_cp;
    endgroup : uart_transactor_cg

    //uart_transactor_cg uart_transactor_cg_;

    function new(integer work_freq_i, string name_i = "" );
        this.work_freq = work_freq_i;
        this.name = name_i;
        uart_transactor_cg = new;
    endfunction : new

endclass : gen_transactor_c

class uart_generator extends btc;

    gen_transactor_c    gen_transactor;
    uart_cd             uart_cd_;

    function new(integer work_freq_i, string name_i = "" );
        gen_transactor = new(50000000, "UART transactor");
        this.name = name_i;
    endfunction : new

    task build( mailbox mbx_i[] = null, event synch_i[] = null );
        this.mbx          = new[mbx_i.size()];
        foreach(mbx[i])
            this.mbx[i]   = mbx_i[i];
        this.synch        = new[synch_i.size()];
        foreach(synch[i])
            this.synch[i] = synch_i[i];
        gen_transactor.en_real_br;
    endtask : build

    task run(ref logic clk);
        forever
        begin
            wait(synch[0].triggered);
            gen_transactor.rand_make();
            gen_transactor.print_info();
            uart_cd_.tx_data = gen_transactor.tx_data;
            uart_cd_.stop_sel = gen_transactor.stop_sel;
            uart_cd_.comp = gen_transactor.comp;
            mbx[1].put(uart_cd_);
            ->synch[1];
            @(posedge clk);
        end
    endtask : run

endclass : uart_generator

class uart_driver extends btc;

    uart_cd             uart_cd_;

    function new( string name_i = "" );
        this.name = name_i;
    endfunction : new

    task build( mailbox mbx_i[] = null, event synch_i[] = null );
        this.mbx          = new[mbx_i.size()];
        foreach(mbx[i])
            this.mbx[i]   = mbx_i[i];
        this.synch        = new[synch_i.size()];
        foreach(synch[i])
            this.synch[i] = synch_i[i];
    endtask : build

    task run(ref logic clk, ref logic [7 : 0] tx_data, ref logic [15 : 0] comp, ref logic [1 : 0] stop_sel, ref logic tr_en, ref logic req, ref logic req_ack);
        forever
        begin
            ->synch[0];
            wait(synch[1].triggered);
            mbx[1].get(uart_cd_);
            
            $display("tx_data = 0x%h",uart_cd_.tx_data);

            stop_sel = uart_cd_.stop_sel;
            tx_data = uart_cd_.tx_data;
            comp = uart_cd_.comp;
            req = '1;
            @(posedge req_ack);
            req = '0;
            @(posedge clk);
        end
    endtask : run

endclass : uart_driver

class uart_enviroment;
    // test classes creation
    uart_generator  uart_generator_         = new("[ UART generator ]");
    uart_driver     uart_driver_            = new("[ UART driver    ]");
    //mailboxes
    mailbox     mbx_generator_2_driver      = new( );
    mailbox     mbx_driver_2_generator      = new( );

    mailbox     mbx_generator_0         []  = new[2];
    mailbox     mbx_driver_0            []  = new[2];

    //events
    event       synch_gen_driver;
    event       synch_driver_gen;

    event       generator_0_e           []  = new[2];
    event       driver_0_e              []  = new[2];

    task build();
        mbx_generator_0 =   { mbx_generator_2_driver , mbx_driver_2_generator };
        mbx_driver_0    =   { mbx_generator_2_driver , mbx_driver_2_generator };
        generator_0_e   =   { synch_gen_driver , synch_driver_gen };
        driver_0_e      =   { synch_gen_driver , synch_driver_gen };

        uart_generator_.build   ( mbx_generator_0 , generator_0_e );
        uart_driver_.build      ( mbx_driver_0    , driver_0_e    );
    endtask : build

    task run(ref logic clk, ref logic [7 : 0] tx_data, ref logic [15 : 0] comp, ref logic [1 : 0] stop_sel, ref logic tr_en, ref logic req, ref logic req_ack);
        fork
            uart_generator_.run(clk);
            uart_driver_.run(clk, tx_data, comp, stop_sel, tr_en, req, req_ack);
        join
    endtask : run

endclass : uart_enviroment

module uart_transmitter_tb();

    timeprecision       1ns;
    timeunit            1ns;
    
    parameter           T = 10,
                        resetn_delay = 7,
                        repeat_cycles = 400;

    // reset and clock
    logic   [0  : 0]    clk;        // clk
    logic   [0  : 0]    resetn;     // resetn
    // controller side interface
    logic   [0  : 0]    tr_en;      // transmitter enable
    logic   [15 : 0]    comp;       // compare input for setting baudrate
    logic   [7  : 0]    tx_data;    // data for transfer
    logic   [0  : 0]    req;        // request signal
    logic   [1  : 0]    stop_sel;   // stop select
    logic   [0  : 0]    req_ack;    // acknowledgent signal
    // uart tx side
    logic   [0  : 0]    uart_tx;    // UART tx wire

    uart_transmitter 
    uart_transmitter_0
    (
        // reset and clock
        .clk        ( clk       ),  // clk
        .resetn     ( resetn    ),  // resetn
        // controller side interface
        .tr_en      ( tr_en     ),  // transmitter enable
        .comp       ( comp      ),  // compare input for setting baudrate
        .tx_data    ( tx_data   ),  // data for transfer
        .req        ( req       ),  // request signal
        .stop_sel   ( stop_sel  ),  // stop select
        .req_ack    ( req_ack   ),  // acknowledgent signal
        // uart tx side
        .uart_tx    ( uart_tx   )   // UART tx wire
    );

    uart_enviroment uart_enviroment_ = new();

    // clock generation
    initial
    begin
        clk = '0;
        forever
            #(T/2) clk = ~clk;
    end
    // reset generation
    initial
    begin
        resetn = '0;
        repeat(resetn_delay) @(posedge clk);
        resetn = '1;
    end
    // stop 
    initial
    begin
        tx_data = '1;
        uart_tx = '1;
        tr_en = '1;
        uart_enviroment_.build();
        @(posedge resetn);
        uart_enviroment_.run(clk, tx_data, comp, stop_sel, tr_en, req, req_ack);
        $stop;
    end

endmodule : uart_transmitter_tb
