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
logic [15:0] requestedAddress;

logic busy;
logic reading;
logic writing;

integer fd, status;
reg [15:0] memoryBlockCount;
reg [15:0] memoryStarts [1024];
reg [15:0] memorySizes [1024];

reg[15:0] holder;

task automatic init_memory(input string filename);


    fd = $fopen(filename, "rb");
    status = $fread(memoryBlockCount, fd);
    for(int i = 0; i < memoryBlockCount; i++) begin
        status = $fread(holder, fd);
        memoryStarts[i] = holder;
        status = $fread(holder, fd);
        memorySizes[i] = holder;
    end

    for(int i = 0; i < memoryBlockCount; i++) begin
        for(int j = 0; j < memorySizes[i]; j++) begin
            status = $fread(holder, fd);
            mem[j + memoryStarts[i]] = holder;
        end
    end

    $fclose(fd);
endtask

always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        busy <= 0;
        readyCounter <= 0;
        reading <= 0;
        writing <= 0;
        requestedAddress <= 16'hxxxx;
    end else begin
        if (busy) begin
            if (readyCounter == 0) begin
                busy <= 0;
                reading <= 0;
                writing <= 0;
                if(writing) mem[requestedAddress] <= eDOUT;
            end else begin 
                readyCounter <= readyCounter - 1;
            end
        end else begin 
            if(eWEA === 1'b0 || eWEA === 1'b1) begin
                reading <= (eWEA === 1'b0) ? 1'b1 : 1'b0;
                writing <= (eWEA === 1'b1) ? 1'b1 : 1'b0;
                requestedAddress <= eADDR;
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
        eDIN = mem[requestedAddress];
        eREADY = 1;
    end
end



endmodule