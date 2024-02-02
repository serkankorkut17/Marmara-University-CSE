module main_module(	
	input clk, 
	input ps2c, 
	input ps2d,
	input pushbutton,
	output logic       hsync,
   output logic       vsync,
   output logic [2:0] rgb);
	
	
logic [3:0] keyout;
logic ack;
//memory map is defined here

localparam BEGINMEM=12'h000,
				ENDMEM=12'h0df;
	
localparam	KEYBOARD_CHK = 12'h0fc,
				KEYBOARD_DAT = 12'h0fd,
				SPACESHIP_X = 12'h0fe,
				SPACESHIP_Y = 12'h0ff,
				SPACESHIP_BITMAP_ADRESS_START = 12'h100,
				SPACESHIP_BITMAP_ADDRESS_END = 12'h10f,
				PLANET_X = 12'h1fe,
				PLANET_Y = 12'h1ff,
				PLANET_BITMAP_ADDRESS_START = 12'h200,
				PLANET_BITMAP_ADDRESS_END = 12'h20f;
				
// memory chip
logic [15:0] memory [0:255];


// cpu's input-output pins
logic [15:0] data_out;
logic [15:0] data_in;
logic [11:0] address;
logic memwt;
logic INT;    //interrupt pin
logic intack; //interrupt acknowledgement
logic vga_int;
logic vga_ack;
logic irq0, irq1, irq2, irq3, irq4, irq5, irq6, irq7;

logic [15:0] data_out_key;
logic [25:0] clk1;

logic [15:0] spaceship_x;
logic [15:0] spaceship_y;
logic [15:0] spaceship_bitmap [0:15];
logic [15:0] planet_x;
logic [15:0] planet_y;
logic [15:0] planet_bitmap [0:15];

vga_sync vga(.clk(clk),.hsync(hsync),.vsync(vsync),.rgb(rgb),.spaceship_x(spaceship_x),.spaceship_y(spaceship_y),.spaceship_bitmap(spaceship_bitmap),
.planet_x(planet_x),.planet_y(planet_y),.planet_bitmap(planet_bitmap),.vga_int(vga_int),.vga_ack(vga_ack));
keyboard kb1(.clk(clk),.ps2d(ps2d),.ps2c(ps2c),.ack(ack),.dout(data_out_key));
mammal m1( .clk(clk), .data_in(data_in), .data_out(data_out), .address(address), .memwt(memwt),.INT(INT), .intack(intack));
 
//===============IRQ's==============
always_comb
    begin
      irq0 = vga_int;
      irq1 = 1'b0;
      irq2 = 1'b0;
      irq3 = 1'b0;
      irq4 = 1'b0;
      irq5 = 1'b0;
      irq6 = 1'b0;
      irq7 = 1'b0;
   end
//we assume that the devices hold their irq until being serviced by cpu
assign INT = irq0 | irq1 | irq2 | irq3 | irq4 | irq5 | irq6 | irq7; 
 
