`timescale 1ns / 1ps

`include "def.v"

module DE_reg(
    input [31:0] D_PC,
    input [31:0] D_Imm32,
    input [31:0] D_Instr,
    input [31:0] D_RD1,
    input [31:0] D_RD2,
    input clk,
    input reset,
    output reg [31:0] E_PC,
    output reg [31:0] E_Imm32,
    output reg [31:0] E_Instr,
    output reg [31:0] E_RD1,
    output reg [31:0] E_RD2
    );

    always @(posedge clk) begin
        if (reset) begin
            E_PC <= 32'h00003000;
            E_Imm32 <= 0;
            E_Instr <= 0;
            E_RD1 <= 0;
            E_RD2 <= 0;
        end
        else begin
            E_PC <= D_PC;
            E_Imm32 <= D_Imm32;
            E_Instr <= D_Instr;
            E_RD1 <= D_RD1;
            E_RD2 <= D_RD2;
        end
    end

endmodule
