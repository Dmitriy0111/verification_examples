/*
*  File            :   uart_enviroment.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.06.28
*  Language        :   SystemVerilog
*  Description     :   This is uart enviroment class for uart transmitter unit
*  Copyright(c)    :   2019 Vlasov D.V.
*/

import uart_pkg::*;

// class uart enviroment
class uart_enviroment;

    virtual uart_if     uart_if_;
    // test classes creation
    uart_generator      uart_generator_;
    uart_driver         uart_driver_;
    uart_monitor        uart_monitor_;
    uart_scoreboard     uart_scoreboard_;
    //mailboxes
    mailbox     generator_2_driver_mbx      = new( );
    mailbox     generator_2_scoreboard_mbx  = new( );

    mailbox     driver_2_generator_mbx      = new( );

    mailbox     monitor_2_scoreboard_mbx    = new( );

    mailbox     generator_mbx_0         []  = new[3];
    mailbox     driver_mbx_0            []  = new[2];
    mailbox     monitor_mbx_0           []  = new[1];
    mailbox     scoreboard_mbx_0        []  = new[2];

    //events
    event       generator2driver_e;
    event       generator2scoreboard_e;

    event       driver2generator_e;

    event       monitor2scoreboard_e;

    event       dis_ev                  []  = new[4];

    event       generator_0_e           []  = new[4];
    event       driver_0_e              []  = new[3];
    event       monitor_0_e             []  = new[2];
    event       scoreboard_0_e          []  = new[3];

    function new( virtual uart_if uart_if_ );
        this.uart_if_ = uart_if_;
        uart_generator_         = new( "[ UART generator  ]" , uart_if_ );
        uart_driver_            = new( "[ UART driver     ]" , uart_if_ );
        uart_monitor_           = new( "[ UART monitor    ]" , uart_if_ );
        uart_scoreboard_        = new( "[ UART scoreboard ]" , uart_if_ );
    endfunction : new

    task build( integer rep_c_i = -1 );

        generator_mbx_0     =   { generator_2_driver_mbx     , driver_2_generator_mbx   , generator_2_scoreboard_mbx };
        driver_mbx_0        =   { generator_2_driver_mbx     , driver_2_generator_mbx                                };
        monitor_mbx_0       =   { monitor_2_scoreboard_mbx                                                           };
        scoreboard_mbx_0    =   { generator_2_scoreboard_mbx , monitor_2_scoreboard_mbx                              };

        generator_0_e       =   { generator2driver_e     , driver2generator_e   , generator2scoreboard_e };
        driver_0_e          =   { generator2driver_e     , driver2generator_e                            };
        monitor_0_e         =   { monitor2scoreboard_e                                                   };
        scoreboard_0_e      =   { generator2scoreboard_e , monitor2scoreboard_e                          };

        uart_generator_.    build( generator_mbx_0  , generator_0_e  , dis_ev[0] );
        uart_driver_.       build( driver_mbx_0     , driver_0_e     , dis_ev[1] );
        uart_monitor_.      build( monitor_mbx_0    , monitor_0_e    , dis_ev[2] );
        uart_scoreboard_.   build( scoreboard_mbx_0 , scoreboard_0_e , dis_ev[3] );

        uart_generator_.rep_c = rep_c_i;
        uart_driver_.rep_c = rep_c_i;
        uart_monitor_.rep_c = rep_c_i;
        uart_scoreboard_.rep_c = rep_c_i;
        
    endtask : build

    task run(integer resetn_delay = 7, integer T = 10);
    begin
        fork : sim_fork
            uart_if_.make_reset(resetn_delay);
            uart_if_.make_clock(T);
            begin
                uart_if_.clean_signals();
                @(posedge uart_if_.resetn);
                uart_if_.tr_en = '1;
                fork : run_env
                    uart_generator_.    run();
                    uart_driver_.       run();
                    uart_monitor_.      run();
                    uart_scoreboard_.   run();
                join_none
            end
            begin
                foreach(dis_ev[i])
                fork
                    automatic integer k = i;
                        wait(dis_ev[k].triggered);
                join_none
                wait fork;
                disable sim_fork;
            end
        join
    end
    endtask : run

    task print_info();
        $display("Simulation stop");
    endtask : print_info

    task free_resource();
        generator_mbx_0.delete();
        driver_mbx_0.delete();
        monitor_mbx_0.delete();
        scoreboard_mbx_0.delete();
        dis_ev.delete();
        generator_0_e.delete();
        driver_0_e.delete();
        monitor_0_e.delete();
        scoreboard_0_e.delete();
        $display("Resources is free");
    endtask : free_resource

endclass : uart_enviroment
