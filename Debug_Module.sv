
/*


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.12.2024
// Design Name: 
// Module Name: DebugModule
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Debug Module for JTAG
// Handles LOAD_PROGRAM and SCAN_TEST operations
// Interfaces with external instruction memory
// 
// Dependencies: 
// Requires ShiftDataRegister and Instruction Memory modules
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.12.2024
// Design Name: 
// Module Name: ScanTestRegister
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Scan Test Register for JTAG
// Implements loading address and reading data from instruction memory
// Based on instruction decoder with ir_enable = 2'b10
// 
// Dependencies: 
// Requires connection to external instruction memory
// 
// Revision:
// Revision 0.02 - Updated with instruction decoder logic
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////

module Scan_Test_Register (
    input logic        tck,              // TAP clock for scan operations
    input logic        tdi_to_scan,      // Test data input specific to scan test
  //  input logic [1:0]  ir_enable,        // Instruction decoder enable
   // output logic       memory_out,              // Test data output
    input logic        shift_dr,     // Enable shifting through the scan register
    input logic        capture_dr,   // Enable capture of scan data
    input logic        update_dr,    // Enable update of scan data
    output logic [63:0] loadAddr,        // Address to read from instruction memory
    output logic        wren            // Write enable signal

);

    // Internal scan register
    logic [64:0] scan_reg; // 64 bits for loadAddr + 1 bit for wren

    // Scan Register Logic
    always_ff @(posedge tck) begin
     //   if (ir_enable == 2'b10) begin
            if (capture_dr) begin
                // Capture default values (e.g., reset state)
                scan_reg <= 65'b0;
            end else if (shift_dr) begin
                // Shift TDI into MSB and shift right
                scan_reg <= {tdi_to_scan, scan_reg[64:1]};
               $display("[DEBUG Module] shift DR; DR set to %b",scan_reg);
            end else if (update_dr) begin
                // Update loadAddr and wren
                loadAddr[63:0] = scan_reg[63:0]; // Lower 64 bits for loadAddr
           //     wren = 0;       // MSB for wren
                $display("[DEBUG Module]  DR set to %b",scan_reg[64]);
                $display("[DEBUG Module]  scan_reg to %b",scan_reg);
                $display("[DEBUG Module]  load address to %b",loadAddr);
            end
      //  end
    end

 ////   // Assign TDO (output LSB of the scan register)
    //assign memory_out = instr;

endmodule


*/
