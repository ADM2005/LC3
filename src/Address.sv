module Address(
    input logic [15:0] baseReg,
    input logic [8:0] offset,
    input logic [15:0] nPC,

    input logic aOp,

    output logic [15:0] aOut
);

logic [15:0] sXOffset;
assign sXOffset = {{7{offset[8]}}, offset};
assign aOut = aOp ? baseReg + sXOffset : nPC + sXOffset;

endmodule
