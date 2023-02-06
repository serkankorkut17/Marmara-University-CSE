module DLatch(D, Clock, Q);
    input D;
    input Clock;

    output Q;

    wire and1, and2, notD;
    not(notD, D);
    assign and1 = notD & Clock;
    assign and2 = D & Clock;

    wire nor1, nor2;

    nor(nor1, and1, nor2);
    nor(nor2, and2, nor1);

    assign Q = nor1;

endmodule
