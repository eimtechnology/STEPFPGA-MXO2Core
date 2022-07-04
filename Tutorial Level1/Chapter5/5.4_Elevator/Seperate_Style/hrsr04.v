/*****************************************  File name: hc_sr04  *************************************** 	
Module Function: HC_SR04 Ultrasonic Distance Sensor Driver

This example code is to accompany the Ultrasonic Distance Sensor module in Chapter 5 of the
STPFPGA tutorial book. You can connect HC_SR04 to any two GPIOs of the STEPFPGA board, and 
map the 'Echo' and 'Trig' to the external pins you connected. The output 'distance' is a 16-bit 
data in unit of 'cm'. For example, if distance = 0000_0000_0001_1100  means the distance is 28cm.

Copyright License: MIT
********************************************************************************************************/ 

/*****************************************   Module Definition  ***************************************/	
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

