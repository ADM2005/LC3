module MemoryModel(
    input logic clk,
    input logic reset,

    input wire [15:0] eADDR,
    input wire eWEA,
    input wire [15:0] eDOUT,

    output logic [15:0] eDIN,
    output logic eREADY
);

logic [15:0] mem [65535];
logic [3:0] readyCounter;

logic busy;
logic reading;
logic writing;

always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        busy <= 0;
        readyCounter <= 0;
        reading <= 0;
        writing <= 0;
    end else begin
        if (busy) begin
            if (readyCounter == 0) begin
                busy <= 0;
                reading <= 0;
                writing <= 0;
                if(writing) mem[eADDR] <= eDOUT;
            end else begin 
                readyCounter <= readyCounter - 1;
            end
        end else begin 
            if(eWEA === 1'b0 || eWEA === 1'b1) begin
                reading <= (eWEA === 1'b0) ? 1'b1 : 1'b0;
                writing <= (eWEA === 1'b1) ? 1'b1 : 1'b0;
                readyCounter <= $urandom % 10;
                busy <= 1;
            end
        end
    end
end

always_comb begin
    if(busy || reading) begin
        eDIN = 16'hxxxx;
        eREADY = 0;
    end else begin 
        eDIN = mem[eADDR];
        eREADY = 1;
    end
end



endmodule