/*
*  File            :   ahb_dec.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.11
*  Language        :   SystemVerilog
*  Description     :   This is AHB decoder module
*  Copyright(c)    :   2019 Vlasov D.V.
*/

`include "../system_settings.svh"

module ahb_dec
#(
    parameter                           slave_c = SLAVE_COUNT
)(
    input   logic   [31        : 0]     haddr,  // AHB address
    output  logic   [slave_c-1 : 0]     hsel    // hsel signal
);

    genvar  gen_ahb_dec;
    generate
        for(gen_ahb_dec = 0 ; gen_ahb_dec < slave_c ; gen_ahb_dec++)
        begin : generate_hsel
            always_comb
            begin
                hsel[gen_ahb_dec] = '0;
                casex( haddr )
                    ahb_vector[gen_ahb_dec] : hsel[gen_ahb_dec] = '1;
                    default                 : ;
                endcase
            end 
        end
    endgenerate

endmodule : ahb_dec
