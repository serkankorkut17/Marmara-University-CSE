`include "FourBitAdder.v"

module TwentyBitAdder(Cin, A, B, Sum, Cout);
    input Cin;
    input [19:0] A;
    input [19:0] B;

    output [19:0] Sum;
    output Cout;

    wire Cout0, Cout1, Cout2, Cout3;

    FourBitAdder fa1 (Cin, A[3:0], B[3:0], Sum[3:0], Cout0);
    FourBitAdder fa2 (Cout0, A[7:4], B[7:4], Sum[7:4], Cout1);
    FourBitAdder fa3 (Cout1, A[11:8], B[11:8], Sum[11:8], Cout2);
    FourBitAdder fa4 (Cout2, A[15:12], B[15:12], Sum[15:12], Cout3);
    FourBitAdder fa5 (Cout3, A[19:16], B[19:16], Sum[19:16], Cout);
endmodule
