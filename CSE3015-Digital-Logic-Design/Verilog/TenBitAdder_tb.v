`timescale 1ns/1ns
`include "TenBitAdder.v"

module TenBitAdder_tb;
    reg [9:0] A;
    reg [9:0] B;

    wire [9:0] Sum;

    TenBitAdder uut(A, B, Sum);

    initial begin
        $dumpfile("TenBitAdder.vcd");
        $dumpvars(0, TenBitAdder_tb);

        A = 20'b0000000001;
        B = 20'b0000000000;
        #20;

        A = 20'b0000011111;
        B = 20'b1111100000;
        #20;

        A = 20'b1111111111;
        B = 20'b0000000001;
        #20;

        A = 20'b0000011111;
        B = 20'b0000011111;
        #20;

        A = 20'b1111111111;
        B = 20'b0000000000;
        #20;

        $display("test completed");
    end
endmodule