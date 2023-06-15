`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:34:44 05/22/2023 
// Design Name: 
// Module Name:    nexys3 
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


module nexys3 (  /*AUTOARG*/
    // Outputs
    //   RsTx,
  //  led,
    seg,
    an,
	 red,
	 green,
	 blue,
	 hsync,
	 vsync,
    // Inputs
    RsRx,
    sw,
    btnUp,
    btnMiddle,
    btnDown,
    btnLeft,
    btnRight,  
    clk,
    JA
);
  // reg [3:0] grid[8:0][8:0];
  // reg [3:0] grid[80:0]; // [8:0];
  reg [323:0] grid; // [8:0];
  wire [323:0] gridWire;
  reg [3:0] selectedRow;
  reg [3:0] selectedCol;

  //integer numberOfGames = 3;
  reg [1:0] gameIndex;

  // btn, sw, 

  //`include "seq_definitions.v"

  // USB-UART
  input RsRx;
  // output       RsTx;
  output [3:0] an;
  reg [3:0] an2;
  output [7:0] seg;
  reg [7:0] seg2;
  
  
  output [2:0] red;
  reg [2:0] vgaRedReg;

  output [2:0] green;
  reg [2:0] vgaGreenReg;
  
  output [1:0] blue;
  reg [1:0] vgaBlueReg;
  
  output hsync;
  output vsync; // 0 or 1
  reg HsyncReg;
  reg VsyncReg; // 0 or 1
  // syncronization pulse that defines how long it take to draw the 640 scanlines -
  // basically, how long it takes to draw the entire crene or frame. 

  // Misc.
  input [7:0] sw;
 // output [7:0] led;
  input btnUp;  // single-step instruction
  input btnMiddle;  // arst
  input btnDown; 
  input btnLeft; 
  input btnRight;

  // Logic
  input clk;  // 100MHz

  wire           paused;
  wire           paused_i;
  reg     [27:0] counter_paused;
  wire    [27:0] counter_paused_dec;
  reg            paused_reg;
  
  wire           left;
  wire           left_i;
  reg     [27:0] counter_left;
  wire    [27:0] counter_left_dec;
  reg            left_reg;
  
  wire           right;
  wire           right_i;
  reg     [27:0] counter_right;
  wire    [27:0] counter_right_dec;
  reg            right_reg;
  
  wire           up;
  wire           up_i;
  reg     [27:0] counter_up;
  wire    [27:0] counter_up_dec;
  reg            up_reg;
  
  wire           down;
  wire           down_i;
  reg     [27:0] counter_down;
  wire    [27:0] counter_down_dec;
  reg            down_reg;

  wire           rst;
  reg     [27:0] counter;
  wire    [28:0] counter_inc;

  reg     [27:0] counter_adj;
  wire    [28:0] counter_adj_inc;
  reg     [27:0] counter_seg;
  wire    [28:0] counter_seg_inc;
  reg     [27:0] counter_seg2;
  wire    [28:0] counter_seg_inc2;
  integer        factor = 1;  //10;
  integer        debouncingDelay = 1000000 * 10 * 5;

  wire    [17:0] clk_dv_inc;

  reg     [16:0] clk_dv;
  reg            clk_en;
  reg            clk_en_d;

  reg     [ 5:0] minutes;
  wire    [ 6:0] minutes_inc;
  reg     [ 5:0] decaminutes;
  wire    [ 6:0] decaminutes_inc;
  reg     [ 5:0] seconds;
  wire    [ 6:0] seconds_inc;
  reg     [ 5:0] decaseconds;
  wire    [ 6:0] decaseconds_inc;
  wire completed_game;
  reg completed_game_reg;
  // ===========================================================================
  // Asynchronous Reset
  // ===========================================================================

  assign seg[7:0] = seg2[7:0];
  assign an[3:0] = an2[3:0];

  // assign rst = btnMiddle;
  // assign rst = 0;

  // ===========================================================================
  // 763Hz timing signal for clock enable
  // ===========================================================================

  assign clk_dv_inc = clk_dv + 1;
  assign counter_inc = counter + 1;
  assign counter_adj_inc = counter_adj + 1;
  assign counter_seg_inc = counter_seg + 1;
  assign counter_seg_inc2 = counter_seg2 + 1;
  assign seconds_inc = seconds + 1;
  assign decaseconds_inc = decaseconds + 1;
  assign minutes_inc = minutes + 1;
  assign decaminutes_inc = decaminutes + 1;

  assign paused_i = btnMiddle;
  assign paused = paused_reg;
  assign completed_game = completed_game_reg ^ paused_reg;
  assign counter_paused_dec = counter_paused + 1;
  
  assign left_i = btnLeft;
  assign left = left_reg; // unneeded
  assign counter_left_dec = counter_left + 1;

  assign right_i = btnRight;
  assign right = right_reg;
  assign counter_right_dec = counter_right + 1;
  
  assign up_i = btnUp;
  assign up = up_reg;
  assign counter_up_dec = counter_up + 1;

  assign down_i = btnDown;
  assign down = down_reg;
  assign counter_down_dec = counter_down + 1;

  assign gridWire = grid;


  integer r;
  integer c;
  integer bo; // bitOffset
  integer isAnswer; // bitOffset
  // reg [16*8-1:0] g0;
  reg [323:0] currentOriginal;
  wire [323:0] currentOriginalWire;
  assign currentOriginalWire = currentOriginal;
  reg [323:0] g0;
  reg [323:0] g0A;
  reg [323:0] g1;
  reg [323:0] g1A;
  reg [323:0] g2;
  reg [323:0] g2A;
  
  inout [7:0] JA;
  // input [7:0] JA;
  wire [3:0] Decode;
  
  reg [3:0] DecodeReg;

  initial begin
      // g0 = 324'b000000000101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000;
      //// g0 = 324'b000000010010001101000101011001111000000100100011010001010110011110000000001000110100010101100111100000000001001101000101011001111000000000010010010001010110011110000000000100100011010101100111100000000001001000110100011001111000000000010010001101000101011110000000000100100011010001010110100000000001001000110100010101100000;//string is bottom right to top left, top leftsqr is 0000 
      //// g0A = 324'b000000010010001101000101011001111000000100100011010001010110011110000000001000110100010101100111100000000001001101000101011001111000000000010010010001010110011110000000000100100011010101100111100000000001001000110100011001111000000000010010001101000101011110000000000100100011010001010110100000000001001000110100010101100001;
      
      g0 = 324'b000110011000010001110011011001010010011000100111100001010001100101000011010101000011100100100110000101111000010001010010000110010111001110000110011110000110001101000010010100011001001100011001010101101000011100100100000000000001011100110100100000000101000000110101001000010000010000000111000000000100011000000000001000110001;
      g0A = 324'b000110011000010001110011011001010010011000100111100001010001100101000011010101000011100100100110000101111000010001010010000110010111001110000110011110000110001101000010010100011001001100011001010101101000011100100100001001100001011100110100100010010101100000110101001000011001010001100111100101110100011010000101001000110001;
      // knight
      g1 = 324'b010000100001000000110000000000001000001101110000010000100000000000010110011010010000000000010000000000000000000100000010000000000100011001010000011100000011001000000110000100000100000001100100000000000101000000110000000001000110000001010010001100000000001000000111100101000011100001100000000000111001000001100001000001000010;
      g1A = 324'b010000100001011000111001010101111000001101110101010000101000100100010110011010011000010100010111010000100011000110000010001101110100011001011001011101010011001010010110000110000100100101100100000110000101001000110111100001000110011101010010001110010001001000010111100101000011100001100101010100111001100001100001011101000010;

      // king
      g2 = 324'b100100110000000100000101000001110100001001110000100000001001000000110110000100000100011100110110000000100000011101100011100100000000010000000101000000001000010100000000000000000000000000000000010001111000000001100000000001000000000010010001001101010000011000000000000000000000000000010000001100001001001001010000000000000000;
      g2A = 324'b100100110110000100100101100001110100001001110101100001001001000100110110000110000100011100110110010100101001011101100011100100010010010010000101010000101000010101100011011110010001010110010001010001111000001001100011100001000010011010010001001101010111011001010111001110000100100100010010001100011001001001010111011001001000;
      // $display("%b s", g0);
      selectedRow = 0;
      selectedCol = 0;
      DecodeReg = 4'b1101;
      // $display("init begin");
      HsyncReg = 0;
      VsyncReg = 0;
      gameIndex=0;
      completed_game_reg  = 0;
      for (r = 0; r < 9; r = r + 1) begin
          for (c = 0; c < 9; c = c + 1) begin                
            for (bo = 0;bo<4;bo = bo+1) begin
              grid[(r*9 + c)*4 + bo] <= g0[(r*9 + c)*4 + bo];
              currentOriginal[(9*r + c)*4 + bo] <= g0[(r*9 + c)*4 + bo];
              // games[0][r][c] <= 10; // games[gameIndex][r][c];
              //  $write("%d ", );
            end
            
              // $write("%d r:%d c:%d", grid[(r*9 + c)*4+0] * 1 + grid[(r*9 + c)*4+1] * 2 + grid[(r*9 + c)*4+2] * 4 + grid[(r*9 + c)*4+3] * 8,r,c);
          end
      // $display("");
      end
      // $display("%b \n %b \n%b\n s", g0, grid, currentOriginal);

      // $display("init end");
  end


