module vga_sync 
  (input logic        clk,
   output logic       hsync,
   output logic       vsync,
	input  logic [15:0] spaceship_x,
	input  logic [15:0] spaceship_y,
   output logic [2:0] rgb,
	input logic [15:0] spaceship_bitmap [0:15],
	input logic [15:0] planet_x,
	input logic [15:0] planet_y,
	input logic [15:0] planet_bitmap [0:15],
	input logic vga_ack,
	output logic vga_int);

   logic pixel_tick, video_on;
   logic [9:0] h_count;
   logic [9:0] v_count;

   localparam HD       = 640, //horizontal display area
              HF       = 48,  //horizontal front porch
              HB       = 16,  //horizontal back porch
              HFB      = 96,  //horizontal flyback
              VD       = 480, //vertical display area
              VT       = 10,  //vertical top porch
              VB       = 33,  //vertical bottom porch
              VFB      = 2,   //vertical flyback
              LINE_END = HF+HD+HB+HFB-1,
              PAGE_END = VT+VD+VB+VFB-1;

   always_ff @(posedge clk)
     pixel_tick <= ~pixel_tick; //25 MHZ signal is generated.

   always_ff @(posedge clk)
     if (pixel_tick) begin
        if (h_count == LINE_END)
          begin
              h_count <= 0;
                  if (v_count == PAGE_END)
                        v_count <= 0;
                  else
                     v_count <= v_count + 1;
                     end
        else
          h_count <= h_count + 1;
     end
    always_ff @(posedge clk)
	begin
		if (pixel_tick) begin
			if (vga_int == 0) begin
				if (v_count == PAGE_END && h_count == LINE_END) begin
					vga_int <= 1;
				end
			end else begin
				if (vga_ack) begin
					vga_int <= 0;
				end
			end
		end
	end
    //color generation  
   always_comb
        begin
            rgb = 3'b0;
				
				 if((h_count < HD) && (v_count < VD))// if video on
                rgb = 3'b010;
				 if((planet_x <= h_count ) && (h_count<planet_x+16) && (planet_y <= v_count ) && (v_count<planet_y+16)&& ( planet_bitmap[v_count-planet_y][h_count-planet_x] == 1))				 
					 rgb = 3'b011;
             if((spaceship_x <= h_count ) && (h_count<spaceship_x+16) && (spaceship_y <= v_count ) && (v_count<spaceship_y+16)&& ( spaceship_bitmap[v_count-spaceship_y][h_count-spaceship_x] == 1))				 
					 rgb = 3'b001;

				
        end
    //output signals
   assign hsync = (h_count >= (HD+HB) && h_count <= (HFB+HD+HB-1));
   assign vsync = (v_count >= (VD+VB) && v_count <= (VD+VB+VFB-1));

   initial
     begin
        h_count = 0;
        v_count = 0;
        pixel_tick = 0;
     end

endmodule