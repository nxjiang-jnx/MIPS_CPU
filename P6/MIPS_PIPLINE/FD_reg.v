`timescale 1ns / 1ps

`include "def.v"

module FD_reg(
    input clk,
    input reset,
    input D_Stall,
    input [31:0] F_Instr,
    input [31:0] F_PC,
    output reg [31:0] D_Instr,
    output reg [31:0] D_PC
    );

    always @(posedge clk) begin
        if (reset) begin				//clear up D
            D_PC <= 32'h00003000;
            D_Instr <= 0;
        end
        else if (!D_Stall) begin						//pipeline runs
            D_PC <= F_PC;
            D_Instr <= F_Instr;
        end
    end

endmodule
