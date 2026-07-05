import State_pkg::*;
import Decode_pkg::*;

module Decode(
    input logic [15:0] eDIN,        // Data Input from external memory interface, the next instruction
    input logic en,                 // Enable Signal
    input logic clk,                // Clock
    input logic reset,              // Reset
    input logic [2:0] psr,

    // Control Unit Outputs
    output logic pNext,             // Change pc to tPC rather than incrementing
    output logic aOp,               // 0: pc + 9bit offset, 1: src1 + 6bit offset
    output drmux_select_t drSrc,       // Destination Register Multiplexor Selector
    output uOp_t uOp,         // Selects operation for ALU
    output cCtrl_t cCtrl,       // Instruction type encoding for state machine

    // Dataflow Outputs
    output logic [2:0] sr1ID,       // Register IDs
    output logic [2:0] sr2ID,
    output logic [2:0] drID,

    output logic [4:0] imm,         // Immediate Value
    output logic [8:0] offset       // Address Offset
);

logic [15:0] ir;

// LOCAL VARIABLES
iType_t [1:0] INSTR_TYPE;
maType_t [1:0] MA_TYPE;
indType_t IND_TYPE;

logic[3:0] opcode;

assign opcode = ir[15:12];

assign cCtrl.iType = INSTR_TYPE;
assign cCtrl.maType = MA_TYPE;
assign cCtrl.indType = IND_TYPE;

always_ff @(posedge clk, posedge reset)
begin
    if(reset)
        ir <= 0;
    else
        if(en) ir <= eDIN;
end

always_comb begin
    INSTR_TYPE = INSTR_INVALID;
    MA_TYPE = MEM_READ;
    IND_TYPE = IND_READ;

    pNext = 0;
    aOp = 0;
    drSrc = ALU_OUT;
    uOp = ALU_ADD;
    sr1ID = 0;
    sr2ID = 0;
    drID = 0;
    imm = 0;
    offset = 0;

    case(opcode)
        OP_ADD: begin
            INSTR_TYPE = INSTR_ALU;
            drSrc = ALU_OUT;
            uOp = ir[5] ? ALU_ADD_IMM : ALU_ADD;
            sr1ID = ir[8:6];
            if(ir[5]) imm = ir[4:0];
            else sr2ID = ir[2:0];
            drID = ir[11:9];
        end
        OP_AND: begin
            INSTR_TYPE = INSTR_ALU;
            drSrc = ALU_OUT;
            uOp = ir[5] ? ALU_AND_IMM : ALU_AND;
            sr1ID = ir[8:6];
            if(ir[5]) imm = ir[4:0];
            else sr2ID = ir[2:0];
            drID = ir[11:9];
        end
        OP_NOT: begin
            INSTR_TYPE = INSTR_ALU;
            drSrc = ALU_OUT;
            uOp = ALU_NOT;
            sr1ID = ir[8:6];
            drID = ir[11:9];
        end
        OP_LD: begin
            INSTR_TYPE = INSTR_MEMORY;
            MA_TYPE = MEM_READ;
            aOp = 0;
            drSrc = MEMORY_INPUT;
            drID = ir[11:9];
            offset = ir[8:0];
        end
        OP_LDR: begin
            INSTR_TYPE = INSTR_MEMORY;
            MA_TYPE = MEM_READ;
            aOp = 1;
            drSrc = MEMORY_INPUT;
            sr1ID = ir[8:6];
            drID = ir[11:9];
            offset = {{3{ir[5]}}, ir[5:0]};
        end
        OP_LDI: begin
            INSTR_TYPE = INSTR_MEMORY;
            MA_TYPE = MEM_IND;
            IND_TYPE = IND_READ;
            aOp = 0;
            drSrc = MEMORY_INPUT;
            drID = ir[11:9];
            offset = ir[8:0];
        end
        OP_LEA: begin
            INSTR_TYPE = INSTR_MEMORY;
            MA_TYPE = MEM_WRITE_REG;
            aOp = 0;
            drSrc = ADDR_OUT;
            drID = ir[11:9];
            offset = ir[8:0];
        end
        OP_ST: begin
            INSTR_TYPE = INSTR_MEMORY;
            MA_TYPE = MEM_WRITE;
            aOp = 0;
            sr1ID = ir[11:9];
            offset = ir[8:0];
        end
        OP_STR: begin
            INSTR_TYPE = INSTR_MEMORY;
            MA_TYPE = MEM_WRITE;
            aOp = 1;
            sr1ID = ir[8:6];
            sr2ID = ir[11:9];
            offset = {{3{ir[5]}}, ir[5:0]};
        end
        OP_STI: begin
            INSTR_TYPE = INSTR_MEMORY;
            MA_TYPE = MEM_IND;
            IND_TYPE = IND_WRITE;
            aOp = 0;
            sr1ID = ir[11:9];
            offset = ir[8:0];
        end
        OP_BR: begin
            INSTR_TYPE = INSTR_CONTROL;
            pNext = (~ir[11] | psr[2]) | (~ir[10] | psr[1]) | (~ir[9] | psr[0]);    // Boolean to test branch cond
            aOp = 0;
            offset = ir[8:0];
        end
        OP_JMP: begin
            INSTR_TYPE = INSTR_CONTROL;
            pNext = 1;
            aOp = 1;
            sr1ID = ir[8:6];
            offset = ir[8:0];
        end
    endcase
end

endmodule