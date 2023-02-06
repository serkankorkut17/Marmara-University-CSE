`timescale 1ns/1ns
`include "FullAdder.v"

module FullAdder_tb;
    reg A;
    reg B;
    reg Cin;

    wire Sum;
    wire Cout;
    FullAdder uut(Cin, A, B, Sum, Cout);

    initial begin
        $dumpfile("FullAdder.vcd");
        $dumpvars(0, FullAdder_tb);

        A = 0;
        B = 0;
        Cin = 0;
        #20;

        A = 1;
        B = 0;
        Cin = 0;
        #20;

        A = 0;
        B = 1;
        Cin = 0;
        #20;

        A = 1;
        B = 1;
        Cin = 0;
        #20;

        A = 0;
        B = 0;
        Cin = 1;
        #20;

        A = 1;
        B = 1;
        Cin = 1;
        #20;

        $display("test completed");
    end
endmodule