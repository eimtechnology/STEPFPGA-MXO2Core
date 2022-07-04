/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			sin_anyfreq.v
*- Top Module name: 	sin_anyfreq
  - Submodules:		lookup_tables, SINE_LUT
*- Description:			Generate arbitrary frequency 10-bit sin wave
*- 
*- Example of Usage:
	Refer to the STEPFPGA tutorial book Chapter 5 for more details
		f_out = M * f_clk/(2^N), since f_clk = 12MHz, N = 32 bit, so we have:
			M = f_out * 358
	To obtain any desired frequency of the sinusoidal signal, you only need to tune for M
* - You can connect a parallel input 10 bit DAC to view the analog sinusoidal wave

*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module sin_anyfreq # (
    parameter M = 93664				// Tune this value for different frequencies of the SIN wave
									// For M = 93664, you will get f_out = 261.63Hz
)
(
	input clk,               
	output [9:0] sin_digital      
);
	
reg [31:0] 	phase_acc;				// Here we used N = 32 thus the phase accumulator has 2^N states!
always @(posedge clk) begin
	phase_acc <= phase_acc + M;  	
end

lookup_tables u1 (
	.phase(phase_acc[31:24]), 		// Taking the first 8 bits from the phase accumulator
	.sin_out(sin_digital)			// - is sufficient for a decently smooth sin wave
);
endmodule


 
