
module SevenTwentySignExtend(A, ExtendedA);

    input [6:0] A;
    output [19:0] ExtendedA;

    assign ExtendedA = { {13{A[6]}}, A };

endmodule
