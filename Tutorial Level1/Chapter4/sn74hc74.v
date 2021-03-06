/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			sn74hc74.v
*- Top Module name: 	sn74hc74
  - Submodules:		N/A
*- Description:			Implement the logic functions of a Dual Positive Edge Triggered D-Flipflop
*- 
*- Example of Usage:
	You can assign the input and output pins of this module to the GPIOs of the STEPFPGA board
	To observe the logic behavior, you may need additional components such as swiches, pushbuottons
	LEDs, resistors...and build the circuit on a breadboard or other medias. 
	
*- This code is for educational purposes only and hold no reliability for any industrial/commerical usages

*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module sn74hc74 (pin1,pin2,pin3,pin4,pin5,pin6,pin7,pin8,
pin9,pin10,pin11,pin12,pin13,pin14);

input  pin3,pin11;					// 2 inputs for CLOCK
input  pin1,pin13;		 			// 2 inputs for RESET
input  pin4,pin10;		 			// 2 inputs for SET
input  pin2,pin12;					// 2 inputs for DATA
output pin7,pin14;			        // Connects to VCC and GND
output pin5,pin6,pin8,pin9;        	    

wire clk1,clk2,reset1_n,reset2_n,set1_n,set2_n,d1,d2;
reg [1:0] q1,q2;

assign pin7 = 1'b0;
assign pin14 = 1'b1;
assign clk1 = pin3;
assign clk2 = pin11;
assign reset1_n = pin1;
assign reset2_n = pin13;
assign set1_n = pin4;
assign set2_n = pin10;
assign d1 = pin2;
assign d2 = pin12;
assign pin5 = q1[1];		//1Q
assign pin6 = q1[0];		//1Q'
assign pin9 = q2[1];		//2Q
assign pin8 = q2[0];		//2Q'

//Building the first channel of D flipflop; 
always @(negedge reset1_n or negedge set1_n or posedge clk1) begin
	if(reset1_n==0) 
		q1<=2'b01;
	else if(set1_n==0) 
		q1<=2'b10;
	else 
		q1<={d1,~d1};
end

//Building the second channel of D flipflop
always@(negedge reset2_n or negedge set2_n or posedge clk2) begin
	if(reset2_n==0) 
		q2<=2'b01;
	else if(set2_n==0) 
		q2<=2'b10;
	else 
		q2<={d2,~d2};
end
endmodule
