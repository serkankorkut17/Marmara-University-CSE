`timescale 1ns/1ns
`include "TwentyBitComparator.v"

module TwentyBitComparator_tb;
    reg [19:0] A;
    reg [19:0] B;

    wire Lt;
    wire Gt;
    wire Eq;
    TwentyBitComparator uut(A, B, Lt, Gt, Eq);

    initial begin
        $dumpfile("TwentyBitComparator.vcd");
        $dumpvars(0, TwentyBitComparator_tb);
        

        A =20'b00000000000000000000;
        B =20'b00000000000000000000;
        #20;

        A =20'b00000000000000000001;
        B =20'b00000000000000000000;
        #20;

        A =20'b00000000000000000000;
        B =20'b00000000000000000001;
        #20;

        A =20'b00000000000000000000;
        B =20'b01111111111111111111;
        #20;

        A =20'b01111111111111111111;
        B =20'b00000000000000000000;
        #20;

        $display("test completed");
    end
endmodule