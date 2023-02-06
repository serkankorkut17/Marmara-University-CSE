`timescale 1ns/1ns
`include "FullComparator.v"

module FullComparator_tb;
    reg LtIn;
    reg GtIn;
    reg EqIn;
    reg A;
    reg B;

    wire Lt;
    wire Gt;
    wire Eq;
    FullComparator uut(LtIn, GtIn, EqIn, A, B, Lt, Gt, Eq);

    initial begin
        $dumpfile("FullComparator.vcd");
        $dumpvars(0, FullComparator_tb);

        LtIn = 1;
        GtIn = 0;
        EqIn = 0;
        A = 1;
        B = 0;
        #20;

        LtIn = 0;
        GtIn = 1;
        EqIn = 0;
        A = 0;
        B = 1;
        #20;

        LtIn = 0;
        GtIn = 0;
        EqIn = 1;
        A = 0;
        B = 0;
        #20;

        LtIn = 0;
        GtIn = 0;
        EqIn = 1;
        A = 1;
        B = 0;
        #20;

        LtIn = 0;
        GtIn = 0;
        EqIn = 1;
        A = 0;
        B = 1;
        #20;

        LtIn = 0;
        GtIn = 0;
        EqIn = 1;
        A = 1;
        B = 1;
        #20;

        $display("test completed");
    end
endmodule