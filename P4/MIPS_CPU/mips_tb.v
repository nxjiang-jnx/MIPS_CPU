`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:40:02 10/31/2024
// Design Name:   mips
// Module Name:   E:/myFolder_3/COLab/P4/MIPS_CPU/mips_tb.v
// Project Name:  MIPS_CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mips
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mips_tb;

	// Inputs
	reg clk;
	reg reset;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk(clk), 
		.reset(reset)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		#10;
		reset = 0;

		// Wait 100 ns for global reset to finish
		#10000;
        
		// Add stimulus here

	end
	
	always #5 clk = ~clk;
      
endmodule

