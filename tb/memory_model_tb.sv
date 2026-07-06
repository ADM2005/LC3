`timescale 1us/1ns

module Memory_Model_Testbench;

logic clk;
logic reset;

logic [15:0] eADDR;
logic eWEA;
logic [15:0] eDOUT;

logic [15:0] eDIN;
logic eREADY;

MemoryModel memoryModel(
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
clk = 0;
eADDR = 16'hzzzz;
eWEA = 1'bz;
eDOUT = 16'hzzzz;

reset = 1;
#10 reset = 0;

// Write
eADDR = 16'h0000;
eWEA = 1'b1;
eDOUT = 16'hBEEF;

@(negedge clk);
eWEA = 1'bz;
while(!eREADY) @(negedge clk);
// Read
eADDR = 16'h0000;
eWEA = 1'b0;

@(negedge clk);
eWEA = 1'bz;
while(!eREADY) @(negedge clk);
repeat (5) @(negedge clk);
$stop;
end

endmodule
