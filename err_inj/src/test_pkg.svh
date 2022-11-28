`ifndef TEST_PKG__SVH
`define TEST_PKG__SVH

package test_pkg;
    `include "uvm_macros.svh" 
    import uvm_pkg::*;

    import test_param_pkg::*;
    import err_inj_pkg::*;

    class env_cls extends uvm_env;
        `uvm_component_utils(env_cls)

        base_err_injector           err_inj;
        logic   [DW-1 : 0]          mask_err [];
        int                         err_num = 200;
        int                         ArrLen = 63;

        int                         WordPos;
        int                         BitPos;

        real                        ErrAverage;
        real                        ErrRMS;

        int                         HistErr [][];

        string                      HistErrFN = "HistErrFD";
        integer                     HistErrFD;

        int                         RepCnt = 200;

        function new(string name = "env_cls", uvm_component parent = null);
            super.new(name, parent);
        endfunction : new

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            err_inj = base_err_injector::type_id::create("err_inj", this);

            $value$plusargs("REP_CNT=%d", RepCnt);
            $value$plusargs("ERR_NUM=%d", err_num);

            HistErrFD = $fopen( $sformatf("%s_%0d_%0d.log", HistErrFN, RepCnt, err_num), "w");
        endfunction : build_phase

        virtual task run_phase(uvm_phase phase);
            mask_err = new[ArrLen];

            HistErr = new[ArrLen];
            foreach(HistErr[ii])
                HistErr[ii] = new[DW];

            for(int rep=0; rep < RepCnt; rep++) begin
                err_inj.inject_errors(err_num, mask_err);

                for(WordPos = 0; WordPos < ArrLen; WordPos++) begin
                    for(BitPos = 0; BitPos < DW; BitPos++) begin
                        if(mask_err[WordPos][BitPos])
                            HistErr[WordPos][BitPos]++;
                    end
                end

                `uvm_info("INFO", $sformatf("%d", rep), UVM_HIGH)
            end

            foreach(HistErr[ii,jj]) begin
                ErrAverage += $itor(HistErr[ii][jj]);
            end
            ErrAverage = ErrAverage / $itor(DW*ArrLen);
            `uvm_info("INFO", $sformatf("ErrAverage = %f", ErrAverage), UVM_LOW)

            begin
                real SquareVal;
                foreach(HistErr[ii,jj]) begin
                    SquareVal = ($itor(HistErr[ii][jj]) - ErrAverage)**2;
                    SquareVal = $pow(SquareVal, 0.5);
                    ErrRMS += SquareVal;
                end
            end
            `uvm_info("INFO", $sformatf("ErrRMS = %f", ErrRMS), UVM_HIGH)
            ErrRMS = ErrRMS / $pow($itor(RepCnt*err_num), 0.5);
            `uvm_info("INFO", $sformatf("ErrRMS = %f", ErrRMS), UVM_LOW)

            foreach(HistErr[ii,jj]) begin
                $fwrite(HistErrFD, "| WordPos | %4d | BitPos | %4d | Hits | %d\n", ii, jj, HistErr[ii][jj]);
            end

            $fclose(HistErrFD);
        endtask : run_phase

    endclass : env_cls

    class base_test extends uvm_test;
        `uvm_component_utils(base_test)

        env_cls     env;
        string      err_inj_type = "base_err_injector";

        uvm_object_wrapper err_inj_wraps[string] = '{
            "base_err_injector" :base_err_injector::get_type(),
            "err_injector_0"    :err_injector_0::get_type(),
            "err_injector_1"    :err_injector_1::get_type(),
            "err_injector_2"    :err_injector_2::get_type(),
            "err_injector_3"    :err_injector_3::get_type()
        };

        function new(string name = "base_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction : new

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!$value$plusargs("ERR_INJ_TYPE=%s", err_inj_type))
                `uvm_fatal("FATAL", "ERR_INJ_TYPE is not set")

            env = env_cls::type_id::create("env", this);

            env.HistErrFN = { env.HistErrFN , err_inj_type };

            set_inst_override_by_type("env.err_inj", err_inj_wraps["base_err_injector"], err_inj_wraps[err_inj_type]);

            factory.print();
        endfunction : build_phase

    endclass : base_test

endpackage : test_pkg

`endif // TEST_PKG__SVH
