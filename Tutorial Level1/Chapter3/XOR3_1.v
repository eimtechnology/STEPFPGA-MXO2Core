/* 	
File name: XOR3_1
Module Function: Implementation of a 3 input XOR gate

This code can also be found in Chapter 3 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

module XOR3_1 (       
    input wire  A,    
    input wire  B,    
    input wire  C,    
    output wire Y     
) ;                      
    xor  (Y, A, B, C) ;   
endmodule            
