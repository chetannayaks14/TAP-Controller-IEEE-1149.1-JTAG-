`timescale 1ns / 1ps

// TDO Output Multiplexer
module TDOOutputMux(
    input logic tdo_bypass,    //bypass
 
    input logic shift_dr_tdo,     // load program
    input logic [1:0] ir_select,
    output logic mux1_tdo
);
    always_comb begin
        case (ir_select)
            2'b01:begin
                 mux1_tdo = shift_dr_tdo ; // load_program
             
            end
      
            2'b11:  mux1_tdo = tdo_bypass ;   // bypass
            default: mux1_tdo = 0;
        endcase
    end
endmodule

