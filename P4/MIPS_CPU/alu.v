`timescale 1ns / 1ps

module alu(
    input [31:0] Op1,
    input [31:0] Op2,
    input [2:0] ALUOp,
    output Zero,
    output [31:0] result
    );

    //Zero
    assign Zero = (Op1 == Op2) ? 1'b1 : 1'b0;

    //result
    assign result = (ALUOp == 3'b000) ? Op1 + Op2 :     //add
                    (ALUOp == 3'b001) ? Op1 - Op2 :     //sub
                    (ALUOp == 3'b010) ? Op1 | Op2 :     //ori
                    (ALUOp == 3'b011) ? Op2 << 16 :  	  //lui
                                        32'b0;


endmodule
