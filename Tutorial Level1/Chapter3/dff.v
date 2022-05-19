/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			dff.v
*- Top Module name: 	dff
  - Submodules:		N/A
*- Description:			Implementation of a 1-bit D Flip-Flop
*- 
*- Example of Usage:
	You can implement this code on all variants of STEPFPGA family boards. 
	If you want to implement this code on board and observe the logic behaviors: 
		- assign clk to PCLK signal (12MHz)
		- assign D to any on-board switches
		- assign Q to any on-board LEDs 
		
*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module dff(
	input clk, 
	input D, 
	output reg Q
);
    always @ (posedge clk) begin
        Q <= D;
    end
endmodule
