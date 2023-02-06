`timescale 1ns/1ns
`include "FourBitAdder.v"

module FourBitAdder_tb;
    reg Cin;
    reg [3:0] A;
    reg [3:0] B;

    wire [3:0] Sum;
    wire Cout;

    FourBitAdder uut(Cin, A, B, Sum, Cout);

    initial begin
        $dumpfile("FourBitAdder.vcd");
        $dumpvars(0, FourBitAdder_tb);

        Cin = 0;
        A = 4'b0001;
        B = 4'b0000;
        #20;

        Cin = 0;
        A = 4'b0011;
        B = 4'b1100;
        #20;

        Cin = 0;
        A = 4'b1111;
        B = 4'b0001;
        #20;

        Cin = 0;
        A = 4'b0011;
        B = 4'b0011;
        #20;

        Cin = 1;
        A = 4'b1111;
        B = 4'b0000;
        #20;

        $display("test completed");
    end
endmodule