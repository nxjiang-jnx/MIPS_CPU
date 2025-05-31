`timescale 1ns / 1ps

`include "def.v"

module mips(
    input clk,
    input reset
    );

    //---------hazard unit---------//
    wire [31:0] D_Instr, E_Instr, M_Instr, W_Instr;
    wire [4:0] E_for_GRFWriteAddr, M_for_GRFWriteAddr, W_GRFWriteAddr;
    wire [2:0] D_Sel_rs, D_Sel_rt, E_Sel_rs, E_Sel_rt, M_Sel_rt;
    wire F_Stall, D_Stall, E_Flush;
    hazardUnit _hazardUnit (.D_Instr(D_Instr), .E_Instr(E_Instr), .M_Instr(M_Instr), .W_Instr(W_Instr), .E_for_GRFWriteAddr(E_for_GRFWriteAddr), .M_for_GRFWriteAddr(M_for_GRFWriteAddr), .W_GRFWriteAddr(W_GRFWriteAddr), .F_Stall(F_Stall), .D_Stall(D_Stall), .E_Flush(E_Flush), .D_Sel_rs(D_Sel_rs), .D_Sel_rt(D_Sel_rt), .E_Sel_rs(E_Sel_rs), .E_Sel_rt(E_Sel_rt), .M_Sel_rt(M_Sel_rt));

    //-----------F level-----------//
    wire [31:0] F_PC, F_NPC, F_Instr, 
                D_for_rs;
    wire [2:0] F_NPCOp;
    //pc
    pc _pc (.NPC(F_NPC), .clk(clk), .reset(reset), .F_Stall(F_Stall), .PC(F_PC));
    //npc
    npc _npc (.PC(F_PC), .RA(D_for_rs), .Imm(D_Instr[`Imm26]), .NPCOp(F_NPCOp), .NPC(F_NPC));
    //im
    im _im (.PC(F_PC), .Instr(F_Instr));

    //-----------D level-----------//
    wire [31:0] D_PC, D_RD1, D_RD2, D_EXTResult, D_for_rt,
                E_PC, 
                M_ALUResult, M_PC, 
                W_GRFWriteData, W_PC;
    wire D_EXTOp, D_Zero,
         W_RFWr;
    //hazard mux
    assign D_for_rs = (D_Sel_rs == 1) ? E_PC + 8 :
                      (D_Sel_rs == 2) ? M_PC + 8 :
                      (D_Sel_rs == 3) ? M_ALUResult : 
                                        D_RD1;
    assign D_for_rt = (D_Sel_rt == 1) ? E_PC + 8 :
                      (D_Sel_rt == 2) ? M_PC + 8 :
                      (D_Sel_rt == 3) ? M_ALUResult : 
                                        D_RD2;
    //cmp
    assign D_Zero = (D_for_rs == D_for_rt) ? 1'b1 : 1'b0;
    //fd_reg
    FD_reg _fd_reg (.clk(clk), .reset(reset), .D_Stall(D_Stall), .F_Instr(F_Instr), .F_PC(F_PC), .D_Instr(D_Instr), .D_PC(D_PC));
    //grf
    grf _grf (.clk(clk), .reset(reset), .W_RFWr(W_RFWr), .A1(D_Instr[`rs]), .A2(D_Instr[`rt]), .A3(W_GRFWriteAddr), .WD(W_GRFWriteData), .W_PC(W_PC), .RD1(D_RD1), .RD2(D_RD2));
    //ext
    ext _ext (.in(D_Instr[`Imm16]), .D_EXTOp(D_EXTOp), .out(D_EXTResult));
    //D_ctrl
    control D_CTRL (.opcode(D_Instr[`opcode]), .funct(D_Instr[`funct]), .Zero(D_Zero), .NPCOp(F_NPCOp), .EXTOp(D_EXTOp));

    //-----------E level-----------//
    wire [31:0] E_for_rs, E_for_rt, E_EXTResult, E_RD1, E_RD2, E_ALUResult, E_ALUB;
    wire [2:0] E_ALUOp;
    wire [1:0] E_A3WRSel;
    wire E_ALUBSel;
    //hazard mux
    assign E_for_rs = (E_Sel_rs == 1) ? M_PC + 8 :
                      (E_Sel_rs == 2) ? M_ALUResult :
                      (E_Sel_rs == 3) ? W_PC + 8 :
                      (E_Sel_rs == 4) ? W_GRFWriteData :
                                        E_RD1;
    assign E_for_rt = (E_Sel_rt == 1) ? M_PC + 8 :
                      (E_Sel_rt == 2) ? M_ALUResult :
                      (E_Sel_rt == 3) ? W_PC + 8 :
                      (E_Sel_rt == 4) ? W_GRFWriteData :
                                        E_RD2;                                        
    //ALUBSel mux
    assign E_ALUB = (E_ALUBSel == 1) ? E_EXTResult : E_for_rt;
    //A3WRSel mux
    assign E_for_GRFWriteAddr = (E_A3WRSel == 2'b00) ? E_Instr[`rt] :
                                (E_A3WRSel == 2'b01) ? E_Instr[`rd] :
                                (E_A3WRSel == 2'b10) ? 5'd31 :
                                5'b0;
    //de_reg
    DE_reg _de_reg (.D_PC(D_PC), .D_Imm32(D_EXTResult), .D_Instr(D_Instr), .D_RD1(D_for_rs), .D_RD2(D_for_rt), .clk(clk), .reset(reset || E_Flush), .E_PC(E_PC), .E_Imm32(E_EXTResult), .E_Instr(E_Instr), .E_RD1(E_RD1), .E_RD2(E_RD2));
    //alu
    alu _alu (.Op1(E_for_rs), .Op2(E_ALUB), .ALUOp(E_ALUOp), .result(E_ALUResult));
    //E_ctrl
    control E_CTRL (.opcode(E_Instr[`opcode]), .funct(E_Instr[`funct]), .ALUOp(E_ALUOp), .A3WRSel(E_A3WRSel), .ALUBSel(E_ALUBSel));

    //-----------M level-----------//
    wire [31:0] M_for_rt, M_RD, M_DMWD;
    wire M_DMWr;
    //hazard mux
    assign M_DMWD = (M_Sel_rt == 1) ? W_PC + 8 :
                    (M_Sel_rt == 2) ? W_GRFWriteData : 
                                      M_for_rt; 
    //em_reg
    EM_reg _em_reg (.clk(clk), .reset(reset), .E_PC(E_PC), .E_ALUResult(E_ALUResult), .E_Instr(E_Instr), .E_for_GRFWriteAddr(E_for_GRFWriteAddr), .E_for_rt(E_for_rt), .M_PC(M_PC), .M_ALUResult(M_ALUResult), .M_Instr(M_Instr), .M_for_GRFWriteAddr(M_for_GRFWriteAddr), .M_for_rt(M_for_rt));
    //dm
    dm _dm (.clk(clk), .reset(reset), .M_DMWr(M_DMWr), .M_PC(M_PC), .A(M_ALUResult), .WD(M_DMWD), .RD(M_RD));
    //M-ctrl
    control M_CTRL (.opcode(M_Instr[`opcode]), .funct(M_Instr[`funct]), .DMWr(M_DMWr));

    //-----------W level-----------//
    wire [31:0] W_ALUResult, W_RD;
    wire [1:0] W_WDSel;
    //WDSel mux
    assign W_GRFWriteData = (W_WDSel == 2'b00) ? W_ALUResult :
                            (W_WDSel == 2'b01) ? W_RD :
                            (W_WDSel == 2'b10) ? W_PC + 8 :
                            32'b0;
    //mw_reg
    MW_reg _mw_reg (.clk(clk), .reset(reset), .M_PC(M_PC), .M_Instr(M_Instr), .M_for_GRFWriteAddr(M_for_GRFWriteAddr), .M_ALUResult(M_ALUResult), .M_RD(M_RD), .W_PC(W_PC), .W_Instr(W_Instr), .W_for_GRFWriteAddr(W_GRFWriteAddr), .W_ALUResult(W_ALUResult), .W_RD(W_RD)); 
    //W_ctrl
    control W_CTRL (.opcode(W_Instr[`opcode]), .funct(W_Instr[`funct]), .WDSel(W_WDSel), .RFWr(W_RFWr));

endmodule