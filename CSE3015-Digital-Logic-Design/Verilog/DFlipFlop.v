`include "DLatch.v"

module DFlipFlop(D, Clock, Enable, Q);
    input D;
    input Clock;
    input Enable;

    output Q;

    wire notClock, dlOutput1, dlOutput2;
    reg muxOutput;

    always @ (dlOutput2 or D or Enable) begin  
        case (Enable)  
            1'b0 : muxOutput <= dlOutput2;  
            1'b1 : muxOutput <= D;  
        endcase  
    end

    not(notClock, Clock);
    DLatch dl1 (muxOutput, notClock, dlOutput1);
    DLatch dl2 (dlOutput1, Clock, dlOutput2);

    assign Q = dlOutput2;

endmodule
