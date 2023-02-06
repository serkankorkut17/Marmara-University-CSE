`timescale 1ns/1ns
`include "TwentyBitAdder.v"

module TwentyBitAdder_tb;
    reg Cin;
    reg [19:0] A;
    reg [19:0] B;

    wire [19:0] Sum;
    wire Cout;

    TwentyBitAdder uut(Cin, A, B, Sum, Cout);

    initial begin
        $dumpfile("TwentyBitAdder.vcd");
        $dumpvars(0, TwentyBitAdder_tb);

        Cin = 0;
        A = 20'b00000000000000000001;
        B = 20'b00000000000000000000;
        #20;

        Cin = 0;
        A = 20'b00000000001111111111;
        B = 20'b11111111110000000000;
        #20;

        Cin = 0;
        A = 20'b11111111111111111111;
        B = 20'b00000000000000000001;
        #20;

        Cin = 0;
        A = 20'b00000000001111111111;
        B = 20'b00000000001111111111;
        #20;

        Cin = 1;
        A = 20'b11111111111111111111;
        B = 20'b00000000000000000000;
        #20;

        $display("test completed");
    end
endmodule