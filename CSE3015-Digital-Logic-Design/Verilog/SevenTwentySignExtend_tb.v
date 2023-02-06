`timescale 1ns/1ns
`include "SevenTwentySignExtend.v"

module SevenTwentySignExtend_tb;
    reg [6:0] A;
    wire [19:0] ExtendedA;

    SevenTwentySignExtend uut(A, ExtendedA);

    initial begin
        $dumpfile("SevenTwentySignExtend.vcd");
        $dumpvars(0, SevenTwentySignExtend_tb);

        A = 7'b0000001;
        #20;

        A = 7'b1000000;
        #20;

        A = 7'b1111111;
        #20;

        A = 7'b0011111;
        #20;

        A = 7'b1010101;
        #20;

        $display("test completed");
    end
endmodule