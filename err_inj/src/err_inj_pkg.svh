`ifndef ERR_INJ_PKG__SVH
`define ERR_INJ_PKG__SVH

package err_inj_pkg;
    `include "uvm_macros.svh" 
    import uvm_pkg::*;

    import test_param_pkg::*;

    class base_err_injector extends uvm_object;
        `uvm_object_utils(base_err_injector)
        int             arr_size = 0;
        bit [63 : 0]    iter_n;

        function new(string name = "base_err_injector");
            super.new(name);
        endfunction : new

        virtual task gen_err(ref logic [DW-1 : 0] in_arr []);
            `uvm_fatal("INFO", "This is base gen_err task")
        endtask : gen_err

        task inject_errors(input int err_cnt, ref logic [DW-1 : 0] in_arr []);
            arr_size = in_arr.size();
            foreach(in_arr[ii])
                in_arr[ii] = '0;

            iter_n = 0;

            for(int ii = 0; ii < err_cnt; ii++) begin
                gen_err(in_arr);
            end
            `uvm_info("INFO", $sformatf("iter_num = %d", iter_n), UVM_HIGH)
        endtask : inject_errors

    endclass : base_err_injector

    class err_injector_0 extends base_err_injector;
        `uvm_object_utils(err_injector_0)

        randc   int     word_pos_c;
        randc   int     bit_pos_c;

        function new(string name = "err_injector_0");
            super.new(name);
        endfunction : new

        task gen_err(ref logic [DW-1 : 0] in_arr []);
            do begin
                randomize(word_pos_c)   with { word_pos_c inside {[0 : arr_size-1]} ; };
                randomize(bit_pos_c)    with { bit_pos_c  inside {[0 : DW-1]} ; };
                iter_n++;
            end while(in_arr[word_pos_c][bit_pos_c]);
            in_arr[word_pos_c][bit_pos_c] = '1;
        endtask : gen_err

    endclass : err_injector_0

    class err_injector_1 extends base_err_injector;
        `uvm_object_utils(err_injector_1)

        rand    int     word_pos;
        rand    int     bit_pos;

        function new(string name = "err_injector_1");
            super.new(name);
        endfunction : new

        task gen_err(ref logic [DW-1 : 0] in_arr []);
            do begin
                randomize(word_pos)     with { word_pos inside {[0 : arr_size-1]} ; };
                randomize(bit_pos)      with { bit_pos  inside {[0 : DW-1]} ; };
                iter_n++;
            end while(in_arr[word_pos][bit_pos]);
            in_arr[word_pos][bit_pos] = '1;
        endtask : gen_err

    endclass : err_injector_1

    class err_injector_2 extends base_err_injector;
        `uvm_object_utils(err_injector_2)

        randc   int     bit_pos_in_arr_c;
                int     word_pos_v;
                int     bit_pos_v;

        function new(string name = "err_injector_2");
            super.new(name);
        endfunction : new

        task gen_err(ref logic [DW-1 : 0] in_arr []);
            do begin
                randomize(bit_pos_in_arr_c)     with { bit_pos_in_arr_c inside {[0 : DW*arr_size-1]} ; };
                word_pos_v = bit_pos_in_arr_c / DW;
                bit_pos_v  = bit_pos_in_arr_c - word_pos_v * DW;
                iter_n++;
            end while(in_arr[word_pos_v][bit_pos_v]);
            in_arr[word_pos_v][bit_pos_v] = '1;
        endtask : gen_err

    endclass : err_injector_2

    class err_injector_3 extends base_err_injector;
        `uvm_object_utils(err_injector_3)

        rand    int     bit_pos_in_arr;
                int     word_pos_v;
                int     bit_pos_v;

        function new(string name = "err_injector_3");
            super.new(name);
        endfunction : new

        task gen_err(ref logic [DW-1 : 0] in_arr []);
            do begin
                randomize(bit_pos_in_arr)     with { bit_pos_in_arr inside {[0 : DW*arr_size-1]} ; };
                word_pos_v = bit_pos_in_arr / DW;
                bit_pos_v  = bit_pos_in_arr - word_pos_v * DW;
                iter_n++;
            end while(in_arr[word_pos_v][bit_pos_v]);
            in_arr[word_pos_v][bit_pos_v] = '1;
        endtask : gen_err

    endclass : err_injector_3

endpackage : err_inj_pkg

`endif // ERR_INJ_PKG__SVH
