`timescale 1us/1ns

import State_pkg::*;

module LC3_Testbench;

logic clk;
logic reset;

logic [15:0] eADDR;
logic eWEA;
logic [15:0] eDOUT;

logic [15:0] eDIN;
logic eREADY;

LC3 lc3(
    .clk(clk),
    .reset(reset),
    .eDIN(eDIN),
    .eREADY(eREADY),

    .eDOUT(eDOUT),
    .eADDR(eADDR),
    .eWEA(eWEA)
);

MemoryModel memory(
    .clk(clk),
    .reset(reset),
    .eADDR(eADDR),
    .eWEA(eWEA),
    .eDOUT(eDOUT),
    .eDIN(eDIN),
    .eREADY(eREADY)
);

always #20 clk = !clk;

initial begin
memory.init_memory("a.out");
#10 $stop;
clk = 0;
reset = 1;
#10 reset =0;

while(lc3.state.state != ILLEGAL) @(negedge clk);
$stop;
end

initial begin
repeat(1000) @(negedge clk);
$stop;
end

endmodule