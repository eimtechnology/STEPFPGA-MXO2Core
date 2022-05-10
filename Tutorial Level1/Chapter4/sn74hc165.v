/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
File name: sn74hc165
Module Function: 8-bit Parallel-load Shift Registers

This code implement the logic functions of a 74xx IC on STEPFPGA board using Verilog. The Pin# in the code 
match to the Pin definitions specified in Texas Instrument datasheet for corresponding 74xx chips.

This example code can also be found in Chapter 4 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

module sn74hc165 (pin1,pin2,pin3,pin4,pin5,pin6,pin7,pin8,
				pin9,pin10,pin11,pin12,pin13,pin14,pin15,pin16);
				
input pin3,pin4,pin5,pin6,pin11,pin12,pin13,pin14;	//八位并行输入
input pin2,pin15;									//时钟（两者相或运算）
input pin1;					     		   			//寄存器加载使能
input pin10;										//移位后末位补0还是补1
output pin8,pin16;			       				 	//GND VCC				
output pin7,pin9;									//Q和~Q

wire   [7:0]  data;
wire          clk,load,sel;
reg    [7:0]  q;

assign pin8 = 1'b0;
assign pin16= 1'b1;
assign data[0]=pin11;
assign data[1]=pin12;
assign data[2]=pin13;
assign data[3]=pin14;
assign data[4]=pin3;
assign data[5]=pin4;
assign data[6]=pin5;
assign data[7]=pin6;
assign clk=pin2|pin15;
assign load=pin1;
assign pin9=q[7];	//Q
assign pin7=~q[7];	//~Q
assign sel=pin10;

always@(posedge clk or negedge load) begin
	if(!load) 
		q<=data;
	else 
		q<={q[6:0],sel};
end

endmodule













