`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//lab2.2
//////////////////////////////////////////////////////////////////////////////////
module labkit(
    input clk_100mhz,
    input [7:0] switch,
   
    input btn_up,       // buttons, depress = high
    input btn_enter,
    input btn_left,
    input btn_down,
    input btn_right,
   
    output [7:0] seg,   //output 0->6 = seg A->G ACTIVE LOW, 
                        //output 7 = decimal point, all active low
                
    output [3:0] dig,   //selects digits 0-3, ACTIVE LOW
    output [7:0] led,   // 1 turns on leds
   
    output [2:0] vgaRed,
    output [2:0] vgaGreen,
    output [2:1] vgaBlue,
    output hsync,
    output vsync,
   
    inout [7:0] ja,
    inout [7:0] jb,
    inout [7:0] jc,
    input [7:0] jd,
    inout [19:0] exp_io_n,
    inout [19:0] exp_io_p
    );

    // all unused outputs must be assigned    VERY IMPORTANT!!!!!!
    assign vgaRed = 3'b111;
    assign vgaGreen = 3'b111;
    assign vgaBlue = 2'b11;
    assign hsync = 1'b1;
    assign vsync = 1'b1;
   
    assign seg = 8'b11111111;
    assign dig = 4'b1111;
   
    ///////////////////////////////////////////////////////////////
    // Implement the project from here
		 
	 //---------------------- initialise RANDOMISER variables ----------------------//
	 reg randomiser_done = 1'b0;
	 reg repeated = 1'b0;
	 reg show_hint = 1'b0;
	 reg reset = 1'b0;
	 
	 reg [31:0] order_list [7:0];		// 8x1 array, 32 bits in each element
	 reg [31:0] sw_order [7:0];		// 8x1 array, 32 bits in each element
	 reg [31:0] clk_cnt;
	 reg [7:0] down_cnt;
	 reg [7:0] r_TOGGLE;
	 
	 integer i;
	 integer j;
	 integer Random;

	 always @ (posedge clk_100mhz)
	 	clk_cnt = clk_cnt + 1;				// create clock count for randomiser
		
	 always @ (posedge btn_down) begin	// each btn_down press will append one switch to order_list
		Random <= clk_cnt%8;					// generate Random based on clock count
		
		// to reset the switch sequence, hold the btn_left, and then press btn_down
		if(btn_left) begin
			down_cnt <= 0;		// reset the down_cnt to generate new random sequence
			for (i=0;i<=7;i=i+1)	begin
				sw_order[i] <= 8'b00000000;	// reset 8'b value in sw_order
				order_list[i] <= 8'b00000000;	// reset 8'b value in order_list
			end // for
		end // if btn_left
		
		//--------------------- RANDOMISER implementation --------------------------//
		for (j=0; j<=20; j=j+1) begin		// regenerate Random for a maximum of 80 tries
			repeated = 1'b0;
			
			for (i=0;i<=7;i=i+1) begin		// iterate through the 8 elements in order_list
				if (order_list[i]== Random) begin  // check for repeated Random
					repeated = 1'b1;
					Random <= clk_cnt%8;		// regenerate Random if there is a repeat
				end // if order_list[i]
			end // for i
			
			if (repeated == 1'b0) begin	// assign to order_list if no repeat
				order_list[down_cnt] <= Random;
				down_cnt <= down_cnt + 1;	// move on to the next element of order_list for the next btn_down press
			end // if not repeated
		end // for j

		// once order_list has 8 random switches, use order_list to generate sw_order 
		if(down_cnt == 7) begin				
			for (j = 0; j <= 7; j = j + 1) begin
			case(order_list[j])
				0: sw_order[j] <= 8'b00000001;		// light up LED 0
				1: sw_order[j] <= 8'b00000010;		// light up LED 1
				2: sw_order[j] <= 8'b00000100;		// light up LED 2 and so on
				3: sw_order[j] <= 8'b00001000;
				4: sw_order[j] <= 8'b00010000;
				5: sw_order[j] <= 8'b00100000;
				6: sw_order[j] <= 8'b01000000;
				7: sw_order[j] <= 8'b10000000;
			endcase				
			end  // for integer j
			
			// show_hint = 1; //  this cannot be done because show_hint is changed in another always block
			
		end // if(press_cnt == 7) 		
	 
	 end // always
	 
	 // parameters to control the show_hint display mode
	 parameter freq = 1.5;
	 parameter c_CNT = 100000000 / freq  ;
	 parameter c_CNT_1 = c_CNT * 1;
	 parameter c_CNT_2 = c_CNT_1+c_CNT * 1;
	 parameter c_CNT_3 = c_CNT_2+c_CNT * 1;
	 parameter c_CNT_4 = c_CNT_3+c_CNT * 1;
	 parameter c_CNT_5 = c_CNT_4+c_CNT * 1;
	 parameter c_CNT_6 = c_CNT_5+c_CNT * 1;
	 parameter c_CNT_7 = c_CNT_6+c_CNT * 1;
	 parameter c_CNT_8 = c_CNT_7+c_CNT * 1;
	 parameter c_CNT_9 = c_CNT_8+c_CNT * 1;
	 reg [31:0] r_CNT = 0;				// stores the clock counter
	 
	  // initialise state values
	  parameter s0 = 4'b0000;
	  parameter s1 = 4'b0001;
	  parameter s2 = 4'b0010;
	  parameter s3 = 4'b0011;
	  parameter s4 = 4'b0100;
	  parameter s5 = 4'b0101;
	  parameter s6 = 4'b0110;
	  parameter s7 = 4'b0111;
	  parameter s8 = 4'b1000;
	  reg [4:0] state = 4'b0000;
	  reg [7:0]c1;
	  reg [7:0]c2;	
	  reg [7:0]c3;	
	  reg [7:0]c4;		
	  reg [7:0]c5;		
	  reg [7:0]c6;		
	  reg [7:0]c7;
	  reg [7:0]c8;	
	  reg press = 1'b1;
	  reg success = 1'b0;
	  reg progress_bar = 1'b0;
	 
	   //----------------------- initialise SUCCESS variables -----------------------------//
		parameter f = 0.5;
		parameter s_CNT = 100000000 / f  ;
		parameter s_CNT_0 = 0;
		parameter s_CNT_1 = s_CNT_0+s_CNT * 0.5;
		parameter s_CNT_2 = s_CNT_1+s_CNT * 1;
		parameter s_CNT_3 = s_CNT_2+s_CNT * 1;
		parameter s_CNT_4 = s_CNT_3+s_CNT * 1;
		parameter s_CNT_5 = s_CNT_4+s_CNT * 1;
		parameter s_CNT_6 = s_CNT_5+s_CNT * 1;
		parameter s_CNT_7 = s_CNT_6+s_CNT * 1;
		parameter s_CNT_8 = s_CNT_7+s_CNT * 1;
		parameter s_CNT_9 = s_CNT_8+s_CNT * 0.5;
		
		reg [31:0] r_CNT_2 = 0;	// stores the counter
		reg direction = 1'b0;					// 1 bit, stores the wave direction
	 
	 
	 //------------------ implementation to control LED display mode ------------------//
	 always @ (posedge clk_100mhz) begin
		 // always block to control the LED display mode (show_hint, progress_bar)
	 
		 // configure each the combination at each stage
		 c1 = sw_order[0];
		 c2 = c1 | sw_order[1];
		 c3 = c2 | sw_order[2];
		 c4 = c3 | sw_order[3];
		 c5 = c4 | sw_order[4];
		 c6 = c5 | sw_order[5];
		 c7 = c6 | sw_order[6];
		 c8 = c7 | sw_order[7];
		 
	    //---------------------- activate SHOW HINT display mode ---------------------------//
		 // press btn_enter to display the switch order
		 if(btn_enter) show_hint = 1'b1;  
		 
		  //------------------ CHECK SWITCH INPUT -----------------------//
		  // switch combination for each level
		  if (btn_up) begin
				progress_bar=1'b1;
				show_hint = 1'b0;
				r_CNT = 0;
			   if (press) begin
				  case(state)
				  s0: if (switch == c1) state = s1;				
					 else state = s0;				
					 
				  s1: if (switch == c2) state = s2;
					else state = s0;

				  s2: if (switch == c3) state = s3;
					else state = s0;
					
				  s3: if (switch == c4) state = s4;
					else state = s0;
					
				  s4: if (switch == c5) state = s5;
					else state = s0;
				
				  s5: if (switch == c6) state = s6;
					else state = s0;
				
				  s6: if (switch == c7) state = s7;
					else state = s0;
				
				  s7: if (switch == c8) state = s8;
					else state = s0;
				  
				  s8: begin
						state = s0;
						progress_bar = 1'b0;
						success = 1'b1;
			     end // s8
				  
				  endcase
				  
				  press = 1'b0;	// press is used as like a edge detector
			   end 	//end if (press)
			end	//end if (btn_up)
			
			else
			  press = 1'b1;
		 
		 if(show_hint) begin
		 progress_bar=1'b0;
			 case(r_CNT)
			   c_CNT_1: r_TOGGLE <= sw_order[0];
			   c_CNT_2: r_TOGGLE <= sw_order[1];
			   c_CNT_3: r_TOGGLE <= sw_order[2];
			   c_CNT_4: r_TOGGLE <= sw_order[3];
			   c_CNT_5: r_TOGGLE <= sw_order[4];
			   c_CNT_6: r_TOGGLE <= sw_order[5];
			   c_CNT_7: r_TOGGLE <= sw_order[6];
			   c_CNT_8: r_TOGGLE <= sw_order[7];
			   c_CNT_9: begin
					r_CNT = 0;
					r_TOGGLE <= 8'b00000000;
					show_hint = 1'b0;			// change LED mode
					progress_bar = 1'b1;		// go back to show the progress_bar
				end // c_CNT_9
			 endcase
			 r_CNT = r_CNT + 1;
		  end // if show_hint

			  
		  //---------------- PROGRESS BAR display mode ------------------//
		  if(progress_bar) begin
			 case(state)
				s0: r_TOGGLE <= 8'b00000000;
				s1: r_TOGGLE <= 8'b00000001;
				s2: r_TOGGLE <= 8'b00000011;
				s3: r_TOGGLE <= 8'b00000111;
				s4: r_TOGGLE <= 8'b00001111;
				s5: r_TOGGLE <= 8'b00011111;
				s6: r_TOGGLE <= 8'b00111111;
				s7: r_TOGGLE <= 8'b01111111;
				s8: r_TOGGLE <= 8'b11111111;
			 endcase
		  end // if
		  
		  //--------------------- SUCCESS display mode ---------------------//
		  // this was not successfully integrated into the working program
//		  if(success) begin
//			  case(r_CNT_2)
//				 s_CNT_0: direction <= 0;
//				 s_CNT_1: r_TOGGLE <= 8'b00000001;
//				 s_CNT_2: r_TOGGLE <= 8'b00000010;
//				 s_CNT_3: r_TOGGLE <= 8'b00000100;
//				 s_CNT_4: r_TOGGLE <= 8'b00001000;
//				 s_CNT_5: r_TOGGLE <= 8'b00010000;
//				 s_CNT_6: r_TOGGLE <= 8'b00100000;
//				 s_CNT_7: r_TOGGLE <= 8'b01000000;
//				 s_CNT_8: r_TOGGLE <= 8'b10000000;
//				 s_CNT_9: direction <= 1;
//			 endcase
//			 
//			 case(direction)
//				1'b0: r_CNT_2 = r_CNT_2 + 1;	// right to left
//				1'b1: r_CNT_2 = r_CNT_2 - 1;	// left to right
//			 endcase
//		  end // if success
		 
	 end //end always
	
	 // light up the LEDs
    assign led[0] = r_TOGGLE[0];
    assign led[1] = r_TOGGLE[1];
    assign led[2] = r_TOGGLE[2]; 
    assign led[3] = r_TOGGLE[3];
    assign led[4] = r_TOGGLE[4]; 
    assign led[5] = r_TOGGLE[5];
    assign led[6] = r_TOGGLE[6];
    assign led[7] = r_TOGGLE[7]; 
	
endmodule

