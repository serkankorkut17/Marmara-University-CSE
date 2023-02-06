
module FullAdder(Cin, A, B, Sum, Cout);
    input Cin, A, B;
    output Sum, Cout;
    wire xor1, and1, and2, or1;
    
    assign xor1 = (~A & B) | (A & ~B);
    assign Sum = (~xor1 & Cin) | (xor1 & ~Cin);
    
    assign and1 = Cin & xor1;
    assign and2 = A & B;
    
    assign Cout = and1 | and2;
endmodule
