`timescale 1ns/1ns
`include "FourBitComparator.v"

module FourBitComparator_tb;
    reg LtIn;
    reg GtIn;
    reg EqIn;
    
    reg [3:0] A;
    reg [3:0] B;

    wire Lt;
    wire Gt;
    wire Eq;
    FourBitComparator uut(LtIn, GtIn, EqIn, A, B, Lt, Gt, Eq);

    initial begin
        $dumpfile("FourBitComparator.vcd");
        $dumpvars(0, FourBitComparator_tb);
        
        LtIn = 0;
        GtIn = 0;
        EqIn = 1;
        A = 4'b0000;
        B = 4'b0000;
        #20;

        LtIn = 0;
        GtIn = 0;
        EqIn = 1;
        A = 4'b0001;
        B = 4'b0000;
        #20;

        LtIn = 0;
        GtIn = 0;
        EqIn = 1;
        A = 4'b0000;
        B = 4'b0001;
        #20;

        LtIn = 1;
        GtIn = 0;
        EqIn = 0;
        A = 4'b0001;
        B = 4'b0000;
        #20;

        LtIn = 0;
        GtIn = 1;
        EqIn = 0;
        A = 4'b0000;
        B = 4'b0001;
        #20;
        $display("test completed");
    end
endmodule