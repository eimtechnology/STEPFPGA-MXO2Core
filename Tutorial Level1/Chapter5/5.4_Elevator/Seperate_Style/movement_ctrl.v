/* 	
File name: movement_ctrl
Module Function: Controlling the movement of DC motor based on distance and user inputs (pushbutton)

This example code can also be found in Chapter 5 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

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

	
