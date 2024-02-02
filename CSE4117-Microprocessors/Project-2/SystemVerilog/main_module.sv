module main_module (
                        input clk,
                        //---input from buttons
                        input  enter_key_left,              //enter button left
					 			input  enter_key_right,              //enter button right
                        //---output to seven segment display
                        output logic [3:0] grounds,
                        output logic [6:0] display
                   );

//====memory map is defined here====
localparam    BEGINMEM = 12'h000,
              ENDMEM = 12'h7ff,
				  READY_BUTTON_LEFT_DATA = 12'h800,
				  READY_BUTTON_LEFT_STATUS = 12'h801,
				  READY_BUTTON_RIGHT = 12'h900,
              SEVENSEG = 12'hb00;

//====memory chip==============
logic [15:0] memory [0:255]; 
 
//=====cpu's input-output pins=====
logic [15:0] data_out;
logic [15:0] data_in;
logic [11:0] address;
logic memwt;
logic INT;    //interrupt pin
logic intack; //interrupt acknowledgement
//logic button_right_interrupt;
//logic button_left_interrupt;
logic ackx, ackx2;

//======ss7 and switchbank=====
logic [15:0] ss7_out, btnleft_in, btnright_in;
//====== pic ===============
logic irq0, irq1, irq2, irq3, irq4, irq5, irq6, irq7;

//=====components==================
sevensegment ss1 (.datain(ss7_out), .grounds(grounds), .display(display), .clk(clk));
button_poll btnleft(.clk(clk), .enter_key(enter_key_left), .a0(address[0]), .ack(ackx), .data_out(btnleft_in));
button_int  btnright(.clk(clk), .enter_key(enter_key_right),  .ack(ackx2) , .interrupt(button_right_interrupt),.data_reg(btnright_in));
mammal m1( .clk(clk), .data_in(data_in), .data_out(data_out), .address(address), .memwt(memwt),.INT(INT), .intack(intack));

//===============IRQ's==============
always_comb
    begin
      irq0 = 1'b0;
      irq1 = 1'b0;
      irq2 = button_right_interrupt;
      irq3 = 1'b0;
      irq4 = 1'b0;
      irq5 = 1'b0;
      irq6 = 1'b0;
      irq7 = 1'b0;
   end
//we assume that the devices hold their irq until being serviced by cpu
assign INT = irq0 | irq1 | irq2 | irq3 | irq4 | irq5 | irq6 | irq7;

//====multiplexer for cpu input======
always_comb
begin
ackx = 0;
ackx2 = 0;
        if (intack == 0)
		  begin
            ackx = 0;
				ackx2 = 0;
            if ( (BEGINMEM<=address) && (address<=ENDMEM) )
                    data_in=memory[address];
				else if ((address==READY_BUTTON_LEFT_DATA)|| (address==READY_BUTTON_LEFT_STATUS))
					begin
						ackx = 1;              //with appropriate a0 resets the ready flag    
						data_in = btnleft_in;   //a0 will determine if we read data or status
					end
				else if (address==READY_BUTTON_RIGHT)
					begin
						ackx2 = 1;              //with appropriate a0 resets the ready flag    
						data_in = btnright_in;   //a0 will determine if we read data or status
					end
				else
					begin
						data_in=16'hf345; //any number
					end
			end
         else                        //intack = 1
            begin
             if (irq0)               //highest priority interrupt is irq0
                 data_in = 16'h0;
             else if (irq1)
                 data_in = 16'h1;
             else if (irq2)
                 data_in = 16'h2;
             else if (irq3)
                 data_in = 16'h3;
             else if (irq4)
                 data_in = 16'h4;
             else if (irq5)
                 data_in = 16'h5;
             else if (irq6)
                 data_in = 16'h6;
             else                           //  irq7 
                 data_in = 16'h7;
            end
end

//=====multiplexer for cpu output=========== 
always_ff @(posedge clk) //data output port of the cpu
begin
    if (memwt)
        if ( (BEGINMEM<=address) && (address<=ENDMEM) )
               memory[address]<=data_out;
        else if ( SEVENSEG==address ) 
               ss7_out<=data_out;
end
					

initial 
    begin
         button_right_interrupt = 0;
         ss7_out = 16'b0;
        $readmemh("ram.dat", memory);
    end
endmodule