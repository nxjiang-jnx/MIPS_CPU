`timescale 1ns / 1ps

`include "def.v"

module MW_reg(
    input clk,
    input reset,
    input [31:0] M_PC,
    input [31:0] M_Instr,
    input [4:0] M_for_GRFWriteAddr,
    input [31:0] M_ALUResult,
    input [31:0] M_RD,
    output reg [31:0] W_PC,
    output reg [31:0] W_Instr,
    output reg [4:0] W_for_GRFWriteAddr,
    output reg [31:0] W_ALUResult,
    output reg [31:0] W_RD
    );

    always @(posedge clk) begin
        if (reset) begin
            W_PC <= 32'h00003000;
            W_Instr <= 0;   
            W_for_GRFWriteAddr <= 0;     
            W_ALUResult <= 0;
            W_RD <= 0;    
        end
        else begin
            W_PC <= M_PC;
            W_Instr <= M_Instr;
            W_for_GRFWriteAddr <= M_for_GRFWriteAddr;
            W_ALUResult <= M_ALUResult;
            W_RD <= M_RD;
        end
    end

endmodule
