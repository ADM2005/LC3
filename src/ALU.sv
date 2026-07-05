import Decode_pkg::*;

module ALU(
    input logic [15:0] sr1,
    input logic [15:0] sr2,
    input logic [4:0] imm,

    input uOp_t uOp,

    output logic [15:0] uOut
);

logic [15:0] sXImm; 

assign sXImm = {{11{imm[4]}}, imm};

always_comb begin
    case(uOp)
        ALU_ADD: uOut = sr1 + sr2;
        ALU_ADD_IMM: uOut = sr1 + sXImm;
        ALU_AND: uOut = sr1 & sr2;
        ALU_AND_IMM: uOut = sr1 & sXImm;
        ALU_NOT: uOut = ~sr1;
    endcase
end

endmodule
