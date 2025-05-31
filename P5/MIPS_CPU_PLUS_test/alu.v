`timescale 1ns / 1ps

module alu(
    input [31:0] Op1,
    input [31:0] Op2,
    input [2:0] ALUOp,
    output Zero,
	 output reg overflow,
    output reg [31:0] result
    );

    //Zero
    assign Zero = (Op1 == Op2) ? 1'b1 : 1'b0;

    //result and judge exception
    always @(*) begin
        overflow = 0;
        case (ALUOp)
            3'b000: //add
            begin
                result = Op1 + Op2;
                if (Op1[31] == Op2[31] && (result[31] != Op1[31])) begin
                    overflow = 1;
                end
            end 
            3'b001: //sub
            begin
                result = Op1 - Op2;
                if (Op1[31] != Op2[31] && (result[31] != Op1[31])) begin
                    overflow = 1;
                end
            end
            3'b010: //ori
            begin
                result = Op1 | Op2;
            end
            3'b011: //lui
            begin
                result = Op2 << 16;
            end
            default: result = 32'b0;
        endcase
    end

endmodule
