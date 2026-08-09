`timescale 1ns / 1ps

module Output_mux_2 (
    input  logic mux1_tdo,   // Input 1: TDO from Mux1
    input  logic ir_tdo,     // Input 2: TDO from IR
    input  logic select,     // Select signal
    output logic mux2_tdo    // Output: Selected TDO
);

  //  logic [95:0] tdo_o;
    // Combinational logic for multiplexer
    always_comb begin
        if (select) begin
            mux2_tdo = ir_tdo;  // Select IR TDO if select=1
        end else begin
            mux2_tdo = mux1_tdo; // Select Mux1 TDO if select=0
         
        end
    end

endmodule



