import Decode_pkg::*;

module DrMux (
    input logic [15:0] uOut,
    input logic [15:0] aOut,
    input logic [15:0] eDIN,
    input drmux_select_t sel,

    output logic [15:0] dr
);

always_comb begin
    unique case (sel)
        ALU_OUT: dr = uOut;
        ADDR_OUT: dr = aOut;
        MEMORY_INPUT: dr = eDIN;
        default: dr = uOut;    
    endcase
end

endmodule


