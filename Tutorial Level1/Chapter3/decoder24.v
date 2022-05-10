/* 	
File name: decoder24
Module Function: Implementation of a 2-4 decoder module (without Enable)

This example code can also be found in Chapter 3 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

module decoder24 (
   input      [1: 0] A,			// 2 input signals, MSB is A[1]          
   output reg [3: 0] Y      	// 4 output signals, MSB is Y[3], LSB is Y[0]
 )  ; 	
	
always @ (A) begin				// This block statement takes place when A changes
    case  (A)  
        2'b00:  Y = 4'b0001;    // 4'b0001 means it is a 4 bit binary number of 0001
        2'b01:  Y = 4'b0010; 
        2'b10:  Y = 4'b0100; 
        2'b11:  Y = 4'b1000; 
    endcase
end
endmodule
