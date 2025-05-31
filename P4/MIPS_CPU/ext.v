`timescale 1ns / 1ps

module ext(
    input [15:0] in,
    input EXTOp,
    output [31:0] out
    );
	 
	 assign out = EXTOp ? {{16{in[15]}}, in} : {16'b0, in};

endmodule
