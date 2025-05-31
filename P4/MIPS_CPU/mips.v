`timescale 1ns / 1ps

module mips(
    input clk,
    input reset
	 );
	
	 //control signal 
	 wire [5:0] opcode;
	 wire [5:0] funct;
	 wire [1:0] NPCOp;
	 wire [2:0] ALUOp;
	 wire [1:0] A3WRSel;
	 wire [1:0] WDSel;
	 wire EXTOp;
	 wire RFWE;
	 wire ALUBSel;
	 wire DMWr;
	 wire Zero;
	 
	 control CTRL (
    .opcode(opcode), 
    .funct(funct), 
    .Zero(Zero), 
    .NPCOp(NPCOp), 
    .ALUOp(ALUOp), 
    .A3WRSel(A3WRSel), 
    .WDSel(WDSel), 
    .EXTOp(EXTOp), 
    .RFWE(RFWE), 
    .ALUBSel(ALUBSel), 
    .DMWr(DMWr)
    );
	 
	 datapath Datapath (
    .clk(clk), 
    .reset(reset), 
    .opcode(opcode), 
    .funct(funct), 
    .NPCOp(NPCOp), 
    .ALUOp(ALUOp), 
    .A3WRSel(A3WRSel), 
    .WDSel(WDSel), 
    .EXTOp(EXTOp), 
    .RFWE(RFWE), 
    .ALUBSel(ALUBSel), 
    .DMWr(DMWr),
	 .Zero(Zero)
    );	 
	 
endmodule
