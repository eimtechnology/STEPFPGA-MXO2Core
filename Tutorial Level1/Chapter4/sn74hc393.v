/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			sn74hc393.v
*- Top Module name: 	sn74hc393
  - Submodules:		N/A
*- Description:			Implement the logic functions of a Dual 4-Stage Binary Counter
*- 
*- Example of Usage:
	You can assign the input and output pins of this module to the GPIOs of the STEPFPGA board
	To observe the logic behavior, you may need additional components such as swiches, pushbuottons
	LEDs, resistors...and build the circuit on a breadboard or other medias. 
	
*- This code is for educational purposes only and hold no reliability for any industrial/commerical usages

*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module sn74hc393 (pin1,pin2,pin3,pin4,pin5,pin6,pin7,pin8,
pin9,pin10,pin11,pin12,pin13,pin14);
				
input pin1,pin13;										// two Clock signal
input pin2,pin12;										// two Clear enable signal
output pin7,pin14;										// Connects to VCC and GND			
output pin3,pin4,pin5,pin6,pin11,pin10,pin9,pin8;		// two 4-bit Binary counter output

wire	clk1,clk2,clr1,clr2;
reg		[3:0]	count1,count2;

assign pin7 = 1'b0;
assign pin14 = 1'b1;
assign clk1 = pin1;
assign clk2 = pin13;
assign clr1 = pin2;
assign clr2 = pin12;
assign pin3 = count1[0];
assign pin4 = count1[1];
assign pin5 = count1[2];
assign pin6 = count1[3];
assign pin11 = count2[0];
assign pin10 = count2[1];
assign pin9  = count2[2];
assign pin8  = count2[3];

always@(negedge clk1 or posedge clr1)begin
	if(clr1)
		count1 <= 4'b0000;
	else begin
		if(count1 == 4'b1111)
			count1 <= 4'b0000;
		else
			count1 <= count1 + 1'b1;
	end 
end 

always@(negedge clk2 or posedge clr2)begin
	if(clr2)
		count2 <= 4'b0000;
	else begin
		if(count2 == 4'b1111)
			count2 <= 4'b0000;
		else
			count2 <= count2 + 1'b1;
	end 
end 
endmodule












