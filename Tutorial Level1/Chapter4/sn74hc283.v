/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
File name: sn74hc283
Module Function: 4-bit Binary Full Adder

This code implement the logic functions of a 74xx IC on STEPFPGA board using Verilog. The Pin# in the code 
match to the Pin definitions specified in Texas Instrument datasheet for corresponding 74xx chips.

This example code can also be found in Chapter 4 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

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












