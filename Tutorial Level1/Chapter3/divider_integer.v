/* 	
File name: divider_integer
Module Function: Implementation of a clock frequency divider

This code implements a clock divider which supports for all integer divisors. 
Note: if the divisor is 'odd' number, the output duty cycle is not exactly 50%; but if the divider is higher than
99 you can practically neglect this.

This example code can also be found in Chapter 3 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

// To set for different divisor, you only need to change these two parameters
module divider_integer # (           
    parameter   N     = 12000000,	// the divisor
    parameter   WIDTH = 24 			// the minimum bit-width to hold this divisor
)  
(
    input clk,
    output reg clkout 
);
reg [WIDTH-1:0] cnt; 
always @ (posedge clk) begin
    if(cnt>=(N-1))
        cnt <= 1'b0;
    else
        cnt <= cnt + 1'b1;
    clkout <= (cnt<N/2)?1'b1:1'b0;
end
endmodule
