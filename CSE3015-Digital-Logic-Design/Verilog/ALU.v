`include "TwentyBitComparator.v"
`include "TwentyBitAdder.v"

module ALU(in1, in2, opCode, EqualFlag, result);
    input [19:0] in1;
    input [19:0] in2;
    input [2:0] opCode;

    output EqualFlag;
    output reg [19:0] result;
    TwentyBitComparator tbc (in1, in2, lt, gt, EqualFlag);

    wire selAnd1, selAnd2, selAnd3;
    assign selAnd1 = opCode[0] & opCode[1] & ~opCode[2];
    assign selAnd2 = ~opCode[0] & ~opCode[1] & opCode[2];
    assign selAnd3 = ~opCode[0] & opCode[1] & ~opCode[2];

    wire [1:0] selOr;
    assign selOr[1] = selAnd1 | selAnd2;
    assign selOr[0] = selAnd2 | selAnd3;

    reg [19:0] newIn2;
    always @ (in2 or opCode[0]) begin  
        case (opCode[0])  
            1'b0 : newIn2 <= in2;  
            1'b1 : newIn2 <= ~in2;  
        endcase  
    end
    wire [19:0] in2_2 = newIn2;
    wire [19:0] muxInput0;
    wire [19:0] muxInput1;
    wire [19:0] muxInput2;
    wire [19:0] muxInput3;
    TwentyBitAdder tba (opCode[0], in1, in2_2, muxInput0, Cout);
    assign muxInput1 = in1 & in2;
    assign muxInput2 = in1 | in2;
    assign muxInput3 = (~in1 & in2) | (in1 & ~in2);

    always @ (muxInput0 or muxInput1 or muxInput2 or muxInput3 or selOr) begin  
        case (selOr)  
            2'b00 : result <= muxInput0;  
            2'b01 : result <= muxInput1;  
            2'b10 : result <= muxInput2;  
            2'b11 : result <= muxInput3;  
        endcase  
    end
endmodule
