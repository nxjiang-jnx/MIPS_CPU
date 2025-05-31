`timescale 1ns / 1ps

module control(
    input [5:0] opcode,
    input [5:0] funct,
	 input Zero,
    output [1:0] NPCOp,
    output [2:0] ALUOp,
    output [1:0] A3WRSel,
    output [1:0] WDSel,
    output EXTOp,
    output RFWE,
    output ALUBSel,
    output DMWr
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

    //OR gate
    assign NPCOp = (beq && Zero) ? (2'b01) : 
						 (jal) ? 2'b10 :
						 (jr) ? 2'b11 :
						 2'b00;
    assign ALUOp = (sub || beq) ? 3'b001 :
                    (ori) ? 3'b010 :
                    (lui) ? 3'b011 :
                    3'b000;
    assign A3WRSel = (add || sub) ? 2'b01 : 
							(jal) ? 2'b10 :
							2'b00;
    assign WDSel = (lw) ? 2'b01 : 
						 (jal) ? 2'b10 :
						 2'b00;
    assign EXTOp = (lw || sw) ? 1'b1 : 1'b0;
    assign RFWE = (add || sub || ori || lw || lui || jal) ? 1'b1 : 1'b0;
    assign ALUBSel = (ori || lw || sw || lui) ? 1'b1 : 1'b0;
	 assign DMWr = (sw) ? 1'b1 : 1'b0;

endmodule
