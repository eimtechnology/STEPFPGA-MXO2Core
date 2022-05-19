/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			sn74hc08.v
*- Top Module name: 	sn74hc08
  - Submodules:		N/A
*- Description:			Implement the logic functions of a Quad 2-input AND gate
*- 
*- Example of Usage:
	You can assign the input and output pins of this module to the GPIOs of the STEPFPGA board
	To observe the logic behavior, you may need additional components such as swiches, pushbuottons
	LEDs, resistors...and build the circuit on a breadboard or other medias. 
	
*- This code is for educational purposes only and hold no reliability for any industrial/commerical usages

*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

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












