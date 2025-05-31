`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:59:08 10/03/2024 
// Design Name: 
// Module Name:    gray 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module gray(
    input Clk,
    input Reset,
    input En,
    output reg [2:0] Output,
    output reg Overflow
    );

    initial begin
        Output <= 3'b0;
        Overflow <= 1'b0;
    end

    always @(posedge Clk) begin
        if (Reset) begin
            Output <= 3'b0;
            Overflow <= 1'b0;
        end
        else if (En) begin

             // 更新计数器
            case (Output)
                3'b000: 
                begin 
                    Output <= 3'b001;
                    Overflow <= Overflow;
                end
                3'b001: 
                begin 
                    Output <= 3'b011;
                    Overflow <= Overflow;
                end
                3'b011: 
                begin 
                    Output <= 3'b010;
                    Overflow <= Overflow;
                end
                3'b010: 
                begin
                    Output <= 3'b110;
                    Overflow <= Overflow;
                end
                3'b110: 
                begin 
                    Output <= 3'b111;
                    Overflow <= Overflow;
                end
                3'b111: 
                begin 
                    Output <= 3'b101;
                    Overflow <= Overflow;
                end
                3'b101: 
                begin
                    Output <= 3'b100;
                    Overflow <= Overflow;
                end
                3'b100: 
                begin
                    Output <= 3'b000;
                    Overflow <= 1'b1;
                end
                default: 
                begin
                    Output <= 3'b000;
                    Overflow <= Overflow;
                end 
            endcase
        end
        else begin
            // 当 En 为低电平时，保持当前状态
            Output <= Output;
            Overflow <= Overflow;
        end
    end
endmodule
