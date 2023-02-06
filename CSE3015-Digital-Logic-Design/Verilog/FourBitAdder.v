`include "FullAdder.v"

module FourBitAdder(Cin, A, B, Sum, Cout);
    input Cin;
    input [3:0] A;
    input [3:0] B;

    output [3:0] Sum;
    output Cout;

    wire Cout0, Cout1, Cout2;

    FullAdder fa1 (Cin, A[0], B[0], Sum[0], Cout0);
    FullAdder fa2 (Cout0, A[1], B[1], Sum[1], Cout1);
    FullAdder fa3 (Cout1, A[2], B[2], Sum[2], Cout2);
    FullAdder fa4 (Cout2, A[3], B[3], Sum[3], Cout);
endmodule
