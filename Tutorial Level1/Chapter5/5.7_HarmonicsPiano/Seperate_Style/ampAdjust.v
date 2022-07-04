/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			ampAdjust.v
*- Top Module name: 	ampAdjust
  - Submodules:		N/A
*- Description:			Adjust the amplitude of a 10-bit digital signal
*- 
*- Example of Usage:
       - This code allows you to adjust the amplitude for a 10-bit digital signal. Most of the cases
	you can connect this module directly to the digital sinusoidal wave generator 'sin_anyfreq'.
       - The output of this module is also 10-bit, but by adjusting the parameter 'numerator' from 1 to 256
	will set the amplitude from 1/256 (0.4%) to 256/256 (100%). 

* - You can connect a parallel input 10 bit DAC to view the analog sinusoidal wave
   - Or you can connect it to 'sigma2delta' to generate a 1-bit DAC using PDM.

* - Read more details in Chapter 5 of the tutorial book.
   
*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module ampAdjust 
#(parameter numerator = 256)					// Divide the amplitude into 256 pieces, the amplitude resolution is 1/256
(	
    input clk,
    input [9:0] digitalSignal,
    output[9:0] dac_Data
);

reg [17:0] amp_data;
always @(posedge clk) 
	amp_data = digitalSignal * numerator;		
	
assign dac_Data = amp_data[17:8]; 			// Take the 10 most significant bits; equaivlent to right shift 8 bits
endmodule