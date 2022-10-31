module TrackballEmu
(
   input clk,
   input [3:0] joystick_digital,
   input [15:0] joystick_analog,
   input [24:0] ps2_mouse,

   input [1:0] mode, // 0 = joy_digital, 1 = joy_analog, 2 = mouse, 3 = snac
   input [1:0] sensitivity,
   
   input v_dir_in, v_clk_in, h_dir_in, h_clk_in,            // from SNAC
   output v_dir_out, v_clk_out, h_dir_out, h_clk_out
);

// c  |  0  1  2  3  
//       00 01 10 11

// A  |  L  H  H  L
// B  |  L  L  H  H 



localparam [15:0] CLOCK_BASE = 16'd3000;
localparam FALLOFF_WIDTH = 11;
localparam joystick_divider_max = 60000;
localparam analog_divider_max = 300000;

reg [19:0] divider;
reg [FALLOFF_WIDTH-1:0] falloff;

reg [7:0] magnitude_x, move_x;
reg [7:0] magnitude_y, move_y;
reg [15:0] h_counter;
reg [15:0] h_cnt_max = 0;
reg [15:0] v_counter;
reg [15:0] v_cnt_max = 0;

reg vdir, hdir;
reg [1:0] vstate, hstate;

always @(posedge clk)
begin
   
   reg updatex;
   reg updatey;
   
   case (mode)
      2'b00 :           // digital joystick
         begin
            divider <= divider - 1'b1;
            if (divider == 0)
            begin
               divider <= joystick_divider_max;
               
               // Right
               if (joystick_digital[0])
               begin
                  hdir <= 1'b0;
                  move_x = 8'd16;
                  updatex <= 1'b1;
               end

               // Left
               if (joystick_digital[1])
               begin
                  hdir <= 1'b1;
                  move_x = 8'd16;
                  updatex <= 1'b1;
               end

               // Down
               if (joystick_digital[2])
               begin
                  vdir <= 1'b1;
                  move_y = 8'd16;
                  updatey <= 1'b1;
               end

               // Up
               if (joystick_digital[3])
               begin
                  vdir <= 1'b0;
                  move_y = 8'd16;
                  updatey <= 1'b1;
               end
            end
         end
         
      2'b01 :     // analog joystick
         begin
            divider <= divider - 1'b1;
            if (divider == 0)
            begin
               divider <= analog_divider_max;

               // Horizontal
               if (joystick_analog[7:0] != 0)
               begin
                  hdir <= joystick_analog[7];
                  move_x = {1'b0, joystick_analog[7] ? -joystick_analog[6:0] : joystick_analog[6:0]};
                  if (move_x < 10) move_x = 0;
                  updatex <= 1'b1;
               end

               // Vertical
               if (joystick_analog[15:8] != 0)
               begin
                  vdir <= ~joystick_analog[15];
                  move_y = {1'b0, joystick_analog[15] ? -joystick_analog[14:8] : joystick_analog[14:8]};
                  if (move_y < 10)
                     move_y = 0;
                  updatey <= 1'b1;
               end
            end
         end

      2'b10 :     // mouse
         begin
            reg old_mstate;
            old_mstate <= ps2_mouse[24];
            if (old_mstate != ps2_mouse[24])
            begin
               hdir <= ps2_mouse[4];  // sign X
               vdir <= ps2_mouse[5];  // sign Y
               move_x = ps2_mouse[4] ? -ps2_mouse[15:8] : ps2_mouse[15:8];
               move_y = ps2_mouse[5] ? -ps2_mouse[23:16] : ps2_mouse[23:16];
               updatex <= 1'b1;
               updatey <= 1'b1;
            end
         end
         
      2'b11 :     // snac
         begin
         end
        
   endcase      
         
   if (updatex)
   begin 
      case (sensitivity)
         2'b00 : // 25% speed
            magnitude_x = move_x >> 2;
         2'b01 : // 50% speed
            magnitude_x = move_x >> 1;
         2'b10 : // 100% speed
            magnitude_x = move_x;
         2'b11 : // 200% speed
            magnitude_x = move_x << 1;
      endcase 
      falloff <= {FALLOFF_WIDTH{1'b1}};
      updatex <= 1'b0;
   end    

   if (updatey)
   begin 
      case (sensitivity)
         2'b00 : // 25% speed
            magnitude_y = move_y >> 2;
         2'b01 : // 50% speed
            magnitude_y = move_y >> 1;
         2'b10 : // 100% speed
            magnitude_y = move_y;
         2'b11 : // 200% speed
            magnitude_y = move_y << 1;
      endcase 
      falloff <= {FALLOFF_WIDTH{1'b1}};
      updatey <= 1'b0;
   end    


   if (magnitude_x > 0) h_cnt_max <= CLOCK_BASE + ((16'd255 - {8'b0,magnitude_x}) << 4); else h_cnt_max <= 0;
   if (magnitude_y > 0) v_cnt_max <= CLOCK_BASE + ((16'd255 - {8'b0,magnitude_y}) << 4); else v_cnt_max <= 0;

   if (falloff == 0)
   begin
      if (magnitude_x > 0) magnitude_x = magnitude_x - 1'b1;
      if (magnitude_y > 0) magnitude_y = magnitude_y - 1'b1;
      falloff <= {FALLOFF_WIDTH{1'b1}};
   end
   else
      falloff <= falloff - 1'b1;

   if (h_cnt_max == 0)
      h_counter <= 0;
   else
   begin
      h_counter <= h_counter + 1'b1;
      if (h_counter >= h_cnt_max)
      begin
         h_counter <= 0;
         hstate <= hdir ? hstate + 2'd1 : hstate - 2'd1;
      end
   end

   if (v_cnt_max == 0)
      v_counter <= 0;
   else
   begin
      v_counter <= v_counter + 1'b1;
      if (v_counter >= v_cnt_max)
      begin
         v_counter <= 0;
         vstate <= vdir ? vstate + 2'd1 : vstate - 2'd1;
      end
   end
end

assign h_dir_out = mode == 2'b11 ? h_dir_in : hstate[1];
assign h_clk_out = mode == 2'b11 ? h_clk_in : hstate[0] ^ hstate[1];
assign v_dir_out = mode == 2'b11 ? v_dir_in : vstate[1];
assign v_clk_out = mode == 2'b11 ? v_clk_in : vstate[0] ^ vstate[1];

endmodule