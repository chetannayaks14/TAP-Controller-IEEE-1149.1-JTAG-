`timescale 1ns / 1ps


module I_mem (
    // -------------------------------------------------------------
    // 1. Port Declarations
    // -------------------------------------------------------------
    input  logic [7:0] program_counter_i,  // PC from CPU domain
    output logic [31:0] instr_o, // Instruction output

    input  logic [7:0] loadAddr_i,         // Load address for JTAG writes
    input  logic [31:0] loadData_i,         // Data to write from JTAG
    input logic trst_n_i,    // JTAG reset (active low)
    input  logic        wren_i,             // Write enable (JTAG domain)
    input  logic        clk_i,              // CPU clock (for instruction fetch)
    input  logic        tck_i               // TAP clock (JTAG domain)
);

    // -------------------------------------------------------------
    // 2. Memory Block Creation & Initialization
    // -------------------------------------------------------------
    // Create a memory array with 256 entries of 32 bits each.
    (* ram_style = "distributed" *) reg [31:0] ram [57:0];
    
    
    
    
    

 initial begin
 
    ram[0]  = 32'h00500113; // ADDI x2, x0, 5
    ram[1]  = 32'h00C00193; // ADDI x3, x0, 12
    ram[2]  = 32'h00800213; // ADDI x4, x0, 8
    ram[3]  = 32'h003102B3; // ADD x5, x2, x3
    ram[4]  = 32'h00523423; // SW x5, 8(x4)
    ram[5]  = 32'h01003303; // LW x6, 16(x0)
    ram[6]  = 32'h00030513; // ADDI x10, x6, 0
    ram[7]  = 32'h0C4000EF; // JAL x1, 0xC40
    ram[8]  = 32'h402182B3; // SUB x5, x3, x2
    ram[9]  = 32'h00028513; // ADDI x10, x5, 0
    ram[10] = 32'h0B8000EF; // JAL x1, 0xB80
    ram[11] = 32'h00000513; // ADDI x10, x0, 0
    ram[12] = 32'h50000293; // ADDI x5, x0, 1280
    ram[13] = 32'h00523823; // SW x5, 8(x4)
    ram[14] = 32'h01900303; // LW x6, 24(x0)
    ram[15] = 32'h00030513; // ADDI x10, x6, 0
    ram[16] = 32'h0A0000EF; // JAL x1, 0xA00
    ram[17] = 32'h00000513; // ADDI x10, x0, 0
    ram[18] = 32'h08500293; // ADDI x5, x0, 133
    ram[19] = 32'h00829293; // ADDI x5, x5, 8
    ram[20] = 32'h00523823; // SW x5, 8(x4)
    ram[21] = 32'h01900303; // LW x6, 24(x0)
    ram[22] = 32'h00030513; // ADDI x10, x6, 0
    ram[23] = 32'h084000EF; // JAL x1, 0x840
    ram[24] = 32'h00000513; // ADDI x10, x0, 0
    ram[25] = 32'h0FF00293; // ADDI x5, x0, 255
    ram[26] = 32'h01029293; // ADDI x5, x5, 16
    ram[27] = 32'h00523823; // SW x5, 8(x4)
    ram[28] = 32'h01A01303; // LW x6, 40(x0)
    ram[29] = 32'h00030513; // ADDI x10, x6, 0
    ram[30] = 32'h068000EF; // JAL x1, 0x680
    ram[31] = 32'h00000513; // ADDI x10, x0, 0
    ram[32] = 32'h0FE00293; // ADDI x5, x0, 254
    ram[33] = 32'h01029293; // ADDI x5, x5, 16
    ram[34] = 32'h01029293; // ADDI x5, x5, 16
    ram[35] = 32'h00523823; // SW x5, 8(x4)
    ram[36] = 32'h01C02303; // LW x6, 56(x0)
    ram[37] = 32'h00030513; // ADDI x10, x6, 0
    ram[38] = 32'h048000EF; // JAL x1, 0x480
    ram[39] = 32'h00000513; // ADDI x10, x0, 0
    ram[40] = 32'h0FD00293; // ADDI x5, x0, 253
    ram[41] = 32'h00523823; // SW x5, 8(x4)
    ram[42] = 32'h01802303; // LW x6, 24(x0)
    ram[43] = 32'h00030513; // ADDI x10, x6, 0
    ram[44] = 32'h030000EF; // JAL x1, 0x300
    ram[45] = 32'h00C00113; // ADDI x2, x0, 12
    ram[46] = 32'h00A00193; // ADDI x3, x0, 10
    ram[47] = 32'h003162B3; // ADD x5, x2, x3
    ram[48] = 32'h00028513; // ADDI x10, x5, 0
    ram[49] = 32'h01C000EF; // JAL x1, 0x1C0
    ram[50] = 32'h00C00113; // ADDI x2, x0, 12
    ram[51] = 32'h00A00193; // ADDI x3, x0, 10
    ram[52] = 32'h003172B3; // ADD x5, x2, x3
    ram[53] = 32'h00028513; // ADDI x10, x5, 0
    ram[54] = 32'h008000EF; // JAL x1, 0x80
    ram[55] = 32'h00C0006F; // JAL x0, 0xC0
end





    // -------------------------------------------------------------
    // 3. Memory Operation Logic
    // -------------------------------------------------------------
   // 1) JTAG domain writes
        always_ff @(posedge tck_i) begin
            if (wren_i) begin
                ram[loadAddr_i[7:0]] <= loadData_i;
            end
        end
        
        // 2) CPU domain reads
        always_ff @(posedge clk_i) begin
            if (!wren_i & !trst_n_i) begin
                instr_o <= ram[program_counter_i[7:0]];
            end
        end

endmodule






