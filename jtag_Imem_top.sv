

`timescale 1ns / 1ps

module Top_JTAGSystem(
    input logic tck_i,       // JTAG test clock
    input logic clk_i,
    input logic trst_n_i,    // JTAG reset (active low)
    input logic tms_i,       // Test Mode Select for TAP controller
    input logic tdi_i,       // Test Data In
    input logic [7:0] program_counter_i,
    output logic tdo_o,       // Test Data Out
    output logic [31:0] instr_o      // decoded instruction
    
);

    // State outputs
    logic test_logic_reset, run_test_idle, select_dr_scan;
    logic capture_dr, shift_dr, exit1_dr, pause_dr;
    logic exit2_dr, update_dr, select_ir_scan;
    logic capture_ir, shift_ir, exit1_ir, pause_ir;
    logic exit2_ir, update_ir;
    
    // Instruction Register and Decoding Outputs
    logic ir_tdo;
    logic [3:0] current_ir;
    
    //instruction decoder  outputs
    logic [1:0] ir_select;        // Output: 3-bit decoded select
  

    // input mux outputs
    logic tdi_to_bypass;   // Output to bypass logic
  
    logic tdi_to_load;      // Output to load program logic
 
    
    // bypass register output
    logic tdo_bypass;          // Test Data Out
    
    //output_mux1 output
    
    logic mux1_tdo;              // Output of the multiplexer
    
    //output_mux2 output
    logic mux2_tdo;         // Output: Selected TDO
    
    //d_flip_flop output
    logic ff_tdo;            // Data output
    

    
  
    
    //shift data register
 
    logic [7:0]         loadAddr_i;    // 64-bit address for instruction memory
    logic [31:0]         loadData_i;    // 32-bit data for instruction memory
   
    
    
    logic update_dr_sig;
    
 
    // TAPC Instantiation
    tap_controller TAP_Controller (
        .tck_i(tck_i),
        .trst_n_i(trst_n_i),
        .tms_i(tms_i),
        .select(select),
        .enable(enable),
        .test_logic_reset(test_logic_reset),
        .run_test_idle(run_test_idle),
        .select_dr_scan(select_dr_scan),
        .capture_dr(capture_dr),
        .shift_dr(shift_dr),
        .exit1_dr(exit1_dr),
        .pause_dr(pause_dr),
        .exit2_dr(exit2_dr),
        .update_dr(update_dr),
        .select_ir_scan(select_ir_scan),
        .capture_ir(capture_ir),
        .shift_ir(shift_ir),
        .exit1_ir(exit1_ir),
        .pause_ir(pause_ir),
        .exit2_ir(exit2_ir),
        .update_ir(update_ir)
    );

    // Instantiate the Instruction Register
    
    jtag_instruction_register  Instruction_Register (
        .tck_i(tck_i),
        .trst_n_i(trst_n_i),
        .shift_ir(shift_ir),
        .capture_ir(capture_ir),
        .update_ir(update_ir),
        .tdi_i(tdi_i),
        .ir_tdo(ir_tdo),
        .current_ir(current_ir)
    );

    // instantiation instruction decoder
    InstructionDecoder Instruction_decoder (
        .current_ir (current_ir),
        .ir_select  (ir_select)
      
    );

    //  instantiation INput_mux
    (* DONT_TOUCH = "TRUE" *)TDIInputMux Input_mux (
        .tdi_i(tdi_i),
        .ir_select(ir_select),
        .tdi_to_bypass(tdi_to_bypass),
   
        .tdi_to_load(tdi_to_load)
    );
    

  
    
    //  instantiation  bbypass register
    bypass_register bypass_register (
        .tck_i(tck_i),
        .tdi_to_bypass(tdi_to_bypass),
        .tdo_bypass(tdo_bypass)
    );


     //  instantiation output_mux1
    (* DONT_TOUCH = "TRUE" *)TDOOutputMux Out_Mux1 (
        .tdo_bypass (tdo_bypass),
        .shift_dr_tdo (shift_dr_tdo),
     
        .ir_select (ir_select),
        .mux1_tdo (mux1_tdo)
    );
    
    //instantiation output mux2

    (* DONT_TOUCH = "TRUE" *) Output_mux_2 output_mux2 (
        .mux1_tdo(mux1_tdo),
        .ir_tdo(ir_tdo),
        .select(select),
        .mux2_tdo(mux2_tdo)
    );
    
     // Instantiate D Flip-Flop
    D_FlipFlop D_flip_flop (
        .tck_i(tck_i),
        .mux2_tdo(mux2_tdo),
        .ff_tdo(ff_tdo)
    );
    
     //  enable
    Enable_Out Enable (
        .ff_tdo(ff_tdo),  // Connect ff_tdo to DUT
        .enable(enable),  // Connect enable to DUT
        .tdo_o(tdo_o)         // Connect tdo to DUT
    );
    
    Shift_Data_Register Shift_Data_Register(
  
    .tdi_to_load(tdi_to_load),
    .tck_i(tck_i),          // JTAG test clock
    .trst_n_i(trst_n_i),       // JTAG reset (active low)
    .shift_dr(shift_dr),     // From TAP controller: shift DR state
    .capture_dr(capture_dr),   // From TAP controller: capture DR state
    .update_dr(update_dr),    // From TAP controller: update DR state
  
    .shift_dr_tdo(shift_dr_tdo),       // Test Data Out (DR serial out)
    .loadAddr_i(loadAddr_i),    // 64-bit address for instruction memory
    .loadData_i(loadData_i),    // 32-bit data for instruction memory
    .wren_i(wren_i)
    );
    
    I_mem Instruction_Memory (
    
        .program_counter_i(program_counter_i),  // PC from CPU domain
        .instr_o(instr_o), // Instruction output
        .loadAddr_i(loadAddr_i),         // Load address for JTAG writes
        .loadData_i(loadData_i),         // Data to write from JTAG
        .wren_i(wren_i),             // Write enable (JTAG domain
        .trst_n_i(trst_n_i),
    
        .clk_i(clk_i),              // CPU clock (for instruction fetch)
        .tck_i(tck_i)
    
    
    );
    

endmodule




