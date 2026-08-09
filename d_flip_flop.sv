`timescale 1ns / 1ps


module D_FlipFlop (
    input  logic tck_i,         // Clock input from TAP
    input  logic mux2_tdo,           // Data input (mux2_tdo)
    output logic ff_tdo            // Data output
);
   

    // Flip-flop functionality
    always_ff @(posedge tck_i) begin
        
        ff_tdo <= mux2_tdo;  // On clock edge, update q with the value of d
    end

endmodule
