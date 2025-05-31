`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:15:51 10/05/2024 
// Design Name: 
// Module Name:    BlockChecker 
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

`define S0 4'b0000  //无关字母输入，且结尾尚未输入空格
`define S1 4'b0001  //结尾空格，当前单词结束
`define S2 4'b0010  //b/B (98/66)
`define S3 4'b0011  //b/B e/E (101/69)
`define S4 4'b0100  //b/B e/E g/G (103/71)
`define S5 4'b0101  //b/B e/E g/G i/I (105/73)
`define S6 4'b0110  //b/B e/E g/G i/I n/N (110/78)
`define S7 4'b0111  //e/E (101/69)
`define S8 4'b1000  //e/E n/N (110/78)
`define S9 4'b1001  //e/E n/N d/D (100/68)
`define S10 4'b1010 //以标点符号结尾
`define S11 4'b1011

module BlockChecker(
    input clk,
    input reset,
    input [7:0] in,
    output result
    );

    reg [31 : 0] cnt_begin;
    reg [31 : 0] cnt_end;
    reg [3 : 0] status;
    reg unmatched;

    assign result = (unmatched == 1'b0 && cnt_begin == cnt_end) ? 1'b1 : 1'b0;

    // 检查输入字符是否为字母 
    function is_letter(input [7:0] c);
        begin
            is_letter = ( (c >= 8'd65 && c <= 8'd90) || (c >= 8'd97 && c <= 8'd122) );
        end
    endfunction

    initial begin
        cnt_begin <= 32'b0;
        cnt_end <= 32'b0;
        status <= `S1;  //初始形态下默认开始新单词
        unmatched <= 1'b0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt_begin <= 32'b0;
            cnt_end <= 32'b0;
            status <= `S1;
            unmatched <= 1'b0;
        end 
        else begin
            case(status)
                `S0: status <= (in == 8'd32) ? `S1 :    //空格
                                (is_letter(in)) ? `S0:  //仍然是字母
                                `S10;                   //是标点符号
                `S1: status <= (in == 8'd98 || in == 8'd66) ? `S2 :
                                (in == 8'd101 || in == 8'd69) ? `S7:
                                (in == 8'd32) ? `S1 :
                                (!is_letter(in)) ? `S10 :   //是标点符号
                                `S0;
                `S2: status <= (in == 8'd101 || in == 8'd69) ? `S3 : 
                                (in == 8'd32) ? `S1 : 
                                (!is_letter(in)) ? `S10 :   //是标点符号
                                `S0;
                `S3: status <= (in == 8'd103 || in == 8'd71) ? `S4 : 
                                (in == 8'd32) ? `S1 : 
                                (!is_letter(in)) ? `S10 :   //是标点符号
                                `S0; 
                `S4: status <= (in == 8'd105 || in == 8'd73) ? `S5 : 
                                (in == 8'd32) ? `S1 : 
                                (!is_letter(in)) ? `S10 :   //是标点符号
                                `S0; 
                `S5: 
                    begin
                        if (in == 8'd110 || in == 8'd78) begin
                            status <= `S6;                        
                            cnt_begin <= cnt_begin + 1;
                        end
                        else begin
                            status <= (in == 8'd32) ? `S1 : 
                                       (!is_letter(in)) ? `S10 :   //是标点符号
                                       `S0;
                        end
                    end                   
                `S6: 
                    begin
                        if (in == 8'd32) begin
                            status <= `S1;
                        end
                        else if (!is_letter(in)) begin  //标点符号
                            status <= `S10;
                        end
                        else begin
                            status <= `S0;
                            cnt_begin <= cnt_begin - 1;
                        end
                    end 
                `S7: status <= (in == 8'd110 || in == 8'd78) ? `S8 :
                                (in == 8'd32) ? `S1 : 
                                (!is_letter(in)) ? `S10 :   //是标点符号
                                `S0;
                `S8:
                    begin
                        if (in == 8'd100 || in == 8'd68) begin
                            status <= `S9;
                            if (cnt_begin > cnt_end) begin
                                cnt_end <= cnt_end + 1;
                            end                            
                            else begin
                                unmatched <= 1'b1; 
                            end
                        end
                        else status <= (in == 8'd32) ? `S1 :
                                        (!is_letter(in)) ? `S10 :   //是标点符号
                                        `S0;
                    end  
                `S9:
                    begin
                        if (in == 8'd32) begin
                            if (unmatched == 1'b1) begin
                                status <= `S11;
                            end
                            else begin
                                status <= `S1;
                            end                            
                        end
                        else if (!is_letter(in)) begin  //标点符号
                            status <= `S10;
                        end
                        else begin
                            status <= `S0;
                            if (unmatched) begin
                                unmatched <= 1'b0;
                            end
                            else begin
                                cnt_end <= cnt_end - 1;
                            end                          
                        end
                    end   
                `S10:
                    begin
                        status <= (in == 8'd32) ? `S1 :
                                   (in == 8'd98 || in == 8'd66) ? `S2 :
                                   (in == 8'd101 || in == 8'd69) ? `S7 : 
                                   (!is_letter(in)) ? `S10 :
                                   `S0;
                    end                                  
            endcase
        end
    end

endmodule
