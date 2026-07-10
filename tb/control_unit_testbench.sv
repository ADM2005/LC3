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

// Testbench

State State(
    .cCtrl(cCtrl),
    .eREADY(eREADY),
    .clk(clk),
    .reset(reset),
    .dEn(decodeEn)
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
eDIN = 16'h0000;
psr = 3'b000;

reset = 1;
#1 reset = 0;


// === ADD IMMEDIATE ===
eREADY = 1;
eDIN = 16'h1021;
repeat (2) @(negedge clk);    
while (State.state != FETCH) @(posedge clk);

// === ADD REGISTER ===
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'h12_00;
repeat (2) @(negedge clk);
while (State.state != FETCH) @(posedge clk);

// === AND IMMEDIATE ===
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'h54_6f;
repeat (2) @(negedge clk);
while (State.state != FETCH) @(posedge clk);

// === AND REGISTER ===
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'h56_81;
repeat (2) @(negedge clk);
while (State.state != FETCH) @(posedge clk);

// === NOT ===
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'h98_FF;
repeat (2) @(negedge clk);
while (State.state != FETCH) @(posedge clk);

// === LOAD ===
eREADY = 0;
repeat($urandom % 10+ 5) @(negedge clk);
eREADY = 1;
eDIN = 16'h2B_FA;
while (State.state != READ_MEMORY) @(posedge clk);
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'hBE_EF;
while (State.state != FETCH) @(posedge clk);
// === LOAD REGISTER ===
eREADY = 0;
repeat($urandom % 10+ 5) @(negedge clk);
eREADY = 1;
eDIN = 16'h6A_00;
while (State.state != READ_MEMORY) @(posedge clk);
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'hBE_EF;
while (State.state != FETCH) @(posedge clk);
// === LOAD INDIRECT ===
eREADY = 0;
repeat($urandom % 10+ 5) @(negedge clk);
eREADY = 1;
eDIN = 16'hAB_F7;
while (State.state != IND_MEMORY) @(posedge clk);
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'hDE_AD;
while (State.state != READ_MEMORY) @(posedge clk);
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'hBE_EF;
while (State.state != FETCH) @(posedge clk);
// === LOAD EFFECTIVE ===
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'hED_F6;
while (State.state != FETCH) @(posedge clk);
// === STORE ===
eREADY = 0;
repeat($urandom % 10+ 5) @(negedge clk);
eREADY = 1;
eDIN = 16'h33_F5;
while (State.state != WRITE_MEMORY) @(posedge clk);
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
while (State.state != FETCH) @(posedge clk);
// === STORE REGISTER ===
eREADY = 0;
repeat($urandom % 10+ 5) @(negedge clk);
eREADY = 1;
eDIN = 16'h72_40;
while (State.state != WRITE_MEMORY) @(posedge clk);
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
while (State.state != FETCH) @(posedge clk);
// === STORE INDIRECT ===
eREADY = 0;
repeat($urandom % 10+ 5) @(negedge clk);
eREADY = 1;
eDIN = 16'hB5_F3;
while (State.state != IND_MEMORY) @(posedge clk);
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'hDE_AD;
while (State.state != WRITE_MEMORY) @(posedge clk);
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
while (State.state != FETCH) @(posedge clk);
// === BRANCH FAIL ===
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'h09_F2;
repeat (2) @(negedge clk);
while (State.state != FETCH) @(posedge clk);
// === BRANCH SUCCESS ===
psr[2] = 1; 
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'h09_F2;
repeat (2) @(negedge clk);
while (State.state != FETCH) @(posedge clk);
// === JUMP ===
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'hC0_80;
repeat (2) @(negedge clk);
while (State.state != FETCH) @(posedge clk);
// === HALT ===
eREADY = 0;
repeat($urandom % 10 + 5) @(negedge clk);
eREADY = 1;
eDIN = 16'hF0_25;
repeat (2) @(negedge clk);
$stop;
end

initial begin
repeat(1000) @(posedge clk);
$stop;
end

endmodule