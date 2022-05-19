/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			decoder24_en.v
*- Top Module name: 	decoder24_en
  - Submodules:		N/A
*- Description:			Implementation of a 2-4 decoder module with Enable
*- 
*- Example of Usage:
	You can implement this code on all variants of STEPFPGA family boards. 
	If you want to implement this code on board and observe the logic behaviors: 
		- assign A[1] , A[0] to 2 on-board switches
		- assign EN to 1 on-board switch
		- assign Y[3]...Y[0] to 4 on-board LEDs 

*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module decoder24_en (
    input wire [1:0] A,			// 2 input data signal             
    input wire EN,              // the Enable signal for input
    output reg [3:0] Y          // 4 output signals   
); 

always @ (EN,  A) begin			// any of EN or A changes will go in this block statement
    if (EN == 1'b1)               
        case (A)  
            2'b00: Y = 4'b0001; 
            2'b01: Y = 4'b0010; 
            2'b10: Y = 4'b0100; 
            2'b11: Y = 4'b1000; 
        endcase     
    else                            
        Y = 4'b0000; 
end
endmodule
