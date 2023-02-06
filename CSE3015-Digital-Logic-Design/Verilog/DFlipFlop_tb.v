`include "DFlipFlop.v"

module DFlipFlop_tb;
    reg D;
    reg Clock;
    reg Enable;

    wire Q;

    DFlipFlop uut(D, Clock, Enable, Q);

    initial begin
        $dumpfile("DFlipFlop.vcd");
        $dumpvars(0, DFlipFlop_tb);

        D = 0;
        Clock = 0;
        Enable = 0;
        #20;

        D = 0;
        Clock = 0;
        Enable = 1;
        #20;

        D = 0;
        Clock = 1;
        Enable = 1;
        #20;

        D = 1;
        Clock = 1;
        Enable = 1;
        #20;

        D = 1;
        Clock = 0;
        Enable = 1;
        #20;

        D = 1;
        Clock = 1;
        Enable = 1;
        #20;

        D = 0;
        Clock = 1;
        Enable = 0;
        #20;

        D = 0;
        Clock = 1;
        Enable = 1;
        #20;

        D = 0;
        Clock = 1;
        Enable = 1;
        #20;

        D = 0;
        Clock = 0;
        Enable = 1;
        #20;

        D = 0;
        Clock = 1;
        Enable = 1;
        #20;

        $display("test completed");
    end
endmodule