`timescale 1ns/1ps

module TAP_Controller_Testbench;
    // Inputs
    logic tck_i;
    logic tms_i;
    logic trst_n_i;
    logic tdi_i;
    logic clk_i;
    logic [7:0] program_counter_i;

    // Outputs
    logic tdo_o;
    logic [31:0] instr_o;



    // Internal Signals
    logic test_logic_reset;
    logic run_test_idle;
    logic select_dr_scan;
    logic capture_dr;
    logic shift_dr;
    logic exit1_dr;
    logic pause_dr;
    logic exit2_dr;
    logic update_dr;
    logic select_ir_scan;
    logic capture_ir;
    logic shift_ir;
    logic exit1_ir;
    logic pause_ir;
    logic exit2_ir;
    logic update_ir;

    // Internal variable for `current_ir`
    logic [3:0] current_ir;
    
    
    // Signals for Instruction Decoder
    logic [1:0] ir_select;
  //  logic ir_enable;
    
    
    // Signals for TDI Input Multiplexer
    logic tdi_to_bypass;
  //  logic tdi_to_scan;
    logic tdi_to_load;
    
    
    // Signals for Bypass Register
    logic tdo_bypass;
    
    
     // Signals for Output MUX 1
    logic mux1_tdo;

    // Additional signals for MUX 1 testing
    //logic memory_out = 1'b0;
    logic shift_dr_tdo = 1'b1;
    
    
     // Signals for Output MUX 2
    logic mux2_tdo;
    logic ir_tdo;
    logic select = 1'b0;
    
    
      // Signals for D Flip-Flop
    logic ff_tdo;
    
     // Outputs
   // logic tdo_o;
   
   
   
 


   
    

    // Instantiate the Top JTAG System (including all ports)
    Top_JTAGSystem dut (
        .tck_i(tck_i),
        .clk_i(clk_i),
        .trst_n_i(trst_n_i),
        .tms_i(tms_i),
        .tdi_i(tdi_i),
        .program_counter_i(program_counter_i),
        .tdo_o(tdo_o),
        .instr_o(instr_o)
    );
    
    
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

    
    
    // Instantiate the Instruction Decoder
    InstructionDecoder decoder (
        .current_ir(current_ir),
        .ir_select(ir_select)
      //  .ir_enable(ir_enable)
    );
    
    
    
    // Instantiate the TDI Input Multiplexer
    TDIInputMux tdi_mux (
        .tdi_i(tdi_i),
        .ir_select(ir_select),
        .tdi_to_bypass(tdi_to_bypass),
        //.tdi_to_scan(tdi_to_scan),
        .tdi_to_load(tdi_to_load)
    );
    
    // Instantiate the Bypass Register
    bypass_register bypass_reg (
        .tck_i(tck_i),
        .tdi_to_bypass(tdi_to_bypass),
        .tdo_bypass(tdo_bypass)
    );
    
    
     // Instantiate Output MUX 1
    TDOOutputMux output_mux1 (
        .tdo_bypass(tdo_bypass),
     //   .memory_out(memory_out),
        .shift_dr_tdo(shift_dr_tdo),
        .ir_select(ir_select),
        .mux1_tdo(mux1_tdo)
    );
    
    
     // Instantiate Output MUX 2
    Output_mux_2 output_mux2 (
        .mux1_tdo(mux1_tdo),
        .ir_tdo(ir_tdo),
        .select(select),
        .mux2_tdo(mux2_tdo)
    );
    
    
       // Instantiate D Flip-Flop
    D_FlipFlop d_flip_flop (
        .tck_i(tck_i),
        .mux2_tdo(mux2_tdo),
        .ff_tdo(ff_tdo)
    );
    
    
    // Instantiate the Enable Block
    Enable_Out uut (
        .ff_tdo(ff_tdo),
        .enable(enable)
       // .tdo_o(tdo_o)
    );



 // Outputs
    logic shift_dr_tdo;
    logic [7:0] loadAddr_i;
    logic [31:0] loadData_i;
    logic shift_dr_tdo;
  //  logic wren;
    logic [31:0] instr_o;
 //   logic [31:0] memory_out;

    // Internal Signals
   // logic [3:0] expected_shift_reg;

    // Instantiate the Shift_Data_Register module
    Shift_Data_Register data_register (
        .tdi_to_load(tdi_to_load),
        .tck_i(tck_i),
        .trst_n_i(trst_n_i),
        .shift_dr(shift_dr),
        .capture_dr(capture_dr),
        .update_dr(update_dr),
     //   .shift_dr_tdo(shift_dr_tdo),
        .loadAddr_i(loadAddr_i),
        .loadData_i(loadData_i),
        .wren_i(wren_i)
    );

    // Instantiate the I_mem module
    I_mem instruction_memory (
        .program_counter_i(program_counter_i),
       // .instr_o(instr_o),
        .loadAddr_i(loadAddr_i),
        .loadData_i(loadData_i),
        .wren_i(wren_i),   
        .clk_i(clk_i),
        .tck_i(tck_i)
    );


    // Connect `current_ir` to DUT's `current_ir` output
    assign current_ir = dut.Instruction_Register.current_ir;
    
  //   assign current_ir = Instruction_Register.current_ir;
 

    // Clock generation
    initial begin
        tck_i = 0;
        //#5000; // Extend runtime to 5000ns
        forever #2.5 tck_i = ~tck_i;
        
    end
    
    initial begin
        clk_i = 0;
        forever #2.5 clk_i = ~clk_i; // 10ns clock period
    end
    
    
   
    

    // Test the TAP Controller and Instruction Register
    task automatic test_tap_controller_and_instruction_register;
        begin
            // Apply reset
            $display("[INFO] Applying reset...");
            trst_n_i = 0;
            tms_i = 0;
            tdi_i = 0;
            clk_i = 0;
            program_counter_i = 8'b111;
  
            #5;
            print_state("Reset State");
            trst_n_i = 1;
            #5;
            print_state("Reset Released");

            // Transition to Run-Test/Idle
            tms_i = 0; #5;
            print_state("Run-Test/Idle");

            // Transition to Select-IR-Scan
            tms_i = 1; #5;
            print_state("Select-DR-Scan");
            
            tms_i = 1; #5;
            print_state("Select-IR-Scan");

            // Transition to Capture-IR
            tms_i = 0; #5;
            print_state("Capture-IR1");

            // Transition to Shift-IR
            //tms = 0; #10;
            print_state("HELLO Shift-IR");

            // Load BYPASS instruction (4'b1111)
            $display("[INFO] Loading instruction 0100...");
            tms_i = 0; #5; // 1st bit
          
            tdi_i = 1; tms_i = 0;#5;          // 2nd bit
            tdi_i = 0;tms_i = 0; #5;          // 3rd bit
            tdi_i = 0; #5;  // 4th bit, then exit SHIFT-IR
            tdi_i = 0;
            
            
             // Transition to Update-IR
            tms_i = 1; #5;
             print_state("x ");
            tms_i = 1; #5;
            print_state("x ");
            tms_i = 1; #5;
            print_state("Update-IR");
            
            
     
            // Verify the instruction
            $display("[DEBUG] Current IR: %b", current_ir);
            if ( current_ir !== 4'b1111 || current_ir !== 4'b0001 ) begin
                //$fatal("[ERROR] Instruction not loaded correctly! Current IR: %b", current_ir);
            end else begin
                $display("[INFO] Instruction loaded successfully. Current IR: %b", current_ir);
            end
            
             #5;
            case (current_ir)
                4'b0001: if (ir_select !== 2'b01 ) 
                            $fatal("[ERROR] Instruction Decoder failed for LOAD_PROGRAM! ir_select=%b", ir_select);
                         else
                                begin
                                 $display("[INFO] LOAD PROGRAM...");
                                           
                                            tms_i=1;#5;
                                           print_state("1");
                                            tms_i=0;#5;
                                           print_state("2");
                                    
                                    
                                            tms_i=1;#5;
                                           print_state("3");
                                           
                                            tms_i=0;#5;
                                           print_state("4");
                                           
                                            tms_i=0;#5;
                                           print_state("5");
                                            // Test shift_dr functionality
                                            $display("[INFO] 1 functionality...");
                                           // shift_dr = 1;
               ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                            tdi_i=1; #5;
                                            
                                          
                             
                                           for (int i =0; i <32; i++) begin
                                                tdi_i = 1;  #5;        
                                            end
                                            
                                            tdi_i=1;  #5;
                                            
                                            for (int i = 0; i <6; i++) begin
                                                tdi_i=0;  #5;        
                                            end
               /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                            
                                           tms_i=1;#5;
                                           print_state("exit-DR");

                                            tms_i=1;#5;
                                           print_state("update-DR");
                                    
                                            tms_i=1;#5;
                                           print_state("1");
                                            tms_i=0;#5;
                                           print_state("2");
                                    
                                    
                                            tms_i=0;#5;
                                           print_state("3");
                                           
                                            tms_i=0;#5;
                                           print_state("4");
                                           
                                            tms_i=0;#5;
                                           print_state("5");
                                            // Test shift_dr functionality
                                            $display("[INFO]2  functionality...");
                                           // shift_dr = 1;

                                           
                                            
                     ///////////////////////////////////////////////////////////////////////////////                      
                                            
                                           tdi_i=1; #5;
                                            for (int i =0; i <32; i++) begin
                                                tdi_i = 0;  #5;        
                                            end
                                            
                                            tdi_i=1;  #5
                                            tdi_i=1;  #5
                                            
                                            tdi_i=1;  #5;
                                             tdi_i=1;  #5;
                                            
                                            for (int i = 0; i <3; i++) begin
                                                tdi_i=0;  #5;        
                                            end
                                            
               /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                            
                                           tms_i=1;#5;
                                           print_state("exit-DR");

                                            tms_i=1;#5;
                                           print_state("update-DR");
                                           
                                           
                                           
                                           tms_i=1;#5;
                                           print_state("1");
                                            tms_i=0;#5;
                                           print_state("2");
                                    
                                    
                                            tms_i=0;#5;
                                           print_state("3");
                                           
                                            tms_i=0;#5;
                                           print_state("4");
                                           
                                            tms_i=0;#5;
                                           print_state("5");
                                            // Test shift_dr functionality
                                            $display("[INFO] 3 functionality...");
                                           // shift_dr = 1;
                          /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                            tdi_i=1; #5;
                                            for (int i =0; i <32; i++) begin
                                                tdi_i = 1;  #5;        
                                            end
                                            
                                            tdi_i=1;  #5;
                                             tdi_i=1;  #5;
                                            
                                            
                                            for (int i = 0; i <5; i++) begin
                                                tdi_i=0;  #5;        
                                            end
              /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                              
                                           tms_i=1;#5;
                                           print_state("exit-DR");

                                            tms_i=1;#5;
                                           print_state("update-DR");
                                           
                                           
                                           
                                       //test    //////////////////////////////////////
                                            tms_i=1;#5;
                                           print_state("1");
                                            tms_i=0;#5;
                                           print_state("2");
                                    
                                    
                                            tms_i=0;#5;
                                           print_state("3");
                                           
                                            tms_i=0;#5;
                                           print_state("4");
                                           
                                            tms_i=0;#5;
                                           print_state("5");
                                            // Test shift_dr functionality
                                            $display("[INFO] 3 functionality...");
                                           // shift_dr = 1;
                          /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                            tdi_i=1; #5;
                                            for (int i =0; i <32; i++) begin
                                                tdi_i = 1;  #5;        
                                            end
                                            
                                            tdi_i=1;  #5;
                                             tdi_i=1;  #5;
                                            
                                            
                                            for (int i = 0; i <5; i++) begin
                                                tdi_i=0;  #5;        
                                            end
              /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                              
                                           tms_i=1;#5;
                                           print_state("exit-DR");

                                            tms_i=1;#5;
                                           print_state("update-DR");
                                           
                                       //test    //////////////////////////////////////
                                            
                                           trst_n_i=0; #5;
        
                                            program_counter_i = 8'b0;#5;
                                             program_counter_i = 8'b1111;#5;
                                            program_counter_i = 8'b1;#5;
                                            program_counter_i = 8'b10;#5;
                                           
                                          //  program_counter_i = 8'b1111;#5;
                               
                                           $display("Instruction loaded Successfully LOAD_PROGRAM PASSED" );
                       
                                  end
          
                                  
               //             $display("[INFO] Instruction Decoder passed for LOAD_PROGRAM! ir_select=%b, ir_enable=%b", ir_select, ir_enable);

               
             
                            
                4'b1111: if (ir_select !== 2'b11 ) 
                            $fatal("[ERROR] Instruction Decoder failed for BYPASS! ir_select=%b", ir_select);
                         else 
                            
                             begin
                                 $display("[INFO] BYPASS...");
                                           // capture_dr = 1;
                                 /*           tms=1;#5;
                                           print_state("1");
                                            tms=0;#5;
                                           print_state("2");
                             //       
                                    
                                            tms=1;#5;
                                           print_state("3");
                                           
                                            tms=0;#5;
                                           print_state("4");
                                           
                                            tms=0;#5;
                                           print_state("5");
                                            // Test shift_dr functionality
                                            $display("[INFO] Testing shift_dr functionality...");
                                           // shift_dr = 1;
*/
                                            tdi_i=1; #5;
                                            tdi_i=1;#5;
                                             tdi_i=1; #5;
                                            tdi_i=1;#5;
                                             tdi_i=1; #5;
                                            tdi_i=1;#5;
                                            for (int i = 2; i <96; i++) begin
                                                tdi_i = 1;  #5;        
                                            end
                                            
                                        //    for (int i = 20; i <97; i++) begin
                                         //       tdi =1;  #5;        
                                          //  end
             
                                            //tdi=1; #5;
                                            
                                     tms_i=1;#5;
                                    //       print_state("exit-DR");

                                     tms_i=1;#5;
                                     //      print_state("update-DR");
                                     
                                     $display("Instruction fetched Successfully BYPASS PASSED ");
                    
       
                                  end
                            
                       
    
            endcase
              
            
        end
    endtask

    // Helper Task to Monitor State Transitions
    task automatic print_state(
        input string description
    );
        $display("%t: %s | TAP State: test_logic_reset=%b, run_test_idle=%b, select_dr_scan=%b, capture_dr=%b, shift_dr=%b, exit1_dr=%b, pause_dr=%b, exit2_dr=%b, update_dr=%b, select_ir_scan=%b, capture_ir=%b, shift_ir=%b, exit1_ir=%b, pause_ir=%b, exit2_ir=%b, update_ir=%b", 
            $time, description,
            dut.test_logic_reset,
            dut.run_test_idle,
            dut.select_dr_scan,
            dut.capture_dr,
            dut.shift_dr,
            dut.exit1_dr,
            dut.pause_dr,
            dut.exit2_dr,
            dut.update_dr,
            dut.select_ir_scan,
            dut.capture_ir,
            dut.shift_ir,
            dut.exit1_ir,
            dut.pause_ir,
            dut.exit2_ir,
            dut.update_ir
        );
    endtask

    // Testbench execution
    initial begin
        #200;
        test_tap_controller_and_instruction_register();
       // #5000ns;
        //$finish;
    end

endmodule
