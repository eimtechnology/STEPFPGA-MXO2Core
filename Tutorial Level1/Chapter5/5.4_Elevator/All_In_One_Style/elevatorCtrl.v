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
hc_sr04 hc_sr04_U(
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

bin_to_bcd bin_to_bcd_U(
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


/*************** Module Definition for a ultrasonic sensor interface module *********************/

module hc_sr04 (
	input clk, rst_n,				// STPFFPGA has on board frequency of 12MHz  
	input echo,						// Module input, connects to HC_SR04 -> echo
	output trig,					// Module output, connects to HC_SR04 -> trig 
	
	/* This 16 bit data gives the measured distance (in binary form) of HC_SR04 sensor; and you
	can connect this 16 wires to other modules */
	output reg [15:0] distance  	
);						

/****************************************   Generate a 10us pulse  ************************************
	>>	This piece of code generates a 10us pulse to enable trigger of the HC_SR04 sensor 			
  ******************************************************************************************************/	
	reg [25:0] cnt_10us;		// Counter for generating 10us pulse
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) begin
			cnt_10us <= 0;
		end
		else if(cnt_10us == 11_999_999)
			cnt_10us <= 0;
		else
			cnt_10us <= cnt_10us + 1'b1;
	end
	assign trig = (cnt_10us < 120) ? 1:0;

/*********************************   Edge detection of Echo signal  *****************************
	>>	This piece of code detects the rising edge and falling edge of Echo signal
	>>	when 'pose_echo' is 1, rising edge; when 'nege_echo' is 1, falling edge		
  *************************************************************************************************/	
	reg echo_2;
	reg echo_1;
	wire pose_echo;
	wire nege_echo;
	always @(posedge clk17k or negedge rst_n)begin
		if(!rst_n)begin
			echo_1 <= 0;
			echo_2 <= 0;
		end
		else begin
			echo_1 <= echo;
			echo_2 <= echo_1;
		end
	end
	assign pose_echo = echo_1 && (~echo_2);
	assign nege_echo = (~echo_1) && echo_2;

/***********************************   Generate a 17kHz pulse  **********************************
	>>	This piece of code generates a 17kHz pulse signal
	>>	By calculation (see Chapter 5 of the book), each pulse corresponds to 1cm
	of the real distance measured by the HC_SR04 ultrasonic sensor.  			
  *************************************************************************************************/
	reg clk17k;
	reg [15:0] cnt17k;		   // Counter for a 17KHz signal (explained in the book)
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			cnt17k <= 0;
		end
		else if(cnt17k == 706)			// divide 12MHz by 706 times will get 17kHz
			cnt17k <= 0;
		else
			cnt17k <= cnt17k + 1;
	end
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)
			clk17k <= 0;
		else if(cnt17k < 706>>1)
			clk17k <= 0;
		else
			clk17k <= 1;
	end
	
/*************************  Convert counter result to the actual distance  ************************
	>>	Since we have generated a 17kHz pulse, as soon as we detected the rising edge
	of the Echo, then the system starts counting how many pulses for clk17k, until a
	falling edge is received to stop counting. 
	>> 	Each pulse of 'clk17k' represents 1cm in the physical measurement		
*****************************************************************************************************/
	parameter S0 = 2'b00; 	// state S0 is when rising edge of echo is detected begin of distance measurement
	parameter S1 = 2'b01; 	// state S1 is when echo stays HIGH, and we will calculate distance in this state 
	parameter S2 = 2'b10; 	// state S2 is when falling edge of echo is detected, end of distance measurement
	reg [1:0] state;
	reg [15:0] cnt_dist;						// Counter for final measured distance with smallest unit of 'cm'
	always@(posedge clk17k or negedge rst_n)begin
		if(!rst_n)begin
			cnt_dist<= 0; 
			distance <= 0;
			state <= S0;
		end
		else
			begin
               case(state)
				S0:begin						// detected the rising edge of the echo signal
					cnt_dist <= 0;				// start to count for distance
					if (pose_echo) 				
						state <= S1;	
					else	
						state <= S0;	
				end	
				S1:begin						// the echo signal level stays HIGH	
					cnt_dist <= cnt_dist + 1;	// counts for distance, each 'cnt_dist' increments 1cm
					if (nege_echo) 				
						state <= S2;			
					else	
						state <= S1;	
                end	
				S2:begin	
					distance <= cnt_dist; 		// detected the falling edge of the echo signal
					cnt_dist <= 0;				// save the 'cnt_dist' result for the actual distance
					state <= S0;	
				end	
				default:begin					// default
					cnt_dist <= 0;	            
					state <= S0;	
				end	
        endcase	
    end	
