`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:34:41 10/08/2024
// Design Name:   BlockChecker
// Module Name:   E:/myFolder_3/COLab/P1/BlockChecker/BlockChecker_tb.v
// Project Name:  BlockChecker
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: BlockChecker
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module BlockChecker_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] in;

	// Outputs
	wire result;

	// Instantiate the Unit Under Test (UUT)
	BlockChecker uut (
		.clk(clk), 
		.reset(reset), 
		.in(in), 
		.result(result)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		in = 0;

        
		// Add stimulus here
		#10;
		in = 97;
		
		#10;
		in = 32;
		
				#10
		in = 69;
		#10
		in = 110;
		#10
		in = 100;
		
				#10;
		in = 32;
		
		#10
		in = 66;
		#10
		in = 69;
		#10
		in = 103;
		#10
		in = 105;
		#10
		in = 78;
		
		#10
		in = 32;
		

		#10
		in = 69;
		#10
		in = 110;
		#10
		in = 100;
		
		#10
		in = 99;
		
		#10
		in = 32;
		
		#10
		in = 69;
		#10
		in = 110;
		#10
		in = 100;
		
		#10;
		in = 32;
		
		#10
		in = 66;
		#10
		in = 69;
		#10
		in = 103;
		#10
		in = 105;
		#10
		in = 78;
		
		#10
		in = 99;
		
	end
	
	always #5 clk = ~clk;
	
	
      
endmodule

