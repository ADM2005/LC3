`include "../src/State.sv"
`include "../src/Decode.sv"
`timescale 1us/1ns

import State_pkg::*;
import Decode_pkg::*;

module Control_Unit_Testbench;

logic clk;
logic reset;

// State Unique Signals
logic eREADY;

// Decode Unique Signals
logic [15:0] eDIN;
logic [2:0] psr;

// Shared Signals
logic decodeEn;
cCtrl_t cCtrl;

State State(
    .cCtrl(cCtrl),
    .eREADY(eREADY),
    .clk(clk),
    .reset(reset)
);

Decode Decode(
    .eDIN(eDIN),
    .en(decodeEn),
    .clk(clk),
    .reset(reset),
    .psr(psr),
    .cCtrl(cCtrl)
);

always #20 clk = !clk;

initial begin 
clk = 0;
reset = 0;
eREADY = 0;
eDIN = 16'h0000
psr = 3'b000
end

endmodule