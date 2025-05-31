`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:41:40 10/04/2024 
// Design Name: 
// Module Name:    expr 
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

/*�种状�
2'b00  起始状�空串)
2'b01  死非法（含有非法字符/连着多个数字/连着多个字符/起始就是符号），无论怎么也回不到合法
2'b10  起始是数字，且均是一个数字和一个合法字符相间，且最后是数字，此时out�
2'b11  起始是数字，且均是一个数字和一个合法字符相间，且最后是合法字符
*/

`define S0 2'b00
`define S1 2'b01
`define S2 2'b10
`define S3 2'b11

module expr(
    input clk,
    input clr,
    input [7:0] in,
    output out
    );

    reg [1 : 0] status;
    wire [1 : 0] charType;

    assign out = (status == `S2) ? 1'b1 : 1'b0;
    assign charType = (in >= "0" && in <= "9") ? 2'b00 :    //数字
                        (in == "+" || in == "*") ? 2'b10 :  //合法字符���
                        2'b01;                                      //非法字符
    initial begin
        status <= `S0;
    end

    always @(posedge clk or posedge clr) begin
        if (clr) begin
            status <= `S0;
        end
        else begin
            case(status)
                `S0:
                begin
                    if (charType == 2'b00) begin
                        status <= `S2;
                    end
                    else begin
                        status <= `S1;
                    end
                end
                `S1:
                begin
                    status <= status;
                end
                `S2:
                begin
                    if (charType == 2'b10) begin
                        status <= `S3;
                    end 
                    else begin
                        status <= `S1;
                    end
                end
                `S3:
                begin
                    if(charType == 2'b00) begin
                        status <= `S2;
                    end
                    else begin
                        status <= `S1;
                    end
                end
            endcase
        end
    end


endmodule
