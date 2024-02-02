module button_poll(
    input clk,
	 //--user side
    input enter_key,
	 //--cpu side
    input a0,
    input ack,
    output [15:0] data_out
);

   logic [1:0] pressed;
	logic [15:0] status_reg; 
	logic [15:0] data_reg ; 

    always_ff @(posedge clk)
    begin
        pressed <= {pressed[0],enter_key};
        if ((pressed == 2'b10) && (status_reg[0] == 1'b0))
        begin
             status_reg  <= 16'b1;
             data_reg    <= 16'h1111;
        end
        else if (ack && !a0)
        begin
             status_reg <= 16'b0;
        end
    end

    always_comb
    begin
        if (a0)
            data_out = status_reg;
        else
            data_out = data_reg;
    end

    //assign ack_sw = ack;

    initial begin
        status_reg = 16'b0;
    end
endmodule