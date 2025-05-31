`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:41:49 10/04/2024
// Design Name:   expr
// Module Name:   E:/myFolder_3/COLab/P1/expr/expr_tb.v
// Project Name:  expr
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: expr
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module expr_tb;

	// Inputs
	reg clk;
	reg clr;
	reg [7:0] in;

	// Outputs
	wire out;

	// Instantiate the Unit Under Test (UUT)
	expr uut (
		.clk(clk), 
		.clr(clr), 
		.in(in), 
		.out(out)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		clr = 0;
		in = 0;

		// Wait 100 ns for global reset to finish
        
		// Add stimulus here
		in = 49;
		#10;
		in = 43;
		#10;
		in = 50;
		#10;
		in = 42;
		#10;
		in = 51;
		#30;
		clr = 1;
		#10;
		clr = 0;
		in = 49;
		#10;
		in = 43;
		#10;
		in = 50;
		#10;
		in = 42;
		#10;
		in = 51;
		#30;

	end
	
	always #5 clk = ~clk;
      
endmodule

