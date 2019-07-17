/*
*  File            :   ahb_if.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.07.15
*  Language        :   SystemVerilog
*  Description     :   This is ahb interface
*  Copyright(c)    :   2019 Vlasov D.V.
*/

interface ahb_if #(parameter if_n = 1);

    // Interface signals
    // clock and reset
    logic               [0  : 0]    hclk;       // hclock
    logic               [0  : 0]    hresetn;    // hresetn
    // ahb signals
    logic   [if_n-1 : 0][31 : 0]    haddr;      // AHB HADDR
    logic   [if_n-1 : 0][31 : 0]    hwdata;     // AHB HWDATA
    logic   [if_n-1 : 0][31 : 0]    hrdata;     // AHB HRDATA
    logic   [if_n-1 : 0][0  : 0]    hwrite;     // AHB HWRITE
    logic   [if_n-1 : 0][1  : 0]    htrans;     // AHB HTRANS
    logic   [if_n-1 : 0][2  : 0]    hsize;      // AHB HSIZE
    logic   [if_n-1 : 0][2  : 0]    hburst;     // AHB HBURST
    logic   [if_n-1 : 0][1  : 0]    hresp;      // AHB HRESP
    logic   [if_n-1 : 0][0  : 0]    hready;     // AHB HREADYOUT
    logic   [if_n-1 : 0][0  : 0]    hsel;       // AHB HSEL

    // Properties
    property haddr_unk_prop;    @(posedge hclk) disable iff( !hresetn ) ! $isunknown( haddr     );  endproperty : haddr_unk_prop
    property hwdata_unk_prop;   @(posedge hclk) disable iff( !hresetn ) ! $isunknown( hwdata    );  endproperty : hwdata_unk_prop
    property hrdata_unk_prop;   @(posedge hclk) disable iff( !hresetn ) ! $isunknown( hrdata    );  endproperty : hrdata_unk_prop
    property hwrite_unk_prop;   @(posedge hclk) disable iff( !hresetn ) ! $isunknown( hwrite    );  endproperty : hwrite_unk_prop
    property htrans_unk_prop;   @(posedge hclk) disable iff( !hresetn ) ! $isunknown( htrans    );  endproperty : htrans_unk_prop
    property hsize_unk_prop;    @(posedge hclk) disable iff( !hresetn ) ! $isunknown( hsize     );  endproperty : hsize_unk_prop
    property hburst_unk_prop;   @(posedge hclk) disable iff( !hresetn ) ! $isunknown( hburst    );  endproperty : hburst_unk_prop
    property hresp_unk_prop;    @(posedge hclk) disable iff( !hresetn ) ! $isunknown( hresp     );  endproperty : hresp_unk_prop
    property hready_unk_prop;   @(posedge hclk) disable iff( !hresetn ) ! $isunknown( hready    );  endproperty : hready_unk_prop
    property hsel_unk_prop;     @(posedge hclk) disable iff( !hresetn ) ! $isunknown( hsel      );  endproperty : hsel_unk_prop
    //Assertions
    haddr_unk   : assert property( haddr_unk_prop   ) else $error( "Assert! haddr is unknown!"  );
    hwdata_unk  : assert property( hwdata_unk_prop  ) else $error( "Assert! hwdata is unknown!" );
    hrdata_unk  : assert property( hrdata_unk_prop  ) else $error( "Assert! hrdata is unknown!" );
    hwrite_unk  : assert property( hwrite_unk_prop  ) else $error( "Assert! hwrite is unknown!" );
    htrans_unk  : assert property( htrans_unk_prop  ) else $error( "Assert! htrans is unknown!" );
    hsize_unk   : assert property( hsize_unk_prop   ) else $error( "Assert! hsize is unknown!"  );
    hburst_unk  : assert property( hburst_unk_prop  ) else $error( "Assert! hburst is unknown!" );
    hresp_unk   : assert property( hresp_unk_prop   ) else $error( "Assert! hresp is unknown!"  );
    hready_unk  : assert property( hready_unk_prop  ) else $error( "Assert! hready is unknown!" );
    hsel_unk    : assert property( hsel_unk_prop    ) else $error( "Assert! hsel is unknown!"   );

endinterface : ahb_if
