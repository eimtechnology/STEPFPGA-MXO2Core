/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			decoder24.v
*- Top Module name: 	decoder24_en
  - Submodules:		N/A
*- Description:			Implementation of a 2-4 decoder module (without Enable)
*- 
*- Example of Usage:
	You can implement this code on all variants of STEPFPGA family boards. 
	If you want to implement this code on board and observe the logic behaviors: 
		- assign A[1] , A[0] to 2 on-board switches
		- assign Y[3]...Y[0] to 4 on-board LEDs 
	
*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module decoder24 (
   input      [1: 0] A,			// 2 input signals, MSB is A[1]          
   output reg [3: 0] Y      	// 4 output signals, MSB is Y[3], LSB is Y[0]
); 	

always @ (A) begin				// This block statement takes place when A changes
    case  (A)  
        2'b00:  Y = 4'b0001;    // 4'b0001 means it is a 4 bit binary number of 0001
        2'b01:  Y = 4'b0010; 
        2'b10:  Y = 4'b0100; 
        2'b11:  Y = 4'b1000; 
    endcase
end
endmodule
