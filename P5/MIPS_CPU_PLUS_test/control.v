`timescale 1ns / 1ps

module control(
    input [5:0] opcode,
    input [5:0] funct,
	 input [4:0] rs,
	 input Zero,
    input Req,
	 input PC_AdEL,
	 input overflow,
	 input DM_AdEL,
	 input AdES,
    output [2:0] NPCOp,
    output [2:0] ALUOp,
    output [1:0] A3WRSel,
    output [1:0] WDSel,
    output EXTOp,
    output RFWE,
    output ALUBSel,
    output DMWr,
	 output en,
    output EXLClr,
	 output [4:0] ExcCodeIn
    );

    //AND gate
    wire add = (opcode == 6'b000000 && funct == 6'b100000);
    wire sub = (opcode == 6'b000000 && funct == 6'b100010);
    wire ori = (opcode == 6'b001101);
    wire lw = (opcode == 6'b100011);
    wire sw = (opcode == 6'b101011);
    wire beq = (opcode == 6'b000100);
    wire lui = (opcode == 6'b001111);
    wire nop = (opcode == 6'b000000 && funct == 6'b000000);
	 wire jal = (opcode == 6'b000011);
	 wire jr = (opcode == 6'b000000 && funct == 6'b001000);	
	 wire mfc0 = (opcode == 6'b010000 && rs == 5'b00000);	
	 wire mtc0 = (opcode == 6'b010000 && rs == 5'b00100);	
	 wire eret = (opcode == 6'b010000 && funct == 6'b011000);	
	 
	 //for exceptions
	 assign RI = !(add || sub || ori || lw || sw || beq || lui || nop || jal || jr || Syscall || mfc0 || mtc0 || eret);
	 assign Syscall = (opcode == 6'b000000 && funct == 6'b001100);
	 
	 assign en = (mtc0) ? 1'b1 : 1'b0;
	 assign EXLClr = (eret) ? 1'b1 : 1'b0;
	 assign ExcCodeIn = PC_AdEL ? 5'd4 :
							  (lw && DM_AdEL) ? 5'd4 :
							  (sw && AdES) ? 5'd5 :
							  Syscall ? 5'd8 :
							  RI ? 5'd10 :
							  ((add || sub) && overflow) ? 5'd12 :
							  5'd0;
							  
    //OR gate
    assign NPCOp = (Req) ? 3'b101 : 			//goto 4180
						 (beq && Zero) ? (3'b001) : 
						 (jal) ? 3'b010 :
						 (jr) ? 3'b011 :
						 (eret) ? 3'b100 :						 						 
						 3'b000;
    assign ALUOp = (sub || beq) ? 3'b001 :
                   (ori) ? 3'b010 :
                   (lui) ? 3'b011 :
                   3'b000;
    assign A3WRSel = (add || sub) ? 2'b01 : 
							(jal) ? 2'b10 :
							2'b00;
    assign WDSel = (lw) ? 2'b01 : 
						 (jal) ? 2'b10 :
						 (mfc0) ? 2'b11 :
						 2'b00;
    assign EXTOp = (lw || sw || beq) ? 1'b1 : 1'b0;
    assign RFWE = ((add && !overflow) || (sub && !overflow) || ori || (lw && !DM_AdEL) || lui || jal || mfc0) ? 1'b1 : 1'b0;
    assign ALUBSel = (ori || lw || sw || lui) ? 1'b1 : 1'b0;
	 assign DMWr = (sw && !AdES) ? 1'b1 : 1'b0;

endmodule
