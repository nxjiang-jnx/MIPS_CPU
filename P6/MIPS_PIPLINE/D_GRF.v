`timescale 1ns / 1ps

`include "def.v"

module grf(
    input clk,
    input reset,	 
    input W_RFWr,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD,
	 input [31:0] W_PC,			 //PC during writeback(W)
    output [31:0] RD1,
    output [31:0] RD2
    );

    reg [31 : 0] rf [0 : 31];  
    //initializing
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            rf[i] = 32'b0;
        end
    end

    //write 
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                rf[i] <= 32'b0;
            end
        end
        else if (W_RFWr && A3 != 0) begin			//$0 = 0, attached to ground
            rf[A3] <= WD;
				$display("%d@%h: $%d <= %h", $time, W_PC, A3, WD);
        end
    end

    //read, inside transmission
    assign RD1 = (W_RFWr && A1 == A3 && A3 != 0) ? WD : rf[A1];
    assign RD2 = (W_RFWr && A2 == A3 && A3 != 0) ? WD : rf[A2];

endmodule
