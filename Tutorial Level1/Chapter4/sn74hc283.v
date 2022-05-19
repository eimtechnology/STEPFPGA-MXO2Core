/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			sn74hc283.v
*- Top Module name: 	sn74hc283
  - Submodules:		N/A
*- Description:			Implement the logic functions of a 4-bit Binary Full Adder
*- 
*- Example of Usage:
	You can assign the input and output pins of this module to the GPIOs of the STEPFPGA board
	To observe the logic behavior, you may need additional components such as swiches, pushbuottons
	LEDs, resistors...and build the circuit on a breadboard or other medias. 
	
*- This code is for educational purposes only and hold no reliability for any industrial/commerical usages

*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */


module sn74hcf283 (pin1,pin2,pin3,pin4,pin5,pin6,pin7,pin8,
pin9,pin10,pin11,pin12,pin13,pin14,pin15,pin16);
				
input pin5,pin3,pin14,pin12,pin6,pin2,pin15,pin11;		// two 4-bit Addends
input pin7;												// Initial Carry input
output pin9;											// Final Carry output
output pin8,pin16;										// Connect to VCC and GND			
output pin4,pin1,pin13,pin10;							// 4-bit output Sum

wire	[3:0]	a,b,sum;
wire			ci,co;

assign pin8 = 1'b0;
assign pin16 = 1'b1;
assign a[0] = pin5;
assign a[1] = pin3;
assign a[2] = pin14;
assign a[3] = pin12;
assign b[0] = pin6;
assign b[1] = pin2;
assign b[2] = pin15;
assign b[3] = pin11;
assign ci = pin7;
assign pin9 = co;
assign pin4 = sum[0];
assign pin1 = sum[1];
assign pin13 = sum[2];
assign pin10 = sum[3];

assign {co,sum} = a + b + ci;

endmodule












