/* 	
File name: elevatorCtrl
Module Function: The full packaged elevatorCtrl module for Elevator Control project

This example code can also be found in Chapter 5.3 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

module elevatorCtrl(
	input clk, rst_n , 					// connect to system clock 12MHz and a pushbutton for reset
	input echo, 						// reads the ECHO signal from HC_SR04; use external GPIO of STEPFPGA
	output trig,                   		// send trigger pulse to HC_SR04 module; use external GPIO of STEPFPGA
	input [4:0] key,                    // reads voltage levels of 5 pushbuttons; use external 5 GPIOs of STEPFPGA
	input  switch,	
	output motoren,
	output move1,                       // for 1A and 2A of L293 motor driver; use external 2 GPIOs of STEPFPGA
	output move2,
	output [8:0] segment_led_1,			// assign to the right on-board 7-Segment display 
	output [8:0] segment_led_2			// assign to the left on-board 7-Segment display 
);

wire 	[2:0]   state;
wire	[15:0] distance;
assign 	seg_data_1 = distance[7:4];
assign 	seg_data_2 = distance[3:0];

/****************************** Instantiate the Ultrasonic Sensor Module ********************************
	>>	The Ultrasonic module HC_SR04 measures the distance 
*************************************************************************************************************/		
hc_sr04 u2(
		.clk(clk),				
		.rst_n(rst_n),			
		.echo(echo),			
		.trig(trig),			
		.distance(distance)
);	

/***************************************  Display of Measured Distance  **********************************
	>>	The previous module gives a 16 bit distance data measured by the HC_SR04 sensor
	If you want to display this data on 7-segment display, change the data to BCD so it only displays
	digital numbers from 0 to 9
	>>	Instantiate the 7-segment display module
************************************************************************************************************/	
wire	[19:0] bcd_distance;		// intermediate wirings 
wire 	[3:0] bcd_digit1;						
wire 	[3:0] bcd_digit2;
assign 	bcd_digit1 = bcd_distance[3:0];
assign 	bcd_digit2 = bcd_distance[7:4];

bin_to_bcd u21(
	.rst_n		(rst_n),			
	.bin_code	(distance),			
	.bcd_code	(bcd_distance)		
);		
segment7 seg_x1(					// display the first Decimal digit of the measured distance
		.seg_data(bcd_digit1),
		.segment_led (segment_led_1)
);
segment7 seg_x10(					// display the second Decimal digit of the measured distance
		.seg_data(bcd_digit2),
		.segment_led (segment_led_2)
);

/************************************** Elevator Movement Control  **************************************
	>>	Instantiate the motor control module
*************************************************************************************************************/	
movement_ctrl u16(
		.clk(clk) ,
		.rst_n(rst_n) ,
		.distance(distance),
		.key(key),
		.switch4enable(switch),
		.enable(motoren),
		.move1(move1),
		.move2(move2)
);
endmodule