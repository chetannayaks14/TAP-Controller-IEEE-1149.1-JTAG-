`timescale 1ns / 1ps


// Bypass Register Module with Input MUX Enable Signal
module bypass_register (
    input  logic tck_i,            // Test Clock
    input  logic tdi_to_bypass,            // Test Data In
  
    output logic tdo_bypass             // Test Data Out
);

    // Internal 1-bit bypass register
    logic bypass_bit;

  
    
   always_ff @(posedge tck_i) begin
    bypass_bit <= tdi_to_bypass;        // Sequentially capture TDI into bypass_bit
end

assign tdo_bypass = bypass_bit; 

endmodule

