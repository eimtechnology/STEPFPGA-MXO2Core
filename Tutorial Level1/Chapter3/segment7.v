/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			segment7.v
*- Top Module name: 	segment7
  - Submodules:		N/A
*- Description:			Implementation of a 7-segment display driver (common cathod)
*- 
*- Example of Usage:
	You can implement this code on all variants of STEPFPGA family boards. 
	If you want to implement this code on board and observe the logic behaviors: 
		- assign seg_data[3]...seg_data[0] to the 4 on-board swiches
		- assign segment_led[8] to SEG, segment_led[7] to DP
		- assign segment_led[6]...segment_led[0] to 'g, f, ... a' accordingly

* - Additional comments: 	 
   If you want to display decimal numbers only, the 4-bit input data must be in BCD converted
   form; will explain in Chapter 5 when implement the Elevator project. 

*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module segment7 (
    input  wire [3:0] seg_data,       // The 4 bit input data in binary form	
    output reg  [8:0] segment_led	  //  9 output for the 7-segment LEDs from MSB to LSB: SEG, DP, g, f, e, d, c, b, a
) ; 
always @ (seg_data) begin
    case  (seg_data) 
      4'b0000: segment_led = 9'h3f;   //  0
      4'b0001: segment_led = 9'h06;   //  1
      4'b0010: segment_led = 9'h5b;   //  2
      4'b0011: segment_led = 9'h4f;   //  3
      4'b0100: segment_led = 9'h66;   //  4
      4'b0101: segment_led = 9'h6d;   //  5
      4'b0110: segment_led = 9'h7d;   //  6
      4'b0111: segment_led = 9'h07;   //  7
      4'b1000: segment_led = 9'h7f;   //  8
      4'b1001: segment_led = 9'h6f;   //  9
      4'b1010: segment_led = 9'h77;   //  A
      4'b1011: segment_led = 9'h7C;   //  b
      4'b1100: segment_led = 9'h39;   //  C
      4'b1101: segment_led = 9'h5e;   //  d
      4'b1110: segment_led = 9'h79;   //  E
      4'b1111: segment_led = 9'h71;   //  F
    endcase
 end
endmodule
