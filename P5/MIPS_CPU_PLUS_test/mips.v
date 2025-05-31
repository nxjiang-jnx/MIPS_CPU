`timescale 1ns / 1ps

module mips(
    input clk,
    input reset
	 );
	
	 //control signal 
	 wire [5:0] opcode;
	 wire [5:0] funct;	 
	 wire [2:0] NPCOp;
	 wire [2:0] ALUOp;
	 wire [1:0] A3WRSel;
	 wire [1:0] WDSel;
	 wire EXTOp;
	 wire RFWE;
	 wire ALUBSel;
	 wire DMWr;
	 wire Zero;
	 //--------------------------//for exception
	 wire [4:0] rs;
	 wire [4:0] ExcCodeIn;
	 wire en;
	 wire EXLClr;
	 wire Req;
	 wire PC_AdEL;
	 wire overflow;
	 wire DM_AdEL;
	 wire AdES;
	 
	 control CTRL (
    .opcode(opcode), 
    .funct(funct), 
    .rs(rs), 
    .Zero(Zero), 
    .Req(Req), 
    .PC_AdEL(PC_AdEL), 
    .overflow(overflow), 
    .DM_AdEL(DM_AdEL), 
    .AdES(AdES), 
    .NPCOp(NPCOp), 
    .ALUOp(ALUOp), 
    .A3WRSel(A3WRSel), 
    .WDSel(WDSel), 
    .EXTOp(EXTOp), 
    .RFWE(RFWE), 
    .ALUBSel(ALUBSel), 
    .DMWr(DMWr), 
    .en(en), 
    .EXLClr(EXLClr), 
    .ExcCodeIn(ExcCodeIn)
    );
	 
	 datapath Datapath (
    .clk(clk), 
    .reset(reset), 
    .NPCOp(NPCOp), 
    .ALUOp(ALUOp), 
    .A3WRSel(A3WRSel), 
    .WDSel(WDSel), 
    .EXTOp(EXTOp), 
    .RFWE(RFWE), 
    .ALUBSel(ALUBSel), 
    .DMWr(DMWr), 
    .en(en), 
    .EXLClr(EXLClr), 
    .ExcCodeIn(ExcCodeIn), 
    .opcode(opcode), 
    .funct(funct), 
    .rs(rs), 
    .Zero(Zero), 
    .Req(Req), 
    .PC_AdEL(PC_AdEL), 
    .overflow(overflow), 
    .DM_AdEL(DM_AdEL), 
    .AdES(AdES)
    );
	 
endmodule
