`timescale 1ns / 1ps

module grf(
    input clk,
    input reset,	 
    input RFWE,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD,
	 input [31:0] WPC,				//instruction now PC
    output [31:0] RD1,
    output [31:0] RD2
    );

    reg [31 : 0] rf [1 : 31];  //$0 = 0, attach to ground

    //initializing
    integer i;
    initial begin
        for (i = 1; i < 32; i = i + 1) begin
            rf[i] = 32'b0;
        end
    end

    //write 
    always @(posedge clk) begin
        if (reset) begin
            for (i = 1; i < 32; i = i + 1) begin
                rf[i] <= 32'b0;
            end
        end
        else if (RFWE && A3 != 0) begin
            rf[A3] <= WD;
				$display("@%h: $%d <= %h", WPC, A3, WD);
        end
    end

    //read
    assign RD1 = (A1 == 0) ? 32'b0 : rf[A1];
    assign RD2 = (A2 == 0) ? 32'b0 : rf[A2];


endmodule
