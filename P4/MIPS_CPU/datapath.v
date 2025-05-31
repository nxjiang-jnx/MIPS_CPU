`timescale 1ns / 1ps

module datapath(
    input clk,
    input reset,
	 //control
	 input [1:0] NPCOp,
	 input [2:0] ALUOp,
	 input [1:0] A3WRSel,
	 input [1:0] WDSel,
	 input EXTOp,
	 input RFWE,
	 input ALUBSel,
	 input DMWr,
	 output [5:0] opcode,
	 output [5:0] funct,
	 output Zero
    );
	 
	 //---------------------------------//PC
	 wire [31:0] PC;
	 wire [31:0] NPC;
	 wire [25:0] Imm26;
	 wire [31:0] PC4;
	 
	 //---------------------------------//IM
	 wire [31:0] Instr;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [15:0] Imm16;
	 
	 //---------------------------------//GRF
	 wire [4:0] A1;
	 wire [4:0] A2;
	 wire [4:0] A3;
	 wire [31:0] GRF_WD;
	 wire [31:0] RD1;
	 wire [31:0] RD2;	
		
	 assign A1 = rs;
	 assign A2 = rt;
	 assign A3 = (A3WRSel == 2'b00) ? rt :
					 (A3WRSel == 2'b01) ? rd :
					 (A3WRSel == 2'b10) ? 5'd31 :
					 5'b0;
	 assign GRF_WD = (WDSel == 2'b00) ? ALU_result :
						  (WDSel == 2'b01) ? RD :
						  (WDSel == 2'b10) ? PC4 :
						  32'b0;
				
	 //---------------------------------//EXT
	 wire [31:0] EXT_result;
	 
	 //---------------------------------//ALU
	 wire [31:0] Op1;
	 wire [31:0] Op2;
	 wire [31:0] ALU_result;
	 
	 assign Op1 = RD1;
	 assign Op2 = (ALUBSel) ? EXT_result : RD2;
	 
	 //---------------------------------//DM
	 wire [31:0] RD;
	 wire [31:0] A;
	 wire [31:0] DM_WD;
	 
	 assign A = ALU_result;
	 assign DM_WD = RD2;	 
	 
	 
	 //---------------------------------//Instantiation	 
	 pc _PC (
    .NPC(NPC), 
    .clk(clk), 
    .reset(reset), 
    .PC(PC)
    );
	 
	 npc _NPC (
    .PC(PC), 
	 .RA(RD1),
    .Imm(Imm26), 
    .NPCOp(NPCOp), 
    .PC4(PC4), 
    .NPC(NPC)
    );
	 
	 im _IM (
    .PC(PC), 
    .Instr(Instr), 
    .opcode(opcode), 
    .funct(funct), 
    .rs(rs), 
    .rt(rt), 
    .rd(rd), 
    .imm16(Imm16), 
    .imm26(Imm26)
    );
	 
	 grf _GRF (
    .clk(clk), 
    .reset(reset), 
    .RFWE(RFWE), 
    .A1(A1), 
    .A2(A2), 
    .A3(A3), 
    .WD(GRF_WD), 
    .WPC(PC), 
    .RD1(RD1), 
    .RD2(RD2)
    );
	 
	 ext _EXT (
    .in(Imm16), 
    .EXTOp(EXTOp), 
    .out(EXT_result)
    );
	 
	 alu _ALU (
    .Op1(Op1), 
    .Op2(Op2), 
    .ALUOp(ALUOp), 
    .Zero(Zero), 
    .result(ALU_result)
    );
	
	 dm _DM (
    .clk(clk), 
    .reset(reset), 
    .DMWr(DMWr), 
    .pc(PC), 
    .A(A), 
    .WD(DM_WD), 
    .RD(RD)
    ); 

endmodule
