/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			full_adder.v
*- Top Module name: 	full_adder
  - Submodules:		N/A
*- Description:			Implementation of a 1-bit Full Binary Adder
*- 
*- Example of Usage:
	You can implement this code on all variants of STEPFPGA family boards. 
	If you want to implement this code on board and observe the logic behaviors: 
		- assign a, b, cin to 3 on-board switches
		- assign sum, co to any 2 on-board LEDs
		
*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module full_adder (
   input wire a,           
   input wire b,  
   input wire cin,  
   output wire sum,         
   output wire co
); 
   assign sum = a ^ b ^ cin;		// dataflow description manner
   assign co = ((a^b)&cin)|(a&b);	// Use mathematical operators
endmodule
