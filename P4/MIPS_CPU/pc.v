`timescale 1ns / 1ps

module pc(
    input [31:0] NPC,
    input clk,
    input reset,
    output reg [31:0] PC
    );

    initial begin
        PC = 32'h00003000;
    end

    always @(posedge clk) begin
        if (reset) begin
            PC <= 32'h00003000;
        end
        else begin
            PC <= NPC;
        end
    end


endmodule
