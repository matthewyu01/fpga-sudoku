`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:30:38 03/19/2013 
// Design Name: 
// Module Name:    vga640x480 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga(
	input wire dclk,			//pixel clock: 25MHz
	input wire clr,			//asynchronous reset
	input wire [323:0] gridWire, //g0 = 324'b000000010010001101000101011001111000000100100011010001010110011110000000001000110100010101100111100000000001001101000101011001111000000000010010010001010110011110000000000100100011010101100111100000000001001000110100011001111000000000010010001101000101011110000000000100100011010001010110100000000001001000110100010101100111;
	input wire [323:0] currentOriginalWire,
	input wire [3:0] selectedRow,
    input wire [3:0] selectedCol,
    input wire paused,
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [2:0] red,	//red vga output
	output reg [2:0] green, //green vga output
	output reg [1:0] blue	//blue vga output

	);

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch
parameter OFFSET_X = 40;
parameter OFFSET_Y = 40;
parameter WHITE_SQUARE_WIDTH = 43;
parameter SQUARE_WIDTH = 44;
parameter WHITE_X_PADDING = 13;
parameter WHITE_Y_PADDING = 5;
parameter SEGMENT_LENGTH = 15;
integer SELECTED_SQUARE_X = OFFSET_X + 0;
integer SELECTED_SQUARE_Y = OFFSET_Y + 0;
integer SQUARE_X = OFFSET_X /*+ SQUARE_WIDTH*/;
integer SQUARE_Y = OFFSET_Y /*+ SQUARE_WIDTH*/;
integer gridRow = 0;
integer gridCol = 0;
integer currentNumber = 0;
integer currentOriginalNumber = 0;


// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
always @(posedge dclk or posedge clr)
begin
	// reset condition
	if (clr == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
		
	end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =
always @(*)
begin
	if (vc > OFFSET_Y + SQUARE_WIDTH*8) begin
		gridRow = 8;
		SQUARE_Y = OFFSET_Y + SQUARE_WIDTH*8;
	end
	else if (vc > OFFSET_Y + SQUARE_WIDTH*7) begin
		gridRow = 7;
		SQUARE_Y = OFFSET_Y + SQUARE_WIDTH*7;
	end
	else if (vc > OFFSET_Y + SQUARE_WIDTH*6) begin
		gridRow = 6;
		SQUARE_Y = OFFSET_Y + SQUARE_WIDTH*6;
	end
	else if (vc > OFFSET_Y + SQUARE_WIDTH*5) begin
		gridRow = 5;
		SQUARE_Y = OFFSET_Y + SQUARE_WIDTH*5;
	end
	else if (vc > OFFSET_Y + SQUARE_WIDTH*4) begin
		gridRow = 4;
		SQUARE_Y = OFFSET_Y + SQUARE_WIDTH*4;
	end
	else if (vc > OFFSET_Y + SQUARE_WIDTH*3) begin
		gridRow = 3;
		SQUARE_Y = OFFSET_Y + SQUARE_WIDTH*3;
	end
	else if (vc > OFFSET_Y + SQUARE_WIDTH*2) begin
		gridRow = 2;
		SQUARE_Y = OFFSET_Y + SQUARE_WIDTH*2;
	end
	else if (vc > OFFSET_Y + SQUARE_WIDTH*1) begin
		gridRow = 1;  //1
		SQUARE_Y = OFFSET_Y + SQUARE_WIDTH*1;
	end
	else if (vc > OFFSET_Y) begin
		gridRow = 0; // 0
		SQUARE_Y = OFFSET_Y;
	end

	// w = hc - hbp
	if (hc - hbp > OFFSET_X +8* SQUARE_WIDTH) begin
		gridCol = 8;
		SQUARE_X = OFFSET_X +8* SQUARE_WIDTH;
	end
	else if (hc - hbp > OFFSET_X + 7 * SQUARE_WIDTH) begin
		gridCol = 7;
		SQUARE_X = OFFSET_X + 7* SQUARE_WIDTH;
	end
	else if (hc - hbp > OFFSET_X + 6 * SQUARE_WIDTH) begin
		gridCol = 6;
		SQUARE_X = OFFSET_X + 6* SQUARE_WIDTH;
	end
	else if (hc - hbp > OFFSET_X + 5 * SQUARE_WIDTH) begin
		gridCol = 5;
		SQUARE_X = OFFSET_X + 5* SQUARE_WIDTH;
	end
	else if (hc - hbp > OFFSET_X + 4 * SQUARE_WIDTH) begin
		gridCol = 4;
		SQUARE_X = OFFSET_X + 4* SQUARE_WIDTH;
	end
	else if (hc - hbp > OFFSET_X + 3 * SQUARE_WIDTH) begin
		gridCol = 3;
		SQUARE_X = OFFSET_X + 3* SQUARE_WIDTH;
	end
	else if (hc - hbp > OFFSET_X + 2 * SQUARE_WIDTH) begin
		gridCol = 2;
		SQUARE_X = OFFSET_X + 2* SQUARE_WIDTH;
	end
	else if (hc - hbp > OFFSET_X + 1 * SQUARE_WIDTH) begin
		gridCol = 1;
		SQUARE_X = OFFSET_X + 1* SQUARE_WIDTH;
	end
	else if (hc - hbp > OFFSET_X + 0 * SQUARE_WIDTH) begin
		gridCol = 0;
		SQUARE_X = OFFSET_X + 0* SQUARE_WIDTH;
	end


	SELECTED_SQUARE_Y = OFFSET_Y + SQUARE_WIDTH * selectedRow;
	SELECTED_SQUARE_X = OFFSET_X + SQUARE_WIDTH * selectedCol;


	
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp) // vertical coutner, horizontal coutner
	begin
		// now display different colors every 80 pixels
		// while we're within the active horizontal range
		// -----------------
		// display white bar
		if (hc >= hbp && hc < (hbp+80))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		/*
		// display yellow bar
		else if (hc >= (hbp+80) && hc < (hbp+160))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b00;
		end
		// display cyan bar
		else if (hc >= (hbp+160) && hc < (hbp+240))
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b11;
		end
		// display green bar
		else if (hc >= (hbp+240) && hc < (hbp+320))
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
		// display magenta bar
		else if (hc >= (hbp+320) && hc < (hbp+400))
		begin
			red = 3'b111;
			green = 3'b000;
			blue = 2'b11;
		end
		// display red bar
		else if (hc >= (hbp+400) && hc < (hbp+480))
		begin
			red = 3'b111;
			green = 3'b000;
			blue = 2'b00;
		end
		// display blue bar
		else if (hc >= (hbp+480) && hc < (hbp+560))
		begin
			red = 3'b000;
			green = 3'b000;
			blue = 2'b11;
		end
		// display black bar
		else if (hc >= (hbp+560) && hc < (hbp+640))
		begin
			red = 3'b000;
			green = 3'b000;
			blue = 2'b00;
		end*/
		// we're outside active horizontal range so display black
		else
		begin
			red = 0;
			green = 0;
			blue = 0;
		end





	end

		// we're outside active vertical range so display black
	else
	begin
		red = 0;
		green = 0;
		blue = 0;
	end


	// TODO: need to calculate SQUARE_X and SQUARE_Y 
	// SQUARE_X = OFFSET_X + SQUARE_WIDTH;
	// SQUARE_X = OFFSET_X + SQUARE_WIDTH*3;
	// SQUARE_X = OFFSET_X + SQUARE_WIDTH*4;
	// SQUARE_X = OFFSET_X + SQUARE_WIDTH*5;
	// SQUARE_X = OFFSET_X + SQUARE_WIDTH*6;
	// SQUARE_X = OFFSET_X + SQUARE_WIDTH*7;
	// SQUARE_X = OFFSET_X + SQUARE_WIDTH*8;
	// SQUARE_X = OFFSET_X + SQUARE_WIDTH*9;
	//  SQUARE_Y = OFFSET_X + SQUARE_WIDTH;


	currentNumber <= gridWire[(gridRow*9 + gridCol)*4] * 1 + gridWire[(gridRow*9 + gridCol)*4 + 1] * 2 + gridWire[(gridRow*9 + gridCol)*4 + 2] * 4 + gridWire[(gridRow*9 + gridCol)*4 + 3] * 8;
	currentOriginalNumber <= currentOriginalWire[(gridRow*9 + gridCol)*4] * 1 + currentOriginalWire[(gridRow*9 + gridCol)*4 + 1] * 2 + currentOriginalWire[(gridRow*9 + gridCol)*4 + 2] * 4 + currentOriginalWire[(gridRow*9 + gridCol)*4 + 3] * 8;

						// $write("%d gridRow:%d gridCol:%d", grid[(gridRow*9 + gridCol)*4+0] * 1 + grid[(gridRow*9 + gridCol)*4+1] * 2 + grid[(gridRow*9 + gridCol)*4+2] * 4 + grid[(gridRow*9 + gridCol)*4+3] * 8,gridRow,

	
	// white background per square
	if(hc > OFFSET_X + hbp && hc < OFFSET_X + hbp + 1 + 9*SQUARE_WIDTH && vc > OFFSET_Y && vc < OFFSET_Y + 1 + 9*SQUARE_WIDTH) begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
	end
	// HORIZONTAL LINES
	if (vc == OFFSET_Y && hc > OFFSET_X + hbp && hc < OFFSET_X + hbp + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	
	else if (vc == OFFSET_Y + 1 * SQUARE_WIDTH && hc > OFFSET_X + hbp && hc < OFFSET_X + hbp + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (vc == OFFSET_Y + 2 * SQUARE_WIDTH && hc > OFFSET_X + hbp && hc < OFFSET_X + hbp + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (vc == OFFSET_Y + 3 * SQUARE_WIDTH && hc > OFFSET_X + hbp && hc < OFFSET_X + hbp + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (vc == OFFSET_Y + 4 * SQUARE_WIDTH && hc > OFFSET_X + hbp && hc < OFFSET_X + hbp + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (vc == OFFSET_Y + 5 * SQUARE_WIDTH && hc > OFFSET_X + hbp && hc < OFFSET_X + hbp + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (vc == OFFSET_Y + 6 * SQUARE_WIDTH && hc > OFFSET_X + hbp && hc < OFFSET_X + hbp + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (vc == OFFSET_Y + 7 * SQUARE_WIDTH && hc > OFFSET_X + hbp && hc < OFFSET_X + hbp + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (vc == OFFSET_Y + 8 * SQUARE_WIDTH && hc > OFFSET_X + hbp && hc < OFFSET_X + hbp + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (vc == OFFSET_Y + 9 * SQUARE_WIDTH && hc > OFFSET_X + hbp && hc < OFFSET_X + hbp + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end

		// VERTICAL LINES
	else if (hc == OFFSET_X + hbp && vc > OFFSET_Y && vc < OFFSET_Y + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	
	else if (hc == OFFSET_X + hbp + 1 * SQUARE_WIDTH && vc > OFFSET_Y && vc < OFFSET_Y + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (hc == OFFSET_X + hbp + 2 * SQUARE_WIDTH && vc > OFFSET_Y && vc < OFFSET_Y + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (hc == OFFSET_X + hbp + 3 * SQUARE_WIDTH && vc > OFFSET_Y && vc < OFFSET_Y + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (hc == OFFSET_X + hbp + 4 * SQUARE_WIDTH && vc > OFFSET_Y && vc < OFFSET_Y + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (hc == OFFSET_X + hbp + 5 * SQUARE_WIDTH && vc > OFFSET_Y && vc < OFFSET_Y + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (hc == OFFSET_X + hbp + 6 * SQUARE_WIDTH && vc > OFFSET_Y && vc < OFFSET_Y + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (hc == OFFSET_X + hbp + 7 * SQUARE_WIDTH && vc > OFFSET_Y && vc < OFFSET_Y + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (hc == OFFSET_X + hbp + 8 * SQUARE_WIDTH && vc > OFFSET_Y && vc < OFFSET_Y + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end
	else if (hc == OFFSET_X + hbp + 9 * SQUARE_WIDTH && vc > OFFSET_Y && vc < OFFSET_Y + 1 + 9*SQUARE_WIDTH)
		begin
			red = 3'b000;
			green = 3'b111;
			blue = 2'b00;
		end




		if (hc > SELECTED_SQUARE_X + hbp + SQUARE_WIDTH + 25 && hc < OFFSET_X + hbp + 2 * SQUARE_WIDTH - 10) begin  // 
			// red = 3'b000;
			// green = 3'b000;
			// blue = 2'b00;
		end
		//first square
		// selected square background
		if(hc > SELECTED_SQUARE_X + hbp && hc < SELECTED_SQUARE_X + hbp + SQUARE_WIDTH && vc > SELECTED_SQUARE_Y && vc < SELECTED_SQUARE_Y + SQUARE_WIDTH) begin
				red = 3'b111;
				green = 3'b000;
				blue = 2'b11;
		end

// top left is very right

// TODO
//0000 0001 0010 001101000101011001111000000100100011010001010110011110000000001000110100010101100111100000000001001101000101011001111000000000010010010001010110011110000000000100100011010101100111100000000001001000110100011001111000000000010010001101000101011110000000000100100011010001010110100000000001001000110100010101100111;
		// current square for number NOT SELECTED SQUARE
		if(hc > SQUARE_X + hbp && hc < SQUARE_X + hbp + SQUARE_WIDTH && vc > SQUARE_Y && vc < SQUARE_Y + SQUARE_WIDTH) begin
			// TOP segment
			if(vc == SQUARE_Y + WHITE_Y_PADDING + 1) begin
				// TOP segment
				if(hc > SQUARE_X + hbp + WHITE_X_PADDING + 1 && hc < SQUARE_X + hbp + SQUARE_WIDTH - WHITE_X_PADDING - 1)begin
					if (currentNumber == 2|| currentNumber == 3|| currentNumber == 5|| currentNumber == 6|| currentNumber == 7 || currentNumber == 8 || currentNumber == 9)
					begin
						red = 3'b000;
						green = 3'b000;
						blue = 2'b00; 
						if (currentOriginalNumber ==0)
					    	blue = 2'b11;
					end

				end
				
			end


			// middle seg
			if(vc == SQUARE_Y + WHITE_Y_PADDING + 1 + SEGMENT_LENGTH + 1) begin
				if(hc > SQUARE_X + hbp + WHITE_X_PADDING + 1 && hc < SQUARE_X + hbp + SQUARE_WIDTH - WHITE_X_PADDING - 1)begin
					if (currentNumber == 2|| currentNumber == 3|| currentNumber == 4 || currentNumber == 5 || currentNumber == 6 || currentNumber == 8 || currentNumber == 9)
					begin
						red = 3'b000;
						green = 3'b000;
						blue = 2'b00;
						if (currentOriginalNumber ==0)
					    	blue = 2'b11;
					end
				end
				
			end

			// BOTTOM segment
			if(vc == SQUARE_Y + WHITE_SQUARE_WIDTH - WHITE_Y_PADDING - 1) begin
				if(hc > SQUARE_X + hbp + WHITE_X_PADDING + 1 && hc < SQUARE_X + hbp + SQUARE_WIDTH - WHITE_X_PADDING - 1)begin
					if (currentNumber == 2|| currentNumber == 3 || currentNumber == 5 || currentNumber == 6 || currentNumber == 8 || currentNumber == 9)
					begin
						// 235689
						red = 3'b000;
						green = 3'b000;
						blue = 2'b00;
						if (currentOriginalNumber ==0)
					    	blue = 2'b11;
					end

				end
				
			end

			// top left segment
			if(hc == SQUARE_X + WHITE_X_PADDING + 1 + hbp) begin
				if(vc > SQUARE_Y + WHITE_Y_PADDING + 1 && vc < SQUARE_Y + WHITE_Y_PADDING + SEGMENT_LENGTH + 1)begin
					// 0 456 89
					if ( currentNumber == 4 || currentNumber == 5 || currentNumber == 6 || currentNumber == 8 || currentNumber == 9)
					begin
						red = 3'b000;
						green = 3'b000;
						blue = 2'b00;
						if (currentOriginalNumber ==0)
					    	blue = 2'b11;
					end

				end
			end


			// top right segment
			if(hc == SQUARE_X + WHITE_X_PADDING + 1 + hbp + SEGMENT_LENGTH + 1) begin
				if(vc > SQUARE_Y + WHITE_Y_PADDING + 1 && vc < SQUARE_Y + WHITE_Y_PADDING + SEGMENT_LENGTH + 1)begin
					// ! 56
					if ( currentNumber == 1|| currentNumber == 2|| currentNumber == 3 || currentNumber == 4 || currentNumber == 7 || currentNumber == 8 || currentNumber == 9)
					begin
						red = 3'b000;
						green = 3'b000;
						blue = 2'b00;
						if (currentOriginalNumber ==0)
					    	blue = 2'b11;
					end

				end
			end


			// bottom left segment
			if(hc == SQUARE_X + WHITE_X_PADDING + 1 + hbp) begin
				if(vc > SQUARE_Y + WHITE_Y_PADDING + 1 + SEGMENT_LENGTH + 1 && vc < SQUARE_Y + WHITE_Y_PADDING + SEGMENT_LENGTH + 1 + SEGMENT_LENGTH + 1)begin
					// 0 2 6 8
					if (currentNumber == 2|| currentNumber == 6 || currentNumber == 8 )
					begin
						red = 3'b000;
						green = 3'b000;
						blue = 2'b00;
						if (currentOriginalNumber ==0)
					    	blue = 2'b11;
					end
				end
			end


			// bottom right segment
			if(hc == SQUARE_X + WHITE_X_PADDING + 1 + hbp + SEGMENT_LENGTH + 1) begin
				if(vc > SQUARE_Y + WHITE_Y_PADDING + 1 + SEGMENT_LENGTH + 1 && vc < SQUARE_Y + WHITE_Y_PADDING + SEGMENT_LENGTH + 1 + SEGMENT_LENGTH + 1)begin
					if (currentNumber == 1|| currentNumber == 3|| currentNumber == 4||currentNumber == 5||  currentNumber == 6 || currentNumber == 7|| currentNumber == 8 || currentNumber == 9)
					begin
					red = 3'b000;
					green = 3'b000;
					blue = 2'b00;
					if (currentOriginalNumber ==0)
					    blue = 2'b11;
					end

				end
			end

		end
		// // selected square
		// if(hc > SELECTED_SQUARE_X + SQUARE_WIDTH + hbp && hc < SELECTED_SQUARE_X + hbp + 2 * SQUARE_WIDTH && vc > SELECTED_SQUARE_Y && vc < SELECTED_SQUARE_Y + SQUARE_WIDTH) begin
		// 		red = 3'b111;
		// 		green = 3'b000;
		// 		blue = 2'b00;
		// end
		// 		if(hc > SELECTED_SQUARE_X + SQUARE_WIDTH + hbp && hc < SELECTED_SQUARE_X + hbp + 2 * SQUARE_WIDTH && vc > SELECTED_SQUARE_Y + SQUARE_WIDTH && vc < SELECTED_SQUARE_Y + SQUARE_WIDTH +SQUARE_WIDTH) begin
		// 		red = 3'b000;
		// 		green = 3'b000;
		// 		blue = 2'b11;
		// end
		// top segment
		
		// SELECTED_SQUARE_X contains offset_x
		// SELECTED_SQUARE_Y already contains offset_y
// 		parameter WHITE_X_PADDING = 13;
// parameter WHITE_Y_PADDING = 5;
	
	


if (paused != 0)begin 
	green = 0;
	red = 0;
	blue = 0; end

	
end

endmodule
