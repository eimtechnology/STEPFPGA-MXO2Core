/* 	
File name: decoder24_en
Module Function: Implementation of a 2-4 decoder module with Enable

This example code can also be found in Chapter 3 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

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
