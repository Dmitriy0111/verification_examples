
`include "uvm_macros.svh" 
import uvm_pkg::*;
import test_pkg::*;

module test;

    initial begin
        run_test("base_test");
    end

endmodule : test
