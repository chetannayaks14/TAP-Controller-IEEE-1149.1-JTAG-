`timescale 1ns / 1ps



// TDI Input Multiplexer
module TDIInputMux(
    input logic tdi_i,              // Test Data Input
    input logic [1:0] ir_select,     // Select signal from Instruction Decoder
    output logic tdi_to_bypass,   // Output to bypass logic

    output logic tdi_to_load      // Output to load program logic
);
    always_comb begin
        // Default all outputs to 0
        tdi_to_bypass = 0;
    
        tdi_to_load   = 0;

        // Route TDI based on select signal
        case (ir_select)
            2'b11: tdi_to_bypass = tdi_i;  // BYPASS instruction
            2'b10: tdi_to_load   = tdi_i;  // SCAN_TEST instruction
            2'b01: tdi_to_load   = tdi_i;  // LOAD_PROGRAM instruction
            default: ;                   // No operation for unsupported instructions
        endcase
    end
endmodule



