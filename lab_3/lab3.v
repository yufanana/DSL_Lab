`timescale 1ns / 1ps
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

    // all unused outputs must be assigned
    assign vgaRed = 3'b111;
	 assign vgaGreen = 3'b111;
	 assign vgaBlue = 2'b11;
	 assign hsync = 1'b1;
	 assign vsync = 1'b1;
	 
	 
  ////////////////////////////////////////////////////////////////////////////
	// EDIT FROM HERE

	 //assign led = 7'b000_0000;

    parameter c_CNT_2ms  = 200000; //number of clocks for 2 milliseconds with 100MHz clock
    reg [31:0] r_CNT_2ms = 0;
    reg [1:0] TOGGLE_2ms = 2'b00;  //used for multiplexing 4 seven segments
    
    parameter c_CNT_1sec  = 100000000; //number of clocks for 1 second with 100MHz clock
    reg [31:0] r_CNT_1sec = 0;
      
    reg [15:0] displayed_number;    //counting number to be displayed
    reg [3:0] segment_pattern;
    reg [3:0] dig;  
    reg [7:0] seg;

    // count r_CNT_2ms    0      ->    1        ->    2      ->    3
    // activates      segment 1    segment 2      segment 3     segment 4
    // and repeat         
    always @ (posedge clk_100mhz)   
    begin
      if (r_CNT_2ms == c_CNT_2ms-1) // -1, since counter starts at 0
        begin    
       r_CNT_2ms    <= 0;
       if (TOGGLE_2ms == 3)
        TOGGLE_2ms <=0;
       else 
        TOGGLE_2ms <=TOGGLE_2ms+1;         
        end
      else
        r_CNT_2ms <= r_CNT_2ms + 1;
    end 
	
    always @ (posedge clk_100mhz)
    begin
      if (r_CNT_1sec == c_CNT_1sec-1) // -1, since counter starts at 0
        begin        
          displayed_number <= 'b0;   //displaying number
          r_CNT_1sec    <= 0;
       displayed_number <= displayed_number + 1'b1;
        end
      else
        r_CNT_1sec <= r_CNT_1sec + 1;
    end
   

   always @(TOGGLE_2ms)
    begin
        case(TOGGLE_2ms)
        2'b00: begin
          dig = 4'b0111; //activate first seven segment and deactivate other 3 seven segments
          segment_pattern = ((displayed_number % 3600)/60)/10; //the first digit of the displaying number
              end
        2'b01: begin
          dig = 4'b1011; //activate second seven segment and deactivate other 3 seven segments
          segment_pattern = ((displayed_number % 3600)/60)%10; //the second digit of the displaying number ("%" is the modulo operator, e.g., 13%10 = 3, 555%100 = 55)
              end
        2'b10: begin
          dig = 4'b1101; //activate third seven segment and deactivate other 3 seven segments
          segment_pattern = ((displayed_number % 3600)%60)/10; //the third digit of the displaying number ("%" is the modulo operator, e.g., 13%10 = 3, 555%100 = 55)
                end
        2'b11: begin
          dig = 4'b1110; //activate forth seven segment and deactivate other 3 seven segments
          segment_pattern = ((displayed_number % 3600)%60)%10; //the fourth digit of the displaying number ("%" is the modulo operator, e.g., 13%10 = 3, 555%100 = 55)    
               end
        endcase
    end
   
     
    always @(segment_pattern) // Cathode patterns of the 7-segment display
    begin
        case(segment_pattern)
        4'b0000: seg = 8'b11000000; // "0"     
        4'b0001: seg = 8'b11111001; // "1" 
        4'b0010: seg = 8'b10100100; // "2" 
        4'b0011: seg = 8'b10110000; // "3" 
        4'b0100: seg = 8'b10011001; // "4" 
        4'b0101: seg = 8'b10010010; // "5" 
        4'b0110: seg = 8'b10000010; // "6" 
        4'b0111: seg = 8'b11111000; // "7" 
        4'b1000: seg = 8'b10000000; // "8"     
        4'b1001: seg = 8'b10010000; // "9" 
        default: seg = 8'b11000000; // "0"
        endcase
    end
	 
	 
 
endmodule
