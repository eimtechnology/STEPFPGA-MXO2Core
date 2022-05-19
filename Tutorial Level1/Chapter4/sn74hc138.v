/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			sn74hc138.v
*- Top Module name: 	sn74hc138
  - Submodules:		N/A
*- Description:			Implement the logic functions of a 3-to-8 Line Decoder/Demultiplexer with Inverting Output
*- 
*- Example of Usage:
	You can assign the input and output pins of this module to the GPIOs of the STEPFPGA board
	To observe the logic behavior, you may need additional components such as swiches, pushbuottons
	LEDs, resistors...and build the circuit on a breadboard or other medias. 
	
*- This code is for educational purposes only and hold no reliability for any industrial/commerical usages

*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module sn74hc138 (pin1,pin2,pin3,pin4,pin5,pin6,pin7,pin8,
pin9,pin10,pin11,pin12,pin13,pin14,pin15,pin16);
				
input pin1,pin2,pin3;			// 3 inputs corresponding to the address location 
input pin4,pin5,pin6;			// 3 inputs for Enable
output pin7,pin9,pin10,pin11,pin12,pin13,pin14,pin15;
output pin8,pin16;				// connects to VCC and GND

// ***** intermediate signals *****
wire 	[2:0] a ;
reg 	[7:0] q ;
wire sel;					

assign pin8 = 1'b0;
assign pin16 = 1'b1;
assign a = {pin3,pin2,pin1};
assign sel = (~pin4)&(~pin5)& pin6;
assign pin7 = q[7];
assign pin9 = q[6];
assign pin10 = q[5];
assign pin11 = q[4];
assign pin12 = q[3];
assign pin13 = q[2];
assign pin14 = q[1];
assign pin15 = q[0];

always@(a,sel) begin
	if(!sel)
			q = 8'b1111_1111;
	else begin
		case(a)
			3'b000: q = 8'b1111_1110;
			3'b001: q = 8'b1111_1101;
			3'b000: q = 8'b1111_1011;
			3'b000: q = 8'b1111_0111;
			3'b000: q = 8'b1110_1111;
			3'b000: q = 8'b1101_1111;
			3'b000: q = 8'b1011_1111;
			3'b000: q = 8'b0111_1111;
			default:q = 8'b1111_1111;
		endcase
	end
end
endmodule

