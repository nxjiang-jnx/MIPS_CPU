`timescale 1ns / 1ps

module pc(
    input [31:0] NPC,
    input clk,
    input reset,
    output reg [31:0] PC,
	 output reg AdEL  	// for exception
    );

    initial begin
        PC = 32'h00003000;
        AdEL = 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            PC <= 32'h00003000;
        end
        else begin
            if (NPC[1:0] != 2'b00 || (NPC < 32'h00003000) || (NPC > 32'h00006ffc)) begin
					 PC <= NPC;
                AdEL <= 1;  //exception
            end
            else begin
                PC <= NPC;
                AdEL <= 0;
            end            
        end
    end


endmodule
