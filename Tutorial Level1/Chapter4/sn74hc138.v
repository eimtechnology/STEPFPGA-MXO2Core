/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
File name: sn74hc138
Module Function: 3-to-8 Line Decoder/Demultiplexer; Inverting Output

This code implement the logic functions of a 74xx IC on STEPFPGA board using Verilog. The Pin# in the code 
match to the Pin definitions specified in Texas Instrument datasheet for corresponding 74xx chips.

This example code can also be found in Chapter 4 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

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

