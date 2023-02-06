
module FullComparator(LtIn, GtIn, EqIn, A, B, Lt, Gt, Eq);
    input LtIn, GtIn, EqIn, A, B;
    output Lt, Gt, Eq;
    wire notA, notB, and1, and2, and3, and4;
    
    not(notA, A);
    not(notB, B);

    assign and1 = EqIn & notA & B; 
    assign and2 = EqIn & A & notB; 
    assign and3 = EqIn & A & B; 
    assign and4 = EqIn & notA & notB; 
    
    assign Lt = LtIn | and1;
    assign Gt = GtIn | and2;
    assign Eq = and3 | and4;
endmodule
