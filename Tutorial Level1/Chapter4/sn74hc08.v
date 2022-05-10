/* 	
File name: sn74hc08
Module Function: Quadruple 2-Input AND Gates 

This code implement the logic functions of a 74xx IC on STEPFPGA board using Verilog. The Pin# in the code 
match to the Pin definitions specified in Texas Instrument datasheet for corresponding 74xx chips.

This example code can also be found in Chapter 4 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

module sn74hc08 (pin1,pin2,pin3,pin4,pin5,pin6,pin7,pin8,
pin9,pin10,pin11,pin12,pin13,pin14);
				
input  pin1,pin2,pin4,pin5,pin9,pin10,pin12,pin13;				                            
output pin3,pin6,pin8,pin11;                  
output pin7,pin14;				// connects to Vcc and GND

wire A1,B1,Y1,A2,B2,Y2,A3,B3,Y3,A4,B4,Y4;

assign A1 = pin1;
assign B1 = pin2;
assign A2 = pin4;
assign B2 = pin5;
assign A3 = pin9;
assign B3 = pin10;
assign A4 = pin12;
assign B4 = pin13;
assign pin3 = Y1;
assign pin6 = Y2;
assign pin8 = Y3;
assign pin11 = Y4;

assign pin7 = 1'b0;
assign pin14 = 1'b1;
assign Y1 = A1 & B1;
assign Y2 = A2 & B2;
assign Y3 = A3 & B3;
assign Y4 = A4 & B4;

endmodule












