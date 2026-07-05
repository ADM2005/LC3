/*
    State module for the LC-3 CPU, part of the control unit. Determines
    the next state of the FSM as well as state dependent output control 
    signals.
*/

import State_pkg::*;

module State(
    input wire cCtrl_t cCtrl,               // The type of instruction sent by the Decode unit. (00 00 0) (iType maType indType).
    input logic eREADY,                     // Indicates whether external memory has completed operation. States involving memory must
                                            // wait for this to go high before transitioning.

    input logic clk,                        // The clock.
    input logic reset,                      // Reset signal.

    output logic pEn,                       // Enables the UpdatePC module to change the program counter.
    output logic fEn,                       // Enables the Fetch module to start a memory fetch.
    output logic dEn,                       // Enables the Decode module to read the instruction from the memory bus .
    output logic rWe,                       // Enables the Registers module to store dr into the register identified by drID.
    output logic [2:0] mOp                  // Indicates the type of memory operation (0 0 0) (Enable Read/Write Direct/Indirect).
);


output_t nextOut;                           // The next output, set combinatorially
 
PROCESSOR_STATE state;                      // The current state
PROCESSOR_STATE nextState;                  // The next state


// Block for determining next state
always_comb begin
    case(state)
    UPDATE_PC:
        nextState = FETCH;
    FETCH:
        nextState = eREADY ? DECODE : FETCH;
    DECODE:
        case(cCtrl.iType)
            INSTR_CONTROL: nextState = TARGET_PC;
            INSTR_ALU: nextState = ALU;
            INSTR_MEMORY: nextState = MEMORY_ADDR;
            default: nextState = ILLEGAL;
        endcase
    ALU:
        nextState = WRITE_REGISTER;
    TARGET_PC:
        nextState = UPDATE_PC;
    MEMORY_ADDR:
        unique case(cCtrl.maType)
            MEM_WRITE_REG: nextState = WRITE_REGISTER;
            MEM_READ: nextState = READ_MEMORY;
            MEM_IND: nextState = IND_MEMORY;
            MEM_WRITE: nextState = WRITE_MEMORY;
            default: nextState = ILLEGAL;
        endcase
    IND_MEMORY:
        if (!eREADY)
            nextState = IND_MEMORY;
        else
            nextState = (cCtrl.indType == IND_READ) ? READ_MEMORY : WRITE_MEMORY;
    READ_MEMORY:
        nextState = eREADY ? WRITE_REGISTER : READ_MEMORY;
    WRITE_MEMORY:
        nextState = eREADY ? UPDATE_PC : WRITE_MEMORY;
    WRITE_REGISTER:
        nextState = UPDATE_PC;

    default: nextState = ILLEGAL;
    endcase 
    
end

// Block for determining next outputs
always_comb begin
    nextOut.pEn = 0;
    nextOut.fEn = 0;
    nextOut.dEn = 0;
    nextOut.rWe = 0;
    nextOut.mOp = 0;

    case(nextState)
        UPDATE_PC:
            nextOut.pEn = 1;                      // Enable PC to be updated (either incremented or set depending on last decoded instruction)
        FETCH:
            nextOut.fEn = eREADY;                 // Enable Fetch module to initiate memory read for instruction fetch.
        DECODE:
            nextOut.dEn = eREADY;                 // Enable Decode module to read the bus.
        WRITE_REGISTER:
            nextOut.rWe = 1;                      // Enables Registers module to overwrite register

        /*
            MEMORY OUTPUTS.
            These are concerned with determinning the next value of mOp.
                Bit 2: Whether or not to actually do a memory operation
                Bit 1: Write or Read
                Bit 0: Indirect or direct.
        */
        IND_MEMORY:
            nextOut.mOp = {eREADY, cCtrl.indType, 1'b0};    
        READ_MEMORY:
            nextOut.mOp = {eREADY, 1'b0, cCtrl.maType == MEM_IND ? 1'b1 : 1'b0};
        WRITE_MEMORY:
            nextOut.mOp = {eREADY, 1'b1, cCtrl.maType == MEM_IND ? 1'b1 : 1'b0};
    endcase
end

always_ff @(negedge clk, posedge reset) begin
    if(reset)
    begin
        state <= UPDATE_PC;
        pEn <= 0;
        fEn <= 0;
        dEn <= 0;
        rWe <= 0;
        mOp <= 3'b000;
    end
    else
    begin
        state <= nextState;
        pEn <= nextOut.pEn;
        fEn <= nextOut.fEn;
        dEn <= nextOut.dEn;
        rWe <= nextOut.rWe;
        mOp <= nextOut.mOp;
    end
end

endmodule
