/****************************************  File name: bin_to_bcd ************************************** 	
Module Function: Binary to BCD Code Converter

This example code is to accompany the BCD module in Chapter 5 of the STPFPGA tutorial book. 
This code converts a 16 bit binary number to 4 BCD numbers. If you want to display numbers on
Segment Displays, you should use BCD data. Note that BCD data may have extra bits.  

Copyright License: MIT
********************************************************************************************************/ 

module bin_to_bcd (
	input				rst_n,
	input		[15:0]	bin_code,	
	output	reg	[19:0]	bcd_code	
);
reg		[35:0]		shift_reg; 
always @ (bin_code or rst_n) begin
	shift_reg = {20'h0,bin_code};
	if(!rst_n) bcd_code = 0; 
	else begin 
		repeat(16) begin // repeat for 16 times
			if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 2'b11;
			if (shift_reg[23:20] >= 5) shift_reg[23:20] = shift_reg[23:20] + 2'b11;
			if (shift_reg[27:24] >= 5) shift_reg[27:24] = shift_reg[27:24] + 2'b11;
			if (shift_reg[31:28] >= 5) shift_reg[31:28] = shift_reg[31:28] + 2'b11;
			if (shift_reg[35:32] >= 5) shift_reg[35:32] = shift_reg[35:32] + 2'b11;
			shift_reg = shift_reg << 1; 
		end
		bcd_code = shift_reg[35:16];   
	end  
end
endmodule