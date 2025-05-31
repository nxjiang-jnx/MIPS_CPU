`timescale 1ns / 1ps

module npc(
    input [31:0] PC,
	 input [31:0] RA,
    input [25:0] Imm,
	 input [31:0] EPCOut,
    input [2:0] NPCOp,
    output [31:0] PC4,
    output [31:0] NPC
    );

    //PC4
    assign PC4 = PC + 4;

    //ALUOp determines NPC
    assign NPC = (NPCOp == 3'b000) ? PC + 4 :                               	    // sequense execution
                 (NPCOp == 3'b001) ? PC + 4 + {{14{Imm[15]}}, Imm[15:0], 2'b0} :  // conditional branch (PC + 4 + offset), sign extend!!!
                 (NPCOp == 3'b010) ? {PC[31:28], Imm, 2'b0} :                     // unconditional jump
					  (NPCOp == 3'b011) ? RA :														 // from 31
					  (NPCOp == 3'b100) ? EPCOut :
					  (NPCOp == 3'b101) ? 32'h00004180 :
					  32'b0;

endmodule
