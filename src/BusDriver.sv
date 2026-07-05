module BusDriver(
    input logic iBR0,
    input logic [15:0] iADDR0,
    input logic iWEA0,

    input logic iBR1,
    input logic [15:0] iADDR1,
    input logic iWEA1,

    output tri [15:0] eADDR,
    output tri eWEA
);

assign eADDR = iBR0 ? iADDR0 : (iBR1 ? iADDR1 : 16'hzzzz);
assign eWEA = iBR0 ? iWEA0 : (iBR1 ? iWEA1 : 1'bz);

endmodule