/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			sn74hc165.v
*- Top Module name: 	sn74hc165
  - Submodules:		N/A
*- Description:			Implement the logic functions of an 8-bit Parallel-load Shift Registers
*- 
*- Example of Usage:
	You can assign the input and output pins of this module to the GPIOs of the STEPFPGA board
	To observe the logic behavior, you may need additional components such as swiches, pushbuottons
	LEDs, resistors...and build the circuit on a breadboard or other medias. 
	
*- This code is for educational purposes only and hold no reliability for any industrial/commerical usages

*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module sn74hc165 (pin1,pin2,pin3,pin4,pin5,pin6,pin7,pin8,
				pin9,pin10,pin11,pin12,pin13,pin14,pin15,pin16);
				
input pin3,pin4,pin5,pin6,pin11,pin12,pin13,pin14;	
input pin2,pin15;									
input pin1;					     		   			
input pin10;										
output pin8,pin16;			       				 		
output pin7,pin9;									

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













