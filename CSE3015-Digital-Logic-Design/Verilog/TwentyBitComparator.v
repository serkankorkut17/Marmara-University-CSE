`include "FourBitComparator.v"

module TwentyBitComparator(A, B, Lt, Gt, Eq);
    
    input [19:0] A;
    input [19:0] B;
    output Lt, Gt, Eq;

    wire LtIn1, GtIn1, EqIn1;
    wire LtIn2, GtIn2, EqIn2;
    wire LtIn3, GtIn3, EqIn3;
    wire LtIn4, GtIn4, EqIn4;
    
    FourBitComparator fc1 (1'b0, 1'b0, 1'b1, A[19:16], B[19:16], LtIn1, GtIn1, EqIn1);
    FourBitComparator fc2 (LtIn1, GtIn1, EqIn1, A[15:12], B[15:12], LtIn2, GtIn2, EqIn2);
    FourBitComparator fc3 (LtIn2, GtIn2, EqIn2, A[11:8], B[11:8], LtIn3, GtIn3, EqIn3);
    FourBitComparator fc4 (LtIn3, GtIn3, EqIn3, A[7:4], B[7:4], LtIn4, GtIn4, EqIn4);
    FourBitComparator fc5 (LtIn4, GtIn4, EqIn4, A[3:0], B[3:0], Lt, Gt, Eq);

endmodule
