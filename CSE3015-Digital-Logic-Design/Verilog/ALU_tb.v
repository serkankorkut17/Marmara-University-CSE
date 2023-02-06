`timescale 1ns/1ns
`include "ALU.v"

module ALU_tb;
    reg [19:0] in1;
    reg [19:0] in2;
    reg [2:0] opCode;

    wire EqualFlag;
    wire [19:0] result;

    ALU uut(in1, in2, opCode, EqualFlag, result);

    initial begin
        $dumpfile("ALU.vcd");
        $dumpvars(0, ALU_tb);

        in1 = 20'b00000000000011111111;
        in2 = 20'b00000000000011111111;
        opCode = 3'b000;
        #10;

        in1 = 20'b00000000000011111111;
        in2 = 20'b00000000000001010101;
        opCode = 3'b000;
        #10;

        in1 = 20'b00000000000011111111;
        in2 = 20'b00000000000001010101;
        opCode = 3'b001;
        #10;

        in1 = 20'b00000000000011111111;
        in2 = 20'b00000000000001010101;
        opCode = 3'b010;
        #10;

        in1 = 20'b00000000000011111111;
        in2 = 20'b00000000000001010101;
        opCode = 3'b011;
        #10;

        in1 = 20'b00000000000011111111;
        in2 = 20'b00000000000001010101;
        opCode = 3'b100;
        #10;

        in1 = 20'b00000000000011111111;
        in2 = 20'b00000000000001010101;
        opCode = 3'b101;
        #10;

        in1 = 20'b00000000000011111111;
        in2 = 20'b00000000000001010101;
        opCode = 3'b110;
        #10;

        in1 = 20'b00000000000011111111;
        in2 = 20'b00000000000001010101;
        opCode = 3'b111;
        #10;

        $display("test completed");
    end
endmodule