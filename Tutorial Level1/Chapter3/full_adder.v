/* 	
File name: full_adder
Module Function: Implementation of a 1-bit full adder

This code implements 1-bit full adder using dataflow method.
This code can also be found in Chapter 3 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

module full_adder (
   input wire a,           
   input wire b,  
   input wire cin,  
   output wire sum,         
   output wire co
); 
   assign sum = a^b^cin;
   assign co = ((a^b)&cin)|(a&b);
endmodule