always_comb
begin
    if (intack == 0)
    begin
        if ((BEGINMEM <= address) && (address <= ENDMEM))
        begin
            data_in <= memory[address];
            ack <= 0;
				vga_ack <=0;
        end
        else if (address == KEYBOARD_CHK)
        begin
            ack <= 0;
				vga_ack <=0;
            data_in <= data_out_key;
        end
        else if (address == KEYBOARD_DAT)
        begin
            ack <= 1;
				vga_ack <=0;
            data_in <= data_out_key;
        end
		  else if((SPACESHIP_BITMAP_ADRESS_START<=address) && (address<=SPACESHIP_BITMAP_ADDRESS_END))
		  begin
				data_in <= spaceship_bitmap[address];
				ack <= 0;
				vga_ack <=0;
		  end
		  else if(SPACESHIP_X == address)
			begin
				data_in <= spaceship_x;
				ack <= 0;
				vga_ack <= 1;
			end	
			else if(SPACESHIP_Y == address)
			begin
				data_in <= spaceship_y;
				ack <= 0;
				vga_ack <= 1;
			end
			else if(PLANET_X == address)
			begin
				data_in <= planet_x;
				ack <= 0;
				vga_ack <= 1;
			end	
			else if(PLANET_Y == address)
			begin
				data_in <= planet_y;
				ack <= 0;
				vga_ack <= 1;
			end
			else 
			begin
            data_in <= 16'h0000;
            ack <= 0;
				vga_ack <=0;
			end
    end
    else // intack = 1
    begin
        if (irq0)               // highest priority interrupt is irq0
		  begin
            data_in <= 16'h0;
				ack <= 0;
				vga_ack <=0;
		  end
        else if (irq1)
		  begin
            data_in <= 16'h1;
				ack <= 0;
				vga_ack <=0;
		  end
        else if (irq2)
		  begin
            data_in <= 16'h2;
				ack <= 0;
				vga_ack <=0;
		  end
        else if (irq3)
		  begin
            data_in <= 16'h3;
				ack <= 0;
				vga_ack <=0;
		  end
        else if (irq4)
		  begin
            data_in <= 16'h4;
				ack <= 0;
				vga_ack <=0;
		  end
        else if (irq5)
		  begin
            data_in <= 16'h5;
				ack <= 0;
				vga_ack <=0;
		  end
        else if (irq6)
		  begin
            data_in <= 16'h6;
				ack <= 0;
				vga_ack <=0;
		  end
        else		  // irq7 
		  begin
            data_in <= 16'h7;
				ack <= 0;
				vga_ack <=0;
		  end
    end
end

//multiplexer for cpu output
always_ff @(posedge clk)
begin
	if (memwt)
	begin
		if((BEGINMEM<=address) && (address<=ENDMEM))
		begin
			memory[address]<=data_out;
		end
		else if(SPACESHIP_X == address)
		begin
			spaceship_x <= data_out;
		end	
		else if(SPACESHIP_Y == address)
		begin
			spaceship_y <= data_out;
		end
		else if(PLANET_X == address)
		begin
			planet_x <= data_out;
		end	
		else if(PLANET_Y == address)
		begin
			planet_y <= data_out;
		end
		else if((SPACESHIP_BITMAP_ADRESS_START<=address) && (address<=SPACESHIP_BITMAP_ADDRESS_END))
		begin
			spaceship_bitmap[address] <= data_out;
		end
	end
end


initial
	begin
		$readmemh("ram.dat", memory);
		data_out_key=16'h0000;
		vga_int<=0;
		vga_ack<=0;
		ack<=0;
		spaceship_bitmap[0] = 16'h0080;
		spaceship_bitmap[1] = 16'h01c0;
		spaceship_bitmap[2] = 16'h01c0;
		spaceship_bitmap[3] = 16'h01c0;
		spaceship_bitmap[4] = 16'h01c0;
		spaceship_bitmap[5] = 16'h03e0;
		spaceship_bitmap[6] = 16'h07f0;
		spaceship_bitmap[7] = 16'h0ff8;
		spaceship_bitmap[8] = 16'h3ffe;
		spaceship_bitmap[9] = 16'h01c0;
		spaceship_bitmap[10] = 16'h01c0;
		spaceship_bitmap[11] = 16'h01c0;
		spaceship_bitmap[12] = 16'h01c0;
		spaceship_bitmap[13] = 16'h03e0;
		spaceship_bitmap[14] = 16'h07f0;
		spaceship_bitmap[15] = 16'h01c0;
		planet_bitmap[0] = 16'h0000;
		planet_bitmap[1] = 16'h01F0;
		planet_bitmap[2] = 16'h0FF8;
		planet_bitmap[3] = 16'h1FFC;
		planet_bitmap[4] = 16'h3FFE;
		planet_bitmap[5] = 16'h3FFE;
		planet_bitmap[6] = 16'h3FFE;
		planet_bitmap[7] = 16'hFFFF;
		planet_bitmap[8] = 16'hFFFF;
		planet_bitmap[9] = 16'hFFFF;
		planet_bitmap[10] = 16'h3FFE;
		planet_bitmap[11] = 16'h3FFE;
		planet_bitmap[12] = 16'h1FFC;
		planet_bitmap[13] = 16'h0FF8;
		planet_bitmap[14] = 16'h01F0;
		planet_bitmap[15] = 16'h0000;
	end
	
	
endmodule