module Fetch(
    input logic en,

    input logic [15:0] pc,

    output logic iBR,
    output logic [15:0] iADDR,
    output logic iWEA
);

assign iADDR = en ? pc : 16'hxxxx;
assign iWEA = en ? 0 : 1'bx;
assign iBR = en;

endmodule
