module seven_segment(grounds, display, dp, clk, btnleft, btnright);

output logic [3:0] grounds;
output logic [6:0] display;
output logic dp;
input clk; 
input wire btnleft;
input wire btnright;

logic [3:0] data [3:0] ; //number to be printed on display
logic [1:0] count;       //which data byte to display.
logic [25:0] clk1;
logic [1:0] mode = 0;
logic btnleft_old;
logic btnright_old;


always_ff @(posedge (mode==0 ? clk1[15]: (mode==1 ? clk1[19]: (mode==2 ? clk1[25]: clk1[15]))))    //25 slow //19 wavy //15 perfect
begin
    grounds<={grounds[2:0],grounds[3]};
    count<=count+1;              //which hex digit to display
end


always_ff @(posedge clk)
begin
		 btnleft_old<=btnleft;
		 btnright_old<=btnright;
		 clk1<=clk1+1;
		 
		 // Left Button
		 if (btnleft_old == 1'b1 & btnleft == 1'b0)
		 begin
				 if (data[3] != 4'hf)
				 begin
						data[3] <= data[3] + 1;
				 end
				 else if (data[2] != 4'hf)
				 begin
						data[3] <= 0;
						data[2] <= data[2] + 1;
				 end
				 else if (data[1] != 4'hf)
				 begin
						data[3] <= 0;
						data[2] <= 0;
						data[1] <= data[1] + 1;
				 end
				 else if (data[0] != 4'hf)
				 begin
						data[3] <= 0;
						data[2] <= 0;
						data[1] <= 0;
						data[0] <= data[0] + 1;
				 end
				 else
				 begin
						data[0] <= 0;
						data[1] <= 0;
						data[2] <= 0;
						data[3] <= 0;
				 end
		 end
		 
		 //Right Button
		 if (btnright_old == 1'b1 & btnright == 1'b0)
		 begin
				 if (mode == 2) 
						mode = 0;
				 else
						mode<=mode+1;
		 end	 
end

	 
	 
always_comb
    case(data[count])
        0:display=7'b1111110; //starts with a, ends with g
        1:display=7'b0110000;
        2:display=7'b1101101;
        3:display=7'b1111001;
        4:display=7'b0110011;
        5:display=7'b1011011;
        6:display=7'b1011111;
        7:display=7'b1110000;
        8:display=7'b1111111;
        9:display=7'b1111011;
        'ha:display=7'b1110111;
        'hb:display=7'b0011111;
        'hc:display=7'b1001110;
        'hd:display=7'b0111101;
        'he:display=7'b1001111;
		  'hf:display=7'b1000111;
        default display=7'b1111111;
    endcase
initial begin
    data[0]=4'hf;
    data[1]=4'h7;
    data[2]=4'ha;
    data[3]=4'h2;
    count = 2'b0;
    grounds=4'b1110;
    clk1=0;
	 dp = 0;
end
endmodule