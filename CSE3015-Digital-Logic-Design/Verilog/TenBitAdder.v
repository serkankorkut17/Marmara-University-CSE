`include "FourBitAdder.v"

module TenBitAdder(A, B, Sum);

    input [9:0] A;
    input [9:0] B;

    wire [11:0] extendedA;
    wire [11:0] extendedB;
    assign extendedA = { {2{A[9]}}, A };
    assign extendedB = { {2{B[9]}}, B };

    wire [12:0] Sum1;
    output [9:0] Sum;

    wire Cout0, Cout1, Cout2;

    FourBitAdder fa1 (1'b0, A[3:0], B[3:0], Sum1[3:0], Cout0);
    FourBitAdder fa2 (Cout0, A[7:4], B[7:4], Sum1[7:4], Cout1);
    FourBitAdder fa3 (Cout1, extendedA[11:8], extendedB[11:8], Sum1[11:8], Cout2);

    assign Sum = Sum1[9:0];

endmodule