end	
endmodule


/*************** Module Definition for a control the movement of a DC motor driver *********************/

module movement_ctrl(
	input clk, rst_n,			
	input [15:0] distance,			// The 16-bit 'distance' signal from HC_SR04 sensor 
	input [4:0] key,				// Connects to 5 pushbuttons, representing floor 1 to floor 5
	input switch4enable,			// The switch to manually enable/disable the DC motor
	output enable,				
	output reg move1, move2			// Controls DC motor driver
);
	
not  (enable, switch4enable);	// unless manually set, the DC motor is constantly enabled

/********************************************* Soft Decouncing ********************************************
	>>	This piece of code is a soft debouncing for mechanical switches
	>>	Here we have 5 keys, so instantiate this module five times
*************************************************************************************************************/	
wire [4:0] key_pulse;							// 5 signals for debounced pulses
debounce key_f1 (clk, key[0], key_pulse[0]);  	// Generate debounced pulses for key 0
debounce key_f2 (clk, key[1], key_pulse[1]); 	// ......
debounce key_f3 (clk, key[2], key_pulse[2]); 	// ......
debounce key_f4 (clk, key[3], key_pulse[3]); 	// ......
debounce key_f5 (clk, key[4], key_pulse[4]); 	// Generate debounced pulses for key 5

wire f1, f2, f3, f4, f5;
assign f1 = key_pulse[0];						// Assgin deboucned pulses to 'floor [4:0]'
assign f2 = key_pulse[1];
assign f3 = key_pulse[2];
assign f4 = key_pulse[3];
assign f5 = key_pulse[4];

/**************************** Elevator Movement Control State Machine *********************************
	>>	This piece implements the state machine for DC motor driver control  
	>>	At Floor 1, you
*************************************************************************************************************/	
// Defining 5 states and have them in binary coded form
parameter FLOOR1 = 3'b000;
parameter FLOOR2 = 3'b001;
parameter FLOOR3 = 3'b010; 
parameter FLOOR4 = 3'b011; 
parameter FLOOR5 = 3'b100;

// Segment 1
reg [2:0] cur_state, next_state;	
assign state = cur_state;
always @ (posedge clk) begin
	cur_state <= next_state;
end

// Segment 2
always @ (*) begin
	case(cur_state)
		FLOOR1:begin				
			if(f2)
				next_state = FLOOR2;
			else if (f3)
				next_state = FLOOR3;
			else if (f4)
				next_state = FLOOR4;
			else if (f5)
				next_state = FLOOR5;
			else
				next_state = FLOOR1;
		end
        FLOOR2:begin
			if(f1) 
				next_state = FLOOR1;
			else if (f3)
				next_state = FLOOR3;
			else if (f4)
				next_state = FLOOR4;
			else if (f5)
				next_state = FLOOR5;
			else
				next_state = FLOOR2;
		end
        FLOOR3:begin
			if(f1) 
				next_state = FLOOR1;
			else if(f2)
				next_state = FLOOR2;
			else if (f4)
				next_state = FLOOR4;
			else if (f5)
				next_state = FLOOR5;
			else
				next_state = FLOOR3;
		end
        FLOOR4:begin
			if(f1) 
				next_state = FLOOR1;
			else if(f2)
				next_state = FLOOR2;
			else if (f3)
				next_state = FLOOR3;
			else if (f5)
				next_state = FLOOR5;
			else
				next_state = FLOOR4;
		end
		FLOOR5:begin
			if(f1) 
				next_state = FLOOR1;
			else if(f2)
				next_state = FLOOR2;
			else if (f3)
				next_state = FLOOR3;
			else if (f4)
				next_state = FLOOR4;
			else
				next_state = FLOOR5;
		end
		default: next_state = FLOOR1;
	endcase
end

