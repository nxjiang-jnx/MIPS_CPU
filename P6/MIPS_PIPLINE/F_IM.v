`timescale 1ns / 1ps

`include "def.v"

module im(
    input [31:0] PC,
    output [31:0] Instr
    );

    wire [11 : 0] Addr;   									  //Address in IM
	 assign Addr = (PC - 32'h00003000) >> 2;
    reg [31 : 0] InstrMemory [0 : 4095];             //ROM

    initial begin
        $readmemh("code.txt", InstrMemory); 
    end

    assign Instr = InstrMemory[Addr];     

endmodule
