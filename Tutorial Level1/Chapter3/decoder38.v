/* 	
File name: decoder38
Module Function: Implementation of a 3-8 decoder module

This example code can also be found in Chapter 3 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

//This decoder 38 module is built by instantiate TWO 2-4 decoders
module decoder38 (
  input wire [2: 0] X,		// 3 input signals 
  output wire [7: 0] D		// 8 output signals
) ; 

// Submodule 1
// Instantiate the first 2-4 decoder  (with Enable),
decoder24_en upper (
      .A   (X[1: 0]),      	// connect wires to the submodules
      .EN  (X[2]),         
      .Y   (D[7: 4])       
); 

// Submodule 2
// Instantiate the second 2-4 decoder  (with Enable)
decoder24_en lower (
      .A   (X[1: 0]) ,      
      .EN  (!X[2]) ,        
      .Y   (D[3: 0])       
) ;  
endmodule


// You can put the Submodule here
// For a seperate .v file but put in the same project directory
module decoder24_en   (
    input wire [1:0] A,             
    input wire EN,                  
    output reg [3:0] Y              
); 

always @ (EN,  A) begin
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
