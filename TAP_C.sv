`timescale 1ns / 1ps


module tap_controller (
    // Inputs
    input  logic tck_i,     // Test Clock input: drives the TAP controller state machine
    input  logic trst_n_i,  // Test Reset input (active low): resets the TAP controller
    input  logic tms_i,     // Test Mode Select input: determines the state transitions

    // Outputs
    output logic select,  // Output: Selects between Instruction Register (IR) and Data Register (DR)
    output logic enable,  // Output: Enables the TDO (Test Data Out) to send data

    // TAP Controller State Outputs
    output logic test_logic_reset, // Active when in the Test-Logic-Reset state
    output logic run_test_idle,    // Active when in the Run-Test/Idle state
    output logic select_dr_scan,   // Active when in the Select-DR-Scan state
    output logic capture_dr,       // Active when in the Capture-DR state
    output logic shift_dr,         // Active when in the Shift-DR state
    output logic exit1_dr,         // Active when in the Exit1-DR state
    output logic pause_dr,         // Active when in the Pause-DR state
    output logic exit2_dr,         // Active when in the Exit2-DR state
    output logic update_dr,        // Active when in the Update-DR state
    output logic select_ir_scan,   // Active when in the Select-IR-Scan state
    output logic capture_ir,       // Active when in the Capture-IR state
    output logic shift_ir,         // Active when in the Shift-IR state
    output logic exit1_ir,         // Active when in the Exit1-IR state
    output logic pause_ir,         // Active when in the Pause-IR state
    output logic exit2_ir,         // Active when in the Exit2-IR state
    output logic update_ir         // Active when in the Update-IR state
);

    // Enumerated type for TAP controller states with full names
    typedef enum logic [3:0] {
        TEST_LOGIC_RESET   = 4'b0000, // State: Test-Logic-Reset
        RUN_TEST_IDLE      = 4'b0001, // State: Run-Test/Idle
        SELECT_DR_SCAN     = 4'b0010, // State: Select-DR-Scan
        CAPTURE_DR         = 4'b0011, // State: Capture-DR
        SHIFT_DR           = 4'b0100, // State: Shift-DR
        EXIT1_DR           = 4'b0101, // State: Exit1-DR
        PAUSE_DR           = 4'b0110, // State: Pause-DR
        EXIT2_DR           = 4'b0111, // State: Exit2-DR
        UPDATE_DR          = 4'b1000, // State: Update-DR
        SELECT_IR_SCAN     = 4'b1001, // State: Select-IR-Scan
        CAPTURE_IR         = 4'b1010, // State: Capture-IR
        SHIFT_IR           = 4'b1011, // State: Shift-IR
        EXIT1_IR           = 4'b1100, // State: Exit1-IR
        PAUSE_IR           = 4'b1101, // State: Pause-IR
        EXIT2_IR           = 4'b1110, // State: Exit2-IR
        UPDATE_IR          = 4'b1111  // State: Update-IR
    } tap_state_t;

    tap_state_t current_state, next_state; // Registers to hold current and next state

    // Sequential logic: State transition on clock edge or reset
    always_ff @(posedge tck_i or negedge trst_n_i) begin
        if (!trst_n_i) begin
            current_state <= TEST_LOGIC_RESET; // On reset, go to Test-Logic-Reset state
        end else begin
            current_state <= next_state; // Otherwise, move to the next state
        end
    end

    // Combinational logic: Determine the next state based on current state and TMS
    always_comb begin
        unique case (current_state)
            TEST_LOGIC_RESET:   next_state = (tms_i) ? TEST_LOGIC_RESET   : RUN_TEST_IDLE;
            RUN_TEST_IDLE:      next_state = (tms_i) ? SELECT_DR_SCAN     : RUN_TEST_IDLE;
            SELECT_DR_SCAN:     next_state = (tms_i) ? SELECT_IR_SCAN     : CAPTURE_DR;
            CAPTURE_DR:         next_state = (tms_i) ? EXIT1_DR           : SHIFT_DR;
            SHIFT_DR:           next_state = (tms_i) ? EXIT1_DR           : SHIFT_DR;
            EXIT1_DR:           next_state = (tms_i) ? UPDATE_DR          : PAUSE_DR;
            PAUSE_DR:           next_state = (tms_i) ? EXIT2_DR           : PAUSE_DR;
            EXIT2_DR:           next_state = (tms_i) ? UPDATE_DR          : SHIFT_DR;
            UPDATE_DR:          next_state = (tms_i) ? SELECT_DR_SCAN     : RUN_TEST_IDLE;
            SELECT_IR_SCAN:     next_state = (tms_i) ? TEST_LOGIC_RESET   : CAPTURE_IR;
            CAPTURE_IR:         next_state = (tms_i) ? EXIT1_IR           : SHIFT_IR;
            SHIFT_IR:           next_state = (tms_i) ? EXIT1_IR           : SHIFT_IR;
            EXIT1_IR:           next_state = (tms_i) ? UPDATE_IR          : PAUSE_IR;
            PAUSE_IR:           next_state = (tms_i) ? EXIT2_IR           : PAUSE_IR;
            EXIT2_IR:           next_state = (tms_i) ? UPDATE_IR          : SHIFT_IR;
            UPDATE_IR:          next_state = (tms_i) ? SELECT_DR_SCAN     : RUN_TEST_IDLE;
            default:            next_state = TEST_LOGIC_RESET; // Default case for safety
        endcase
    end

    // Combinational logic: Output signal assignments based on current state
    always_comb begin
        // Default all outputs to inactive (0)
        test_logic_reset = 1'b0;
        run_test_idle    = 1'b0;
        select_dr_scan   = 1'b0;
        capture_dr       = 1'b0;
        shift_dr         = 1'b0;
        exit1_dr         = 1'b0;
        pause_dr         = 1'b0;
        exit2_dr         = 1'b0;
        update_dr        = 1'b0;
        select_ir_scan   = 1'b0;
        capture_ir       = 1'b0;
        shift_ir         = 1'b0;
        exit1_ir         = 1'b0;
        pause_ir         = 1'b0;
        exit2_ir         = 1'b0;
        update_ir        = 1'b0;
        enable           = 1'b1; // TDO disabled by default
        select           = 1'b0; // Default to Data Register output

        // Set outputs based on current state
        case (current_state)
            TEST_LOGIC_RESET: test_logic_reset = 1'b1;
            RUN_TEST_IDLE:    run_test_idle    = 1'b1;

            // Data Register states
            SELECT_DR_SCAN:   select_dr_scan = 1'b1;
            CAPTURE_DR:       begin 
                                capture_dr = 1'b1; 
                                enable     = 1'b1; // Enable TDO during DR operations
                              end
            SHIFT_DR:         begin 
                                shift_dr = 1'b1;
                                enable   = 1'b1; 
                                select   = 1'b0; // Select Data Register for output
                              end
            EXIT1_DR:         exit1_dr = 1'b1;
            PAUSE_DR:         pause_dr = 1'b1;
            EXIT2_DR:         exit2_dr = 1'b1;
            UPDATE_DR:        update_dr = 1'b1;

            // Instruction Register states
            SELECT_IR_SCAN:   select_ir_scan = 1'b1;
            CAPTURE_IR:       begin 
                                capture_ir = 1'b1;
                                enable     = 1'b1; // Enable TDO during IR operations
                              end
            SHIFT_IR:         begin 
                                shift_ir = 1'b1; 
                                enable   = 1'b1;
                                select   = 1'b1; // Select Instruction Register for output
                              end
            EXIT1_IR:         exit1_ir = 1'b1;
            PAUSE_IR:         pause_ir = 1'b1;
            EXIT2_IR:         exit2_ir = 1'b1;
            UPDATE_IR:        update_ir = 1'b1;
        endcase
    end
    
   


endmodule
