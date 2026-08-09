`timescale 1ns / 1ps


// Instruction Decoder Module
module InstructionDecoder(
    input logic [3:0] current_ir,  // Current instruction from IR
    output logic [1:0] ir_select    // Selection signal based on the instruction
    
);
    // Define supported instructions
    localparam [3:0] LOAD_PROGRAM  = 4'b0001;  // Load program data
    localparam [3:0] SCAN_TEST     = 4'b0010;  // Scan test operation
    localparam [3:0] BYPASS        = 4'b1111;  // Bypass mode

    always_comb begin
        ir_select = 2'b00;  // Default select value
     
        case (current_ir)
            LOAD_PROGRAM: {ir_select} = {2'b01};  // Load Program
            SCAN_TEST:    {ir_select} = {2'b10};  // Scan Test
            BYPASS:       {ir_select} = {2'b11};  // Bypass
            default:      {ir_select} = {2'b00};  // Default case for unsupported instructions
        endcase
    end
endmodule




