module Registers (
    input logic clk,
    input logic reset,
    input logic en,

    input logic [2:0] sr1ID,
    input logic [2:0] sr2ID,
    input logic [2:0] drID,
    input logic [15:0] dr,

    output logic [2:0] psr,
    output logic [15:0] sr1,
    output logic [15:0] sr2
);

logic [7:0][15:0] registerBank;

assign  sr1 = registerBank[sr1ID];
assign  sr2 = registerBank[sr2ID];

always_ff @(negedge clk, posedge reset)
begin
    integer i;
    if(reset) for(i=0; i < 8; i++) registerBank[i] <= 0;
    else begin
        if (en) begin
            registerBank[drID] <= dr;
            psr[2] <= (dr < 0) ?  1 : 0;
            psr[1] <= (dr == 0) ?  1 : 0; 
            psr[0] <= (dr > 0) ?  1 : 0; 
        end
    end 
end

endmodule