// Segment 3
// Motor actions in each state
// Each floor hight of the elevator kit is approximately 5cm
always @ (posedge clk) begin		// synchronize all results with clk signal
	case(next_state)
		FLOOR1:begin
			// distance is from HC_SR04 sensor in units of 'cm', you can change the values
			if(distance > 3 && distance <= 24 ) begin
				move1 <= 0;
				move2 <= 1;		
			end
			else if (distance > 19) begin
				move1 <= 1;
				move2 <= 0;
			end
			else begin
				move1 <= 0;
				move2 <= 0;
			end
		end
		FLOOR2:begin
			if(distance < 8 ) begin
				move1 <= 1;
				move2 <= 0;
			end
			else if (distance > 8) begin
				move1 <= 0;
				move2 <= 1;
			end
			else begin
				move1 <= 0;
				move2 <= 0;
			end
		end
		FLOOR3:begin
			if(distance < 13 ) begin
				move1 <= 1;
				move2 <= 0;
			end
			else if (distance > 13) begin
				move1 <= 0;
				move2 <= 1;
			end
			else begin
				move1 <= 0;
				move2 <= 0;
			end
		end				
		FLOOR4:begin
			if(distance < 18 ) begin
				move1 <= 1;
				move2 <= 0;
			end
			else begin
				move1 <= 0;
				move2 <= 0;
			end
		end
		FLOOR5:begin
			if(distance < 23 ) begin
				move1 <= 1;
				move2 <= 0;
			end
			else if (distance > 23 )begin
				move1 <= 0;
				move2 <= 1;
			end
			else begin
				move1 <= 0;
				move2 <= 0;
			end
		end
		default:begin
				move1 <= 0;
				move2 <= 0;
		end
	endcase
end
endmodule


/*********************** Module Definition for a switch debouncer ***********************/
module debounce (
    input clk, key,
    output key_deb
);

wire slow_clk;
wire Q1,Q2,Q2_bar;

divider_integer #(.WIDTH(17),.N(240000)) U1 ( 
    .clk(clk),                              
    .clkout(slow_clk)          
);
dff U2 (                       
    .clk(slow_clk),
    .D(key),
    .Q(Q1) 
);
dff U3 (                       
    .clk(slow_clk),
    .D(Q1),
    .Q(Q2) 
);

assign Q2_bar = ~Q2;
assign key_deb = Q1 & Q2_bar;  
endmodule

/************************* Module Definition for D Flip Flot **************************/
module dff(input clk, D, output reg Q);
    always @ (posedge clk) begin
        Q <= D;
    end
endmodule

/****************** Module Definition for an integer clock divider ********************/
module divider_integer # (           
    parameter   WIDTH = 24,          
    parameter   N     = 12000000     
)  
(
    input clk,
    output reg clkout 
);
reg [WIDTH-1:0] cnt; 
always @ (posedge clk) begin
    if(cnt>=(N-1))
        cnt <= 1'b0;
    else
        cnt <= cnt + 1'b1;
    clkout <= (cnt<N/2)?1'b1:1'b0;
end
endmodule


/************************ Module Definition for a BCD converter ***********************/
module bin_to_bcd (
	input				rst_n,
	input		[15:0]	bin_code,	
	output	reg	[19:0]	bcd_code	
);
reg		[35:0]		shift_reg; 
always @ (bin_code or rst_n) begin
	shift_reg = {20'h0,bin_code};
	if(!rst_n) bcd_code = 0; 
	else begin 
		repeat(16) begin // repeat for 16 times
			if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 2'b11;
			if (shift_reg[23:20] >= 5) shift_reg[23:20] = shift_reg[23:20] + 2'b11;
			if (shift_reg[27:24] >= 5) shift_reg[27:24] = shift_reg[27:24] + 2'b11;
			if (shift_reg[31:28] >= 5) shift_reg[31:28] = shift_reg[31:28] + 2'b11;
			if (shift_reg[35:32] >= 5) shift_reg[35:32] = shift_reg[35:32] + 2'b11;
			shift_reg = shift_reg << 1; 
		end
		bcd_code = shift_reg[35:16];   
	end  
end
endmodule


/********************* Module Definition for a 7-segment tube driver ******************/
module segment7
 (
    input  wire [3:0] seg_data,        
    output reg  [8:0] segment_led  
    //  MSB~LSB = SEG,  DP,  g,  f e,  d,  c,  b,  a
) ; 
always @  (seg_data)  begin
    case  (seg_data) 
      4'b0000: segment_led = 9'h3f;   //  0
      4'b0001: segment_led = 9'h06;   //  1
      4'b0010: segment_led = 9'h5b;   //  2
      4'b0011: segment_led = 9'h4f;   //  3
      4'b0100: segment_led = 9'h66;   //  4
      4'b0101: segment_led = 9'h6d;   //  5
      4'b0110: segment_led = 9'h7d;   //  6
      4'b0111: segment_led = 9'h07;   //  7
      4'b1000: segment_led = 9'h7f;   //  8
      4'b1001: segment_led = 9'h6f;   //  9
      4'b1010: segment_led = 9'h77;   //  A
      4'b1011: segment_led = 9'h7C;   //  b
      4'b1100: segment_led = 9'h39;   //  C
      4'b1101: segment_led = 9'h5e;   //  d
      4'b1110: segment_led = 9'h79;   //  E
      4'b1111: segment_led = 9'h71;   //  F
    endcase
 end
endmodule
