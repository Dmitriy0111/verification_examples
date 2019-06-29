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

    event       generator_0_e           []  = new[3];
    event       driver_0_e              []  = new[2];
    event       monitor_0_e             []  = new[1];
    event       scoreboard_0_e          []  = new[2];

    function new( virtual uart_if uart_if_ );
        this.uart_if_ = uart_if_;
        uart_generator_         = new( "[ UART generator  ]" , uart_if_ );
        uart_driver_            = new( "[ UART driver     ]" , uart_if_ );
        uart_monitor_           = new( "[ UART monitor    ]" , uart_if_ );
        uart_scoreboard_        = new( "[ UART scoreboard ]" , uart_if_ );
    endfunction : new

    task build();

        generator_mbx_0     =   { generator_2_driver_mbx     , driver_2_generator_mbx   , generator_2_scoreboard_mbx };
        driver_mbx_0        =   { generator_2_driver_mbx     , driver_2_generator_mbx                                };
        monitor_mbx_0       =   { monitor_2_scoreboard_mbx                                                           };
        scoreboard_mbx_0    =   { generator_2_scoreboard_mbx , monitor_2_scoreboard_mbx                              };

        generator_0_e       =   { generator2driver_e     , driver2generator_e   , generator2scoreboard_e };
        driver_0_e          =   { generator2driver_e     , driver2generator_e                            };
        monitor_0_e         =   { monitor2scoreboard_e                                                   };
        scoreboard_0_e      =   { generator2scoreboard_e , monitor2scoreboard_e                          };

        uart_generator_.    build( generator_mbx_0  , generator_0_e   );
        uart_driver_.       build( driver_mbx_0     , driver_0_e      );
        uart_monitor_.      build( monitor_mbx_0    , monitor_0_e     );
        uart_scoreboard_.   build( scoreboard_mbx_0 , scoreboard_0_e  );
        
    endtask : build

    task run(integer resetn_delay, integer T);
        fork
            uart_if_.make_reset(resetn_delay);
            uart_if_.make_clock(T);
            begin
                uart_if_.clean_signals();
                @(posedge uart_if_.resetn);
                uart_if_.tr_en = '1;
                fork
                    uart_generator_.    run();
                    uart_driver_.       run();
                    uart_monitor_.      run();
                    uart_scoreboard_.   run();
                join_none
            end
        join
    endtask : run

endclass : uart_enviroment