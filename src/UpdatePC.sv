module UpdatePC(
    input logic clk,
    input logic reset,
    input logic en,
    input logic sel,

    input logic [15:0] tPC,

    output logic [15:0] nPC,
    output logic [15:0] pc
);

assign nPC = pc + 1;

always_ff @(negedge clk, posedge reset) begin
    if(reset) pc <= 16'h0000;
    else if(en) pc <= sel ? tPC : nPC;
end

endmodule
