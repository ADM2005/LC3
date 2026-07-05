module MemoryIF(
    input logic [15:0] eDIN,
    input logic [15:0] sr,
    input logic [15:0] addr,

    input logic [2:0] mOp,

    output logic [15:0] eDOUT,
    output logic iBR,
    output logic [15:0] iADDR,
    output logic iWEA
);

logic [1:0] memOperation;

assign memOperation = mOp[1:0];

always_comb begin
     case(memOperation)
        2'b00: begin
            // READ DIRECT
            eDOUT = 16'hzzzz;
            iBR = 1;
            iADDR = addr;
            iWEA = 0;
        end
        2'b01: begin
            // READ INDIRECT
            eDOUT = 16'hzzzz;
            iBR = 1;
            iADDR = eDIN;
            iWEA = 0;
        end
        2'b10: begin
            // WRITE 
            eDOUT = sr;
            iBR = 1;
            iADDR = addr;
            iWEA = 1;
        end
        2'b11: begin
            // WRITE INDIRECT
            eDOUT = sr;
            iBR = 1;
            iADDR = eDIN;
            iWEA = 1;
        end
        default: begin
            eDOUT = 16'hzzzz;
            iBR = 0;
            iADDR = 16'hxxxx;
            iWEA = 0;
        end
    endcase
end

endmodule