Decoder C0(
			.clk(clk),
			.Row(JA[7:4]),
			.Col(JA[3:0]),
			.DecodeOut(Decode)
	);

  always @(posedge clk) begin
    // counter <= counter_inc[15:0];
    // $display("here");
    
  vgaRedReg <= 0;
  vgaGreenReg <= 1;  
  vgaBlueReg <= 2;
  // DecodeReg <= DecodeReg & Decode;
  if (Decode == 4'b1101 && DecodeReg == 4'b0000) begin // reset
    DecodeReg <= Decode;
    HsyncReg <= 0;
    VsyncReg <= 0;
    // gameIndex <= 0;
    // $display("reset");

    for (r = 0; r < 9; r = r + 1) begin
      for (c = 0; c < 9; c = c + 1) begin
        for (bo = 0;bo<4;bo = bo+1) begin
          grid[(r*9 + c)*4 + bo] <= currentOriginal[(r*9 + c)*4 + bo];
        end
          // $write("%d ", grid[(r*9 + c)*4+0] * 1 + grid[(r*9 + c)*4+1] * 2 + grid[(r*9 + c)*4+2] * 4 + grid[(r*9 + c)*4+3] * 8);
      end
      // $display("");
    end
    // $display("DecodeReg: %b", DecodeReg);
    // $display("done printing in reset");

    clk_dv <= 0;
    counter <= 0;
    counter_adj <= 0;
    counter_seg <= 0;
    counter_seg2 <= 0;
    clk_en <= 1'b0;
    clk_en_d <= 1'b0;
    minutes <= 0;
    seconds <= 0;
    decaminutes <= 0;
    decaseconds <= 0;
    paused_reg <= 0;
    completed_game_reg <= 0;

    left_reg <= 0;
    counter_paused <= debouncingDelay;  // 10k = .1ms
    counter_left <= debouncingDelay;  // 10k = .1ms
    counter_right <= debouncingDelay;  // 10k = .1ms
    counter_up <= debouncingDelay;  // 10k = .1ms
    counter_down <= debouncingDelay;  // 10k = .1ms
    selectedCol <= 0;
    selectedRow <= 0;
    paused_reg <= 0;
    an2 <= 4'b0100;
    seg2 <= 7'b1111001;
  end else if (paused_i == 1 && counter_paused >= debouncingDelay) begin
    if (paused == 1) begin
      paused_reg <= 0; // unpause
    end else begin
      paused_reg <= 1; // pause
    end
    counter_paused <= 0;
    
    HsyncReg <= 1;
    VsyncReg <= 1;
  end else if (paused) begin
    if (counter_paused_dec < debouncingDelay) begin
      counter_paused <= counter_paused_dec;
    end else begin
      counter_paused <= debouncingDelay;
    end
    HsyncReg <= 1;
    VsyncReg <= 1;
  end else begin
    HsyncReg <= 1;
    VsyncReg <= 1;
    if (counter_paused_dec < debouncingDelay) begin
      counter_paused <= counter_paused_dec;
    end else begin
      counter_paused <= debouncingDelay;
    end
    if (left_i == 1 && counter_left >= debouncingDelay) begin
      if (selectedCol == 0) selectedCol <= 8;
      else selectedCol <= selectedCol - 1;
      counter_left <= 0;
    end else begin
      if (counter_left_dec < debouncingDelay) counter_left <= counter_left_dec;
      else counter_left <= debouncingDelay;
    end
    if (right_i == 1 && counter_right >= debouncingDelay) begin
      if (selectedCol == 8) selectedCol <= 0;
      else selectedCol <= selectedCol + 1;
      counter_right <= 0;
    end else begin
      if (counter_right_dec < debouncingDelay) counter_right <= counter_right_dec;
      else counter_right <= debouncingDelay;
    end
    if (up_i == 1 && counter_up >= debouncingDelay) begin
      if (selectedRow == 0) selectedRow <= 8;
      else selectedRow <= selectedRow - 1;
      counter_up <= 0;
    end else begin
      if (counter_up_dec < debouncingDelay) counter_up <= counter_up_dec;
      else counter_up <= debouncingDelay;
    end
    if (down_i == 1 && counter_down >= debouncingDelay) begin
      if (selectedRow == 8) selectedRow <= 0;
      else selectedRow <= selectedRow + 1;
      counter_down <= 0;
    end else begin
      if (counter_down_dec < debouncingDelay) counter_down <= counter_down_dec;
      else counter_down <= debouncingDelay;
    end

    if (sw[7] == 1) begin  // adjD 
      if (counter_adj_inc >= 50000000 / factor) begin  // divide by 2. todo
        counter_adj <= counter_adj_inc[0];
        if (sw[6] == 0) begin  // minutes for adj/sel
          if (minutes_inc == 10) begin
            if (decaminutes_inc == 10) begin  // might need to dbe 6 for an hour
              decaminutes <= 0;
            end else begin
              decaminutes <= decaminutes_inc;
            end
            minutes <= 0;
          end else begin
            minutes <= minutes_inc;
          end
        end else begin  // seconds for adj/sel
          if (seconds_inc == 10) begin
            if (decaseconds_inc == 6) begin
              decaseconds <= 0;
            end else begin
              decaseconds <= decaseconds_inc;
            end
            seconds <= 0;
          end else begin
            seconds <= seconds_inc;
          end

        end
      end else begin
        counter_adj <= counter_adj_inc[27:0];
      end
      // end else if (counter_inc == 100000000/100) begin // 1000ms
    end else if (counter_inc == 100000000 / factor) begin  // 1000ms
      counter_adj <= 0;
      clk_dv   <= clk_dv_inc[16:0];
      counter  <= 0;
      // 10^8 = 1Hz, .5E8 = 2Hz, 200Hz = .5E8/100 = .5E6 = 5E5
      clk_en   <= clk_dv_inc[17];  //17,16
      clk_en_d <= clk_en;
      // seconds <= seconds_inc[5:0];
      if (seconds_inc == 10) begin
        if (decaseconds_inc == 6) begin
          if (minutes_inc == 10) begin
            if (decaminutes_inc == 10) begin  // might need to dbe 6 for an hour
              decaminutes <= 0;
            end else begin
              decaminutes <= decaminutes_inc;
            end
            minutes <= 0;
          end else begin
            minutes <= minutes_inc;
          end
          decaseconds <= 0;
        end else begin
          decaseconds <= decaseconds_inc;
        end
        seconds <= 0;
      end else begin
        seconds <= seconds_inc;
      end
    end else begin
      counter_adj <= 0;
      clk_dv <= clk_dv_inc[16:0];
      counter <= counter_inc[27:0];
      // 10^8 = 1Hz, .5E8 = 2Hz, 200Hz = .5E8/100 = .5E6 = 5E5
      clk_en <= clk_dv_inc[17];  //17,16
      clk_en_d <= clk_en;
    end


  end

    // seg

    if (counter_seg_inc == 100000000/400/factor) // 400Hz
        begin
      // $display("refresh");

      // an2 <= 4'b0001;;
      if (counter_seg_inc2 == 4) begin
        an2 <= 4'b1110;
        counter_seg2 <= 0;
        case (seconds)
          0: seg2 <= 7'b1000000;
          1: seg2 <= 7'b1111001;
          2: seg2 <= 7'b0100100;
          3: seg2 <= 7'b0110000;
          4: seg2 <= 7'b0011001;
          5: seg2 <= 7'b0010010;
          6: seg2 <= 7'b0000010;
          7: seg2 <= 7'b1111000;
          8: seg2 <= 7'b0000000;
          9: seg2 <= 7'b0010000;
        endcase
      end

      if (counter_seg_inc2 == 1) begin
        an2 <= 4'b1101;
        counter_seg2 <= 1;

        if ( sw[7] == 1 &&  sw[6] == 1) begin // adjust is on
        end else
          case (decaseconds)
            0: seg2 <= 7'b1000000;
            1: seg2 <= 7'b1111001;
            2: seg2 <= 7'b0100100;
            3: seg2 <= 7'b0110000;
            4: seg2 <= 7'b0011001;
            5: seg2 <= 7'b0010010;
            6: seg2 <= 7'b0000010;
            7: seg2 <= 7'b1111000;
            8: seg2 <= 7'b0000000;
            9: seg2 <= 7'b0010000;
          endcase
      end
      if (counter_seg_inc2 == 2) begin
        an2 <= 4'b1011;
        counter_seg2 <= 2;
        if ( sw[7] == 1 &&  sw[6] == 0) begin // adjust is on
        end else
          case (minutes)
            0: seg2 <= 7'b1000000;
            1: seg2 <= 7'b1111001;
            2: seg2 <= 7'b0100100;
            3: seg2 <= 7'b0110000;
            4: seg2 <= 7'b0011001;
            5: seg2 <= 7'b0010010;
            6: seg2 <= 7'b0000010;
            7: seg2 <= 7'b1111000;
            8: seg2 <= 7'b0000000;
            9: seg2 <= 7'b0010000;
          endcase
      end
      if (counter_seg_inc2 == 3) begin
        an2 <= 4'b0111;
        counter_seg2 <= 3;

        if ( sw[7] == 1 &&  sw[6] == 0) begin // adjust is on
        end else
          case (decaminutes)
            0: seg2 <= 7'b1000000;
            1: seg2 <= 7'b1111001;
            2: seg2 <= 7'b0100100;
            3: seg2 <= 7'b0110000;
            4: seg2 <= 7'b0011001;
            5: seg2 <= 7'b0010010;
            6: seg2 <= 7'b0000010;
            7: seg2 <= 7'b1111000;
            8: seg2 <= 7'b0000000;
            9: seg2 <= 7'b0010000;
          endcase
      end
      counter_seg <= 0;
    end else begin
      counter_seg <= counter_seg_inc;
    end
    if (DecodeReg != 0) begin
      if (Decode == 4'b1101 && DecodeReg != 0) begin 
        if (DecodeReg < 4'b1010) begin
          if (currentOriginal[(selectedRow*9 + selectedCol)*4 + 3] == 0 && currentOriginal[(selectedRow*9 + selectedCol)*4 + 2] == 0 && currentOriginal[(selectedRow*9 + selectedCol)*4 + 1] == 0 && currentOriginal[(selectedRow*9 + selectedCol)*4 + 0] == 0) begin
            grid[(selectedRow*9 + selectedCol)*4 + 3] <= DecodeReg[3];
            grid[(selectedRow*9 + selectedCol)*4 + 2] <= DecodeReg[2];
            grid[(selectedRow*9 + selectedCol)*4 + 1] <= DecodeReg[1];
            grid[(selectedRow*9 + selectedCol)*4 + 0] <= DecodeReg[0];
            // minutes <= DecodeReg;
            // TODO check sol
            if (gameIndex == 0) begin
            isAnswer = 1;
              for (r = 0; r < 9; r = r + 1) begin
                for (c = 0; c < 9; c = c + 1) begin
                  for (bo = 0;bo<4;bo = bo+1) begin
                    if (grid[(r*9 + c)*4 + bo] != g0A[(r*9 + c)*4 + bo]) begin 
                      isAnswer = 0;
                    end
                  end
                end
              end
              if (isAnswer == 1) begin 
                paused_reg <= 1;
                completed_game_reg <= 1;
              end
            end else if (gameIndex == 1) begin
            isAnswer = 1;
              for (r = 0; r < 9; r = r + 1) begin
                for (c = 0; c < 9; c = c + 1) begin
                  for (bo = 0;bo<4;bo = bo+1) begin
                    if (grid[(r*9 + c)*4 + bo] != g1A[(r*9 + c)*4 + bo]) begin 
                      isAnswer = 0;
                    end
                  end
                end
              end
              if (isAnswer == 1) begin 
                paused_reg <= 1;
                completed_game_reg <= 1;
              end
            end else if (gameIndex == 2) begin
            isAnswer = 1;
              for (r = 0; r < 9; r = r + 1) begin
                for (c = 0; c < 9; c = c + 1) begin
                  for (bo = 0;bo<4;bo = bo+1) begin
                    if (grid[(r*9 + c)*4 + bo] != g2A[(r*9 + c)*4 + bo]) begin 
                      isAnswer = 0;
                    end
                  end
                end
              end
              if (isAnswer == 1) begin 
                completed_game_reg <= 1;
                paused_reg <= 1;
              end 
              end
          end
        end else if (DecodeReg == 4'b1111) begin
          // next game
          HsyncReg <= 0;
          VsyncReg <= 0;
          gameIndex <= gameIndex + 1;
          // $display("reset");
          if (gameIndex == 0) 
            for (r = 0; r < 9; r = r + 1) begin
              for (c = 0; c < 9; c = c + 1) begin
                for (bo = 0;bo<4;bo = bo+1) begin
                  grid[(r*9 + c)*4 + bo] <= g1[(r*9 + c)*4 + bo];
                  currentOriginal[(r*9 + c)*4 + bo] <= g1[(r*9 + c)*4 + bo];
                end
              end
            end
          else if (gameIndex == 1)
            for (r = 0; r < 9; r = r + 1) begin
              for (c = 0; c < 9; c = c + 1) begin
                for (bo = 0;bo<4;bo = bo+1) begin
                  grid[(r*9 + c)*4 + bo] <= g2[(r*9 + c)*4 + bo];
                  currentOriginal[(r*9 + c)*4 + bo] <= g2[(r*9 + c)*4 + bo];
                end
              end
            end
          clk_dv <= 0;
          counter <= 0;
          counter_adj <= 0;
          counter_seg <= 0;
          counter_seg2 <= 0;
          clk_en <= 1'b0;
          clk_en_d <= 1'b0;
          minutes <= 0;
          seconds <= 0;
          decaminutes <= 0;
          decaseconds <= 0;
          paused_reg <= 0;
          completed_game_reg <= 0;
          left_reg <= 0;
          counter_paused <= debouncingDelay;  // 10k = .1ms
          counter_left <= debouncingDelay;  // 10k = .1ms
          counter_right <= debouncingDelay;  // 10k = .1ms
          counter_up <= debouncingDelay;  // 10k = .1ms
          counter_down <= debouncingDelay;  // 10k = .1ms
          an2 <= 4'b0100;
          seg2 <= 7'b1111001;
          selectedCol <= 0;
          selectedRow <= 0;
        end
      end 
      DecodeReg <= Decode;
    end


  end

  // ===========================================================================
  // Instruction Stepping Control
  // ===========================================================================
  // assign led[7:3] = sw[7:3];
  // assign led[0]   = sw[0];
  // assign led[1]   = RsRx;
  // assign led[2]   = btnMiddle;
  
  clockdiv U1(
	.clk(clk),
	.clr(btnMiddle), // reset button
	// .segclk(segclk),
	.dclk(dclk)
	);
  vga U3(
	.dclk(dclk), // 25 MHz
	.clr(btnMiddle),
	.hsync(hsync),
	.vsync(vsync),
  .gridWire(gridWire),
  .currentOriginalWire(currentOriginalWire),
  .selectedRow(selectedRow),
  .selectedCol(selectedCol),
	.red(red),
	.green(green),
	.paused(completed_game),
	.blue(blue)
	);
endmodule  // nexys3
// Local Variables:
// verilog-library-flags:("-f ../input.vc")
// End:

