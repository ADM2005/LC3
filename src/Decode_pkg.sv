package Decode_pkg;

typedef enum logic[3:0]
{
    // ALU opcodes
    OP_ADD = 4'b0001,
    OP_AND = 4'b0101,
    OP_NOT = 4'b1001,

    // Memory opcodes
    OP_LD = 4'b0010,
    OP_LDR = 4'b0110,
    OP_LDI = 4'b1010,
    OP_LEA = 4'b1110,
    OP_ST = 4'b0011,
    OP_STR = 4'b0111,
    OP_STI = 4'b1011,

    // Control opcodes
    OP_BR = 4'b0000,
    OP_JMP = 4'b1100,
    OP_HALT = 4'b1111
} INSTR_OPCODE;

typedef enum logic [1:0]
{
    ALU_OUT = 2'b00,
    ADDR_OUT = 2'b01,
    MEMORY_INPUT = 2'b10
} drmux_select_t;

typedef enum logic [2:0]
{
    ALU_ADD = 3'b000,
    ALU_ADD_IMM = 3'b001,
    ALU_AND = 3'b010,
    ALU_AND_IMM = 3'b011,
    ALU_NOT = 3'b100
} uOp_t;

endpackage : Decode_pkg
