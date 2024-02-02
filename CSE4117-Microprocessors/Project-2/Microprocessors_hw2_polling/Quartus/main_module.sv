module main_module( input clk,
                        //---input from buttons
                        input  enter_key_left,              //enter button left
								input  enter_key_right,              //enter button right
                        //---output to seven segment display
                        output logic [3:0] grounds,
                        output logic [6:0] display
                        );
								
//memory map is defined here
localparam    BEGINMEM=12'h000,
                  ENDMEM=12'h7ff,
						READY_BUTTON_LEFT_DATA = 12'h800,
						READY_BUTTON_LEFT_STATUS = 12'h801,
						READY_BUTTON_RIGHT_DATA = 12'h900,
						READY_BUTTON_RIGHT_STATUS = 12'h901,
                  SEVENSEG=12'hb00;

//  memory chip
logic [15:0] memory [0:255]; 
 
// cpu's input-output pins
logic [15:0] data_out;
logic [15:0] data_in;
logic [11:0] address;
logic memwt;

//======ss7 and switchbank=====
logic [15:0] ss7_out, btnleft_in, btnright_in;
//logic ack_left, ack_right;
logic ackx, ackx2;

sevensegment ss1(.datain(ss7_out),.grounds(grounds),.display(display),.clk(clk));
button_poll btnleft(.clk(clk), .enter_key(enter_key_left), .a0(address[0]), .ack(ackx), .data_out(btnleft_in));
button_poll btnright(.clk(clk), .enter_key(enter_key_right), .a0(address[0]), .ack(ackx2), .data_out(btnright_in));
bird br1 (.clk(clk),.data_in(data_in), .data_out(data_out),.address(address),.memwt(memwt));

//multiplexer for cpu input
always_comb
begin
		ackx = 0;
		ackx2 = 0;
		if ( (BEGINMEM<=address) && (address<=ENDMEM) )
			begin
				data_in=memory[address];
			end
		else if ((address==READY_BUTTON_LEFT_DATA)|| (address==READY_BUTTON_LEFT_STATUS))
			begin
				ackx = 1;              //with appropriate a0 resets the ready flag    
				data_in = btnleft_in;   //a0 will determine if we read data or status
			end
		else if ((address==READY_BUTTON_RIGHT_DATA)|| (address==READY_BUTTON_RIGHT_STATUS))
			begin
				ackx2 = 1;              //with appropriate a0 resets the ready flag    
				data_in = btnright_in;   //a0 will determine if we read data or status
			end
		else
			begin
				data_in=16'hf345; //any number
			end
end

//multiplexer for cpu output 
always_ff @(posedge clk) //data output port of the cpu
    if (memwt)
        if ( (BEGINMEM<=address) && (address<=ENDMEM) )
            memory[address]<=data_out;
        else if ( SEVENSEG==address) 
            ss7_out<=data_out;
            
initial 
    begin
        ss7_out=0;
        $readmemh("ram.dat", memory);
    end
endmodule