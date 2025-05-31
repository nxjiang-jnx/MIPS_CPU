`timescale 1ns / 1ps

`include "def.v"

module EM_reg(
    input clk,
    input reset,
    input [31:0] E_PC,
    input [31:0] E_ALUResult,
    input [31:0] E_Instr,
    input [4:0] E_for_GRFWriteAddr,
    input [31:0] E_for_rt,
    output reg [31:0] M_PC,
    output reg [31:0] M_ALUResult,
    output reg [31:0] M_Instr,
    output reg [4:0] M_for_GRFWriteAddr,
    output reg [31:0] M_for_rt
    );

    always @(posedge clk) begin
        if (reset) begin
            M_PC <= 32'h00003000;
            M_ALUResult <= 0;
            M_Instr <= 0;
            M_for_GRFWriteAddr <= 0;
            M_for_rt <= 0;
        end
        else begin
            M_PC <= E_PC;
            M_ALUResult <= E_ALUResult;
            M_Instr <= E_Instr;
            M_for_GRFWriteAddr <= E_for_GRFWriteAddr;
            M_for_rt <= E_for_rt;
        end
    end


endmodule
