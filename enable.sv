`timescale 1ns / 1ps


module Enable_Out (
    input  logic ff_tdo,  // Input from D flip-flop
    input  logic enable,  // Enable signal from TAP controller
    output logic tdo_o      // Output after gating
);

// logic [96:0] tdo_o;

    // Enable gating logic
    always_comb begin
        if (enable) begin
            tdo_o = ff_tdo;  // Pass flip-flop output if enabled
        end else begin
            tdo_o = 1'bz;    // High-impedance state when not enabled
        end
    end
    
    

endmodule

