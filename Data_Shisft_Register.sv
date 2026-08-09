

`timescale 1ns / 1ps

module Shift_Data_Register #(
    parameter DR_LENGTH = 41 // Data Register length (1-bit wren, 8-bit addr, 32-bit data)
) (
    input logic tdi_to_load,              // Serial input data
    input logic tck_i,                   // JTAG test clock
    input logic trst_n_i,                // JTAG reset (active low)
    input logic shift_dr,                // Shift DR state
    input logic capture_dr,              // Capture DR state
    input logic update_dr,               // Update DR state
    output logic shift_dr_tdo,           // Test Data Out (serial output)
    output logic [7:0] loadAddr_i,       // 8-bit address for instruction memory
    output logic [31:0] loadData_i,      // 32-bit data for instruction memory
    output logic wren_i                  // Write enable for instruction memory
);

    // Data shift register
    logic [DR_LENGTH-1:0] dr_shift_reg;

    // Temporary register to hold TDO before shifting
    logic tdo_reg;

    // Synchronous logic for DR shifting and capturing
    always_ff @(posedge tck_i or negedge trst_n_i) begin
        if (!trst_n_i) begin
            // On reset, clear the shift register and outputs
            dr_shift_reg <= {41{1'b0}}; // Explicit width initialization
            wren_i <= 1'b0;
            loadAddr_i <= 8'b0;
            loadData_i <= 32'b0;
            tdo_reg <= 1'b0;
        end else begin
            // Capture TDO before shifting
            tdo_reg <= dr_shift_reg[0];
            
            

            if (capture_dr) begin
                // Capture default values into the shift register
                dr_shift_reg <= {41{1'b0}}; // Replace with specific values if needed
            end else if (shift_dr) begin
                // Shift operation: input TDI into MSB, shift right, output TDO as LSB
                dr_shift_reg <= {tdi_to_load, dr_shift_reg[DR_LENGTH-1:1]};
                 assign shift_dr_tdo = tdo_reg;
               
            end

            if (update_dr) begin
                // Update outputs from the shift register
                wren_i <= dr_shift_reg[0];                  // 1-bit write enable
                loadData_i <= dr_shift_reg[32:1];          // 32-bit load data
                loadAddr_i <= dr_shift_reg[40:33];         // 8-bit load address
                
               
                
            end
        end
    end

    // Assign TDO from the temporary register
    assign shift_dr_tdo = tdo_reg;
   
endmodule



