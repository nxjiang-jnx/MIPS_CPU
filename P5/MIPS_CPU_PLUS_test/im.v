`timescale 1ns / 1ps

module im(
    input [31:0] PC,
    output [31:0] Instr,
    output [5:0] opcode,
    output [5:0] funct,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [15:0] imm16,
    output [25:0] imm26
    );

    wire [11 : 0] Addr;   									  //Address in IM
	 assign Addr = (PC - 32'h00003000) >> 2;
    reg [31 : 0] InstrMemory [0 : 4095];             //ROM

    initial begin
        $readmemh("code.txt", InstrMemory); 
    end

    assign Instr = InstrMemory[Addr];     
    assign opcode = InstrMemory[Addr][31 : 26];
    assign funct = InstrMemory[Addr][5 : 0];
    assign rs = InstrMemory[Addr][25 : 21];
    assign rt = InstrMemory[Addr][20 : 16];
    assign rd = InstrMemory[Addr][15 : 11];
    assign imm16 = InstrMemory[Addr][15 : 0];
    assign imm26 = InstrMemory[Addr][25 : 0];

endmodule
