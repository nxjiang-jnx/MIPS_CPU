`timescale 1ns / 1ps

`include "def.v"

module hazardUnit(
    input [31:0] D_Instr,
    input [31:0] E_Instr,
    input [31:0] M_Instr,
    input [31:0] W_Instr,
    input [4:0] E_for_GRFWriteAddr,
    input [4:0] M_for_GRFWriteAddr,
    input [4:0] W_GRFWriteAddr,
    output F_Stall,
    output D_Stall,
    output E_Flush,
    output [2:0] D_Sel_rs,
    output [2:0] D_Sel_rt,
    output [2:0] E_Sel_rs,
    output [2:0] E_Sel_rt,
    output [2:0] M_Sel_rt
    );

    //-----------D level-----------//
    wire D_Ical, D_Rcal, D_jal, D_lw, D_sw, D_jr, D_beq;
    wire [4:0] D_rs, D_rt;
    InstrSet D_InstrSet (.Instr(D_Instr), .Ical(D_Ical), .Rcal(D_Rcal), .jal(D_jal), .lw(D_lw), .sw(D_sw), .jr(D_jr), .beq(D_beq));
    assign D_rs = D_Instr[`rs];
    assign D_rt = D_Instr[`rt];
    
    //-----------E level-----------//
    wire E_Ical, E_Rcal, E_jal, E_lw, E_sw, E_jr, E_beq;
    wire [4:0] E_rs, E_rt, E_rd;
    InstrSet E_InstrSet (.Instr(E_Instr), .Ical(E_Ical), .Rcal(E_Rcal), .jal(E_jal), .lw(E_lw), .sw(E_sw), .jr(E_jr), .beq(E_beq));
    assign E_rs = E_Instr[`rs];
    assign E_rt = E_Instr[`rt];
    assign E_rd = E_Instr[`rd];

    //-----------M level-----------//
    wire M_Ical, M_Rcal, M_jal, M_lw, M_sw, M_jr, M_beq;
    wire [4:0] M_rs, M_rt, M_rd;
    InstrSet M_InstrSet (.Instr(M_Instr), .Ical(M_Ical), .Rcal(M_Rcal), .jal(M_jal), .lw(M_lw), .sw(M_sw), .jr(M_jr), .beq(M_beq));
    assign M_rs = M_Instr[`rs];
    assign M_rt = M_Instr[`rt];
    assign M_rd = M_Instr[`rd];

    //-----------W level-----------//
    wire W_Ical, W_Rcal, W_jal, W_lw, W_sw, W_jr, W_beq;
    wire [4:0] W_rs, W_rt, W_rd;
    InstrSet W_InstrSet (.Instr(W_Instr), .Ical(W_Ical), .Rcal(W_Rcal), .jal(W_jal), .lw(W_lw), .sw(W_sw), .jr(W_jr), .beq(W_beq));

    //------------Tuse------------//
    wire [1:0] D_Tuse_rs, D_Tuse_rt;
    assign D_Tuse_rs = (D_beq || D_jr) ? 0 :
                       (D_Rcal || D_Ical || D_lw || D_sw) ? 1 :
                                                            2;
    assign D_Tuse_rt = D_beq ? 0 :
                       D_Rcal ? 1 :
                       D_sw ? 2 :
                              3;  

    //------------Tnew------------//    
    //E level
    wire [1:0] E_Tnew = (E_Rcal || E_Ical) ?  1 :
                        (E_lw) ? 2 :
                                 0;
    //M level    
    wire [1:0] M_Tnew = (M_lw) ? 1 : 0;                                                                                            

    //-----------Stall------------//
    //stall wire
    wire rs_Stall, rt_Stall;
    wire stallYes;
    assign stallYes = rs_Stall || rt_Stall;
    assign F_Stall = stallYes;
    assign D_Stall = stallYes;
    assign E_Flush = stallYes;
    
    //stall logic
    assign rs_Stall = ((D_rs == E_for_GRFWriteAddr) && D_rs && (D_Tuse_rs < E_Tnew)) ||             //E_level
                      ((D_rs == M_for_GRFWriteAddr) && D_rs && (D_Tuse_rs < M_Tnew));               //M_level

    assign rt_Stall = ((D_rt == E_for_GRFWriteAddr) && D_rt && (D_Tuse_rt < E_Tnew)) ||             //E_level
                      ((D_rt == M_for_GRFWriteAddr) && D_rt && (D_Tuse_rt < M_Tnew));               //M_level

    //forward MUX
    assign D_Sel_rs = (E_jal && (D_rs == E_for_GRFWriteAddr)) ? 1 :                                 //E_jal   
                      (M_jal && (D_rs == M_for_GRFWriteAddr)) ? 2 :                                 //M_jal
                      ((M_Rcal || M_Ical) && (D_rs == M_for_GRFWriteAddr) && D_rs) ? 3 :            //M_Rcal, M_Ical
                                                                                     0;
    assign D_Sel_rt = (E_jal && (D_rt == E_for_GRFWriteAddr)) ? 1 :                                 //E_jal
                      (M_jal && (D_rt == M_for_GRFWriteAddr)) ? 2 :                                 //M_jal
                      ((M_Rcal || M_Ical) && (D_rt == M_for_GRFWriteAddr) && D_rt) ? 3 :            //M_Rcal, M_Ical
                                                                                     0;
    assign E_Sel_rs = (M_jal && (E_rs == M_for_GRFWriteAddr)) ? 1 :                                 //M_jal
                      ((M_Ical || M_Rcal) && (E_rs == M_for_GRFWriteAddr) && E_rs) ? 2 :            //M_Rcal, M_Ical
                      (W_jal && (E_rs == W_GRFWriteAddr)) ? 3 :                                     //W_jal
                      ((W_lw || W_Ical || W_Rcal) && (E_rs == W_GRFWriteAddr) && E_rs) ? 4 :        //W_lw, W_Ical, W_Rcal
                                                                                         0;
    assign E_Sel_rt = (M_jal && (E_rt == M_for_GRFWriteAddr)) ? 1 :                                 //M_jal
                      ((M_Ical || M_Rcal) && (E_rt == M_for_GRFWriteAddr) && E_rt) ? 2 :            //M_Rcal, M_Ical
                      (W_jal && (E_rt == W_GRFWriteAddr)) ? 3 :                                     //W_jal
                      ((W_lw || W_Ical || W_Rcal) && (E_rt == W_GRFWriteAddr) && E_rt) ? 4 :        //W_lw, W_Ical, W_Rcal
                                                                                         0;
    assign M_Sel_rt = (W_jal && (M_rt == W_GRFWriteAddr)) ? 1 :                                     //W_jal
                      ((W_lw || W_Ical || W_Rcal) && (M_rt == W_GRFWriteAddr) && M_rt) ? 2 :        //W_lw, W_Ical, W_Rcal
                                                                                         0;

endmodule
