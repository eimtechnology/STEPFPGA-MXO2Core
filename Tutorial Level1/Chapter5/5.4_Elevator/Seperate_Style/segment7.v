module segment7
 (
    input  wire [3:0] seg_data,        
    output reg  [8:0] segment_led  
    //  MSB~LSB = SEG,  DP,  g,  f e,  d,  c,  b,  a
) ; 
always @  (seg_data)  begin
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
