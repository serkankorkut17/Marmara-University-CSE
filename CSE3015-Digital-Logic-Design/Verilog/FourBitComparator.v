`include "FullComparator.v"

module FourBitComparator(LtIn, GtIn, EqIn, A, B, Lt, Gt, Eq);
    
    input LtIn, GtIn, EqIn;
    input [3:0] A;
    input [3:0] B;
    output Lt, Gt, Eq;
    
    wire LtIn1, GtIn1, EqIn1;
    wire LtIn2, GtIn2, EqIn2;
    wire LtIn3, GtIn3, EqIn3;
    
    FullComparator fc1 (LtIn, GtIn, EqIn, A[3], B[3], LtIn1, GtIn1, EqIn1);
    FullComparator fc2 (LtIn1, GtIn1, EqIn1, A[2], B[2], LtIn2, GtIn2, EqIn2);
    FullComparator fc3 (LtIn2, GtIn2, EqIn2, A[1], B[1], LtIn3, GtIn3, EqIn3);
    FullComparator fc4 (LtIn3, GtIn3, EqIn3, A[0], B[0], Lt, Gt, Eq);

endmodule
