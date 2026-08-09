
`timescale 1ns/1ps

module jtag_instruction_register #(
    //parameter IR_LENGTH = 4
) (
    input  logic                 tck_i,        // JTAG test clock
    input  logic                 trst_n_i,     // JTAG reset (active low)
    input  logic                 shift_ir,   // From TAP controller: shift IR state
    input  logic                 capture_ir, // From TAP controller: capture IR state
    input  logic                 update_ir,  // From TAP controller: update IR state
    input  logic                 tdi_i,        // Test Data In
    output logic                 ir_tdo,     // Test Data Out (IR serial out) to mux2
    output logic [3:0] current_ir  // Latched current instruction
);

    // Define supported JTAG instructions (4-bit IR)
    localparam [3:0] LOAD_PROGRAM  = 4'b0001;
    localparam [3:0] SCAN_TEST     = 4'b0010;
    localparam [3:0] BYPASS        = 4'b1111;

    // Pattern captured during Capture-IR
    localparam [3:0] CAPTURE_PATTERN = 4'b0101;

    // IR shift register
    logic [3:0] ir_shift_reg;

    // Temporary register to hold TDO before shifting
    logic tdo_reg;
    
    

    // Combined Reset and Clocked Sequential Logic
    always_ff @(posedge tck_i or negedge trst_n_i) begin
        if (!trst_n_i) begin
            // Reset Logic
            ir_shift_reg <= BYPASS;
            current_ir <= BYPASS;
            tdo_reg <= BYPASS[0];
        end else begin
            // Clocked Logic
            if (capture_ir) begin
                ir_shift_reg <= CAPTURE_PATTERN;
             //   $display("[DEBUG] Capture-IR: IR set to CAPTURE_PATTERN (4'b0101)");
            end else if (shift_ir) begin
                ir_shift_reg <= {tdi_i, ir_shift_reg[3:1]};
             //   $display("[DEBUG] During Shift-IR: ir_shift_reg = %b, tdi = %b", ir_shift_reg, tdi);
            end

            if (update_ir) begin
                current_ir <= ir_shift_reg;
               // $display("[DEBUG] Update-IR: current_ir updated to %b", current_ir);
            end

            tdo_reg <= ir_shift_reg[0]; // Update TDO
        end
    end



    // Assign TDO from the temporary register
    assign ir_tdo = tdo_reg;

endmodule
