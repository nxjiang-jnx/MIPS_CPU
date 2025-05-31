`timescale 1ns / 1ps

module dm(
    input clk,
    input reset,
    input DMWr,
	 input overflow,
	 input [31:0] pc,
    input [31:0] A,
    input [31:0] WD,
    output [31:0] RD,
    output reg AdEL,
    output reg AdES
    );

    wire [11 : 0] addr;
	 assign addr = A >> 2;
    reg [31 : 0] DataMemory [0 : 3071];

    //initializing
    integer i;
    initial begin
        for (i = 0; i < 3072; i = i + 1) begin
            DataMemory[i] = 32'b0;
        end
        AdEL = 0;
        AdES = 0;
    end

    //check exception
    always @(*) begin
        AdEL = 0;
        AdES = 0;

        if ((A[1:0] != 2'b00) || (A < 32'h00000000) || (A > 32'h00002fff) || overflow) begin
            AdEL = 1;
				AdES = 1;
        end
    end

    //write
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 3072; i = i + 1) begin
                DataMemory[i] <= 32'b0;
            end   
        end
        else if (DMWr && !AdES) begin
            DataMemory[addr] <= WD;
				$display("@%h: *%h <= %h", pc, A, WD);
        end
    end

    //read
    assign RD = DataMemory[addr];

endmodule
