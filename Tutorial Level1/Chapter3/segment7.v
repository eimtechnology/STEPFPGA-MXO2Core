/* 	
File name: segment7
Module Function: Implementation of a 7-segment display driver

This code implements a 7-segment display driver.
This code can also be found in Chapter 3 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

/* Option 1: if you want to manually display a number from 0 to F, you can connect the 4 input wires to four switches */

/* Option 2: if you want to display a hex data on 7-segment which was sent out from other modules, you can connect the 
4 bit output data from that module directly to the 4 bit inputs of the segment7 */

/* Option 3: if if you want to display a decimal data on 7-segment sent out from other modules, you  need to use Binary to
BCD converter first, then connect the 4 bit data to this module's inputs.  */

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
