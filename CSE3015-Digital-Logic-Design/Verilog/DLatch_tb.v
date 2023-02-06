`include "DLatch.v"

module DLatch_tb;
    reg D;
    reg Clock;

    wire Q;

    DLatch uut(D, Clock, Q);

    initial begin
        $dumpfile("DLatch.vcd");
        $dumpvars(0, DLatch_tb);

        D = 0;
        Clock = 0;
        #20;

        D = 0;
        Clock = 1;
        #20;

        D = 1;
        Clock = 1;
        #20;

        D = 1;
        Clock = 0;
        #20;

        D = 0;
        Clock = 0;
        #20;

        D = 0;
        Clock = 1;
        #20;

        $display("test completed");
    end
endmodule