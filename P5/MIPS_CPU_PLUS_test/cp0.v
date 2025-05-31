`timescale 1ns / 1ps

module cp0(
    input clk,
    input reset,
    input en,
    input [4:0] CP0Add,     //to locate SR ? CAUSE ? EPC ?
    input [31:0] CP0In,     //CP0 input data 
    input [31:0] VPC,       //victim PC
    input [4:0] ExcCodeIn,  //exception type
    input EXLClr,           //reset EXL
    output [31:0] EPCOut,   //value of EPC
    output [31:0] CP0Out,   //CP0 output data
    output reg Req          //request to access exception, only when SR[1] == 0
    );

    //cp0 registers
    reg [31:0] SR;      //SR[1] = EXL
    reg [31:0] CAUSE;   //CAUSE[6:2] = ExcCode
    reg [31:0] EPC;     //PC to return 

    //initializing
    initial begin
        SR = 0;
        CAUSE = 0;
        EPC = 0;
		  Req = 0;
    end

    //exception request
    always @(posedge clk) begin
        if (reset) begin
            SR <= 0;
            CAUSE <= 0;
            EPC <= 0;
        end
        else if (EXLClr) begin           	  //exit exception    
            SR[1] <= 0;                  //clear EXL
        end
        else if (en) begin
            case (CP0Add)
                5'd12: SR <= CP0In;
                5'd13: CAUSE <= CP0In;
                5'd14: EPC <= CP0In;
                default: ;
            endcase
        end
        else if (Req) begin  //into exception
            SR[1] <= 1'b1;
            CAUSE[6:2] <= ExcCodeIn;
            EPC <= VPC;
        end
    end
	 
	 //Req combinational logic
	 always @(*) begin
        Req = ExcCodeIn && !SR[1];
	 end

    //output
    assign CP0Out = (CP0Add == 5'd12) ? SR :
                    (CP0Add == 5'd13) ? CAUSE :
                    (CP0Add == 5'd14) ? EPC :
                                        0;

    assign EPCOut = EPC;

endmodule
