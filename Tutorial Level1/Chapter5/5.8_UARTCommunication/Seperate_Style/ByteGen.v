/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			ByteGen.v
*- Top Module name: 	ByteGen
  - Submodules:		
*- Description:			Generating output data in Bytes
					
*- Example of Usage:
       - This code takes a continous pulse signal as input and send the data in Bytes. We used
       this module to convert the output pulse of the Rotary Encoder into Bytes which to be sent
       out through the UART_Transmitter module
	
* - Read more details in Chapter 5 (UART Communication) of the tutorial book.
   
*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module ByteGen (
	input				clk,rst_n,			
	input				pulse1, pulse2,
	output	reg	[7:0]	dataByte
);

//key_pulse transfer to dataByte
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		dataByte <= 8'b0000_0000;
	end else begin
		if(pulse1) begin
			dataByte <= dataByte - 1'b1;
		end 
		else if(pulse2) begin
			dataByte <= dataByte + 1'b1;
		end 
		else begin
			dataByte <= dataByte;
		end
	end
end