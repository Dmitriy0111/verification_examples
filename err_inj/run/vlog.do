transcript on

set i0 +incdir+../src/

set s0 ../src/test_param_pkg.svh
set s1 ../src/err_inj_pkg.svh
set s2 ../src/test_pkg.svh
set s3 ../src/test.sv

vlog -sv $i0 $s0 $s1 $s2 $s3

quit