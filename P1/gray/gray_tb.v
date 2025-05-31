`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:09:25 10/04/2024
// Design Name:   gray
// Module Name:   E:/myFolder_3/COLab/P1/gray/gray_tb.v
// Project Name:  gray
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: gray
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module gray_tb;

	// Inputs
	reg Clk;
	reg Reset;
	reg En;

	// Outputs
	wire [2:0] Output;
	wire Overflow;

	// Instantiate the Unit Under Test (UUT)
	gray uut (
		.Clk(Clk), 
		.Reset(Reset), 
		.En(En), 
		.Output(Output), 
		.Overflow(Overflow)
	);

	initial begin
		// Initialize Inputs
		Clk = 0;
		Reset = 0;
		En = 0;

		// Wait 10 ns for global reset to finish
		#10;
        
		// Add stimulus here
		En = 1;
		#20
		Reset = 1;
		#5
		Reset = 0;

	end
	
	 always #5 Clk = ~Clk;
      
endmodule

