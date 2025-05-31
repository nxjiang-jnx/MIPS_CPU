`timescale 1ns / 1ps

`include "def.v"

module ext(
    input [15:0] in,
    input D_EXTOp,
    output [31:0] out
    );
	 
	 assign out = (D_EXTOp == 1'b1) ? {{16{in[15]}}, in} : {16'b0, in};

endmodule
