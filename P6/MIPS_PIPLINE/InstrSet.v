`timescale 1ns / 1ps

`include "def.v"

module InstrSet(
    input [31:0] Instr,
    output Ical,
    output Rcal,
    output jal,
    output lw,
    output sw,
    output jr,
    output beq
    );

    assign Ical = (Instr[`opcode] == 6'b001101) || (Instr[`opcode] == 6'b001111);   //ori, lui
    assign Rcal = (Instr[`opcode] == 6'b000000 && Instr[`funct] == 6'b100000) ||
                  (Instr[`opcode] == 6'b000000 && Instr[`funct] == 6'b100010);      //add, sub
    assign jal = (Instr[`opcode] == 6'b000011);
    assign lw = (Instr[`opcode] == 6'b100011);
    assign sw = (Instr[`opcode] == 6'b101011);
    assign jr = (Instr[`opcode] == 6'b000000 && Instr[`funct] == 6'b001000);
    assign beq = (Instr[`opcode] == 6'b000100);

endmodule
