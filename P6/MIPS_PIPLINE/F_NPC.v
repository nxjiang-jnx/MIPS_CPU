`timescale 1ns / 1ps

`include "def.v"

module npc(
    input [31:0] PC,
	 input [31:0] RA,
    input [25:0] Imm,
    input [2:0] NPCOp,	//3-bits for NPCOp from main CTRL
    output [31:0] NPC
    );

    //ALUOp determines NPC
    assign NPC = (NPCOp == `Br) ? PC + {{14{Imm[15]}}, Imm[15:0], 2'b0} :  // conditional branch (PC + 4 + offset), sign extend!!!
                 (NPCOp == `Jal) ? {PC[31:28], Imm, 2'b0} :                    // unconditional jump
                 (NPCOp == `Jr) ? RA :
                 PC + 4;                               	    						  // sequense execution           

endmodule