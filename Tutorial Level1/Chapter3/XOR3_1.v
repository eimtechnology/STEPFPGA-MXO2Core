/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			XOR3_1.v
*- Top Module name: 	XOR3_1
  - Submodules:		xor (Verilog built-in primitive gates)
*- Description:			Implementation of a 3 input XOR gate
*- 
*- Example of Usage:
	You can implement this code on all variants of STEPFPGA family boards. 
	If you want to implement this code on board and observe the logic behaviors: 
		- assign A, B, C to 3 on-board switches
		- assign Y to any on-board LEDs

*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */
module XOR3_1 (       
    input wire  A,    
    input wire  B,    
    input wire  C,    
    output wire Y     
) ;                      
    xor  (Y, A, B, C) ;   
endmodule            
