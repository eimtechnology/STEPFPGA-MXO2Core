module	DigitalLockerCtrl	(
	input		clk, rst_n,
	output		[3:0]	row,	
	input		[2:0]	col,
	output		buzzer_out,
	output		servo_pwm

	/*** uncomment if you want to display the key on segment display*/
	// output	wire	[8:0]	seg_led_1,
	// output	wire	[8:0]	seg_led_2
);


wire	[3:0]	keyUserInput;
keypad_3by4	LockerKeyIn (clk, rst_n, col, row, keyUserInput);

wire	pw_true, pw_false, timeout_flag;
pwd_checker	#((28'd60000000),(16'h1234)) PWDcheck (clk, rst_n, keyUserInput, pw_true, pw_false, timeout_flag);
buzzer #((24'd12000),(28'd12000000),(28'd36000000)) beep (clk, rst_n, pw_false, timeout_flag, buzzer_out);

wire 	[7:0] 	angle;
ServoAngle	LockerCtrl (clk, rst_n, pw_true, angle);
servo 		ServoCtrl  (clk, rst_n, angle, servo_pwm);

endmodule


/*********************************************************************************************/
/***********************   Instantiate the angle control module  ***************************/
module	ServoAngle(
	input	wire			clk,rst_n,		
	input	wire			pw_true,
	output 	reg	[7:0]		rotate_angle
);

parameter	T_DELAY=28'd60000000;

reg	delay_rst;
reg	[27:0]	cnt_delay;

always@(posedge	clk or negedge rst_n)begin
	if(!rst_n)begin
		rotate_angle<=8'd90;
		delay_rst<=1'b1;
	end 
	else begin
		if(pw_true)begin
			rotate_angle<=8'd40;
			delay_rst<=1'b0;
		end 
		else begin
			if(cnt_delay>=T_DELAY)begin
				rotate_angle<=8'd90;
				delay_rst<=1'b1;
			end 
			else begin
				rotate_angle<=rotate_angle;
				delay_rst<=delay_rst;
			end 
		end 
	end 
end 

always@(posedge	clk or negedge rst_n)begin
	if(!rst_n)
		cnt_delay<=28'd0;
	else begin
		if(delay_rst)
			cnt_delay<=28'd0;
		else
			cnt_delay<=cnt_delay+1'b1;
	end 
end 

endmodule



/*********************************************************************************************/
/**************************** Instantiate Servo control module ****************************/
module servo (
	input   			clk, rst_n,
	// Since a servo does not rotate beyond 180 degrees, use 8-bit is enough (0 - 255)
	input 	[7:0]		rotate_angle,	// Rotation degrees in Binary form
	output	reg			servo_pwm
);

localparam  	CNT_20MS = 240_000;		// 240000 counts means 20ms 
localparam	 	UpLimit = 179;			

reg [15:0] cnt;

	
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
		cnt <= 1'b0;
    else if(cnt == (CNT_20MS-1)) 
		cnt <= 1'b0;
    else 
		cnt <= cnt + 1'b1;
end

/******************************  This code controls the rotational angle of the servo motor *********************************/
// 	For a 12MHz clock, 0.5ms - 2.5ms pulse width corresponds to 6000 to 30000 counts, reserve a 16 bit width register
reg [15:0] cnt_degree;	

// rotation angle within 180 degrees is calculated by: 6000 + rotate_angle * 134 (for rotate_angle < 179) 
always @(posedge clk) begin 
	if (rotate_angle <= 179)
		cnt_degree <= rotate_angle * 19'd134 + 19'd6000;
		
	else	// for rotation_angle higher than 179 degree, set it to 179
		cnt_degree <= UpLimit * 19'd134 + 19'd6000;
end

/******************************************  Generates the angle-encoded PWM *********************************************/
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
		servo_pwm <= 1'b0;
    else 
		servo_pwm <= (cnt <= cnt_degree)? 1'b1:1'b0;
end
endmodule 

/*********************************************************************************************/
/*********************************** Check the Password **************************************/

module	pwd_checker(
	input	wire			clk, rst_n,		
	input	wire	[3:0]	keyUserInput,
	output	reg				pw_true,
	output	reg				pw_false,
	output	reg				timeout_flag
);


parameter	TIME_OUT=28'd120000000;	
parameter	PASSWORD=16'h1234;		

localparam	IDLE			=3'b001;		
localparam	LOAD_PWD		=3'b010;
localparam	CHECK_PWD		=3'b100;

reg	[2:0]	cur_state;
reg	[2:0]	next_state;

reg	[2:0]	cnt_pwdPressing;

reg	[19:0]	pwd_input;

reg				restart_flag;	
reg		[27:0]	cnt_delay;
wire			restart_flag_pos;
reg				restart_flag_r;
reg				level_restart;

always@(posedge	clk or negedge rst_n)begin
	if(!rst_n)
		cur_state<=IDLE;
	else
		cur_state<=next_state;
end

always@(*)begin
	if(!rst_n)
		next_state=IDLE;
	else begin
		case(cur_state)
			IDLE:begin
				if(keyUserInput==4'd10)
					next_state=LOAD_PWD;
				else
					next_state=IDLE;
			end 
			LOAD_PWD:begin
				if(timeout_flag)
					next_state=IDLE;
				else begin
					if(cnt_pwdPressing<3'd5)
						next_state=LOAD_PWD;
					else
						next_state=CHECK_PWD;
				end 
			end 
			CHECK_PWD:begin
				next_state=IDLE;
			end 
			default: next_state=IDLE;
		endcase
	end 
end 

always@(posedge	clk or negedge rst_n)begin
	if(!rst_n)begin
		cnt_pwdPressing<=3'd0;
		restart_flag<=1'b0;
		level_restart<=1'b1;
		pwd_input<=20'h00000;
		pw_true<=1'b0;
		pw_false<=1'b0;
	end 
	else begin
		case(cur_state)
			IDLE:begin
				cnt_pwdPressing<=3'd0;
				restart_flag<=1'b0;
				level_restart<=1'b1;
				pwd_input<=20'h00000;
				pw_true<=1'b0;
				pw_false<=1'b0;
			end 
			LOAD_PWD:begin
				level_restart<=1'b0;
				if(keyUserInput!=4'd15)begin
					cnt_pwdPressing<=cnt_pwdPressing+1'b1;
					pwd_input<={pwd_input[15:0],keyUserInput[3:0]};
					restart_flag<=1'b1;
				end 
				else
					restart_flag<=1'b0;
			end 
			CHECK_PWD:begin
				if(pwd_input=={PASSWORD,4'hc})
					pw_true<=1'b1;
				else
					pw_false<=1'b1;
			end  
			default: ;
		endcase	
	end 
end 
					
always@(posedge	clk or negedge rst_n)begin
	if(!rst_n)
		restart_flag_r<=1'b0;
	else
		restart_flag_r<=restart_flag;
end 
assign	restart_flag_pos=(~restart_flag_r) & restart_flag;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnt_delay<=28'd0;
		timeout_flag<=1'b0;
	end 
	else begin
		if(level_restart|restart_flag_pos|timeout_flag)begin
			cnt_delay<=28'd0;
			timeout_flag<=1'b0;
		end 
		else if(cnt_delay<=TIME_OUT-1'b1)begin
			cnt_delay<=cnt_delay+1'b1;
			timeout_flag<=1'b0;
		end 
		else begin
			cnt_delay<=cnt_delay;
			timeout_flag<=1'b1;
		end 
	end 
end 	
endmodule


/*********************************************************************************************/
/*********************************** sound the alarm **************************************/
module	buzzer (
	input	wire			clk, rst_n,
	input	wire			pw_false,
	input	wire			timeout_flag,
	output	wire			beep_out
);

parameter	T_FREQ = 24'd12000;				//1kHZ (1ms)-> T_FREQ=12000
parameter	T_TIMEOUT =28'd12000000;		// Counter for 1s, beep time for time out
parameter	T_PW_ERROR =28'd36000000;		// Counter for 3s, beep time for password error


reg				start_delay;
reg		[27:0]	cnt_delay;	
reg				stop_beep;
reg		[23:0]	cnt_period;

reg				flag;

always@(posedge	clk	or negedge	rst_n)begin
	if(!rst_n)begin
		start_delay<=1'b0;
		stop_beep<=1'b1;
		flag<=1'b1;
	end 
	else begin
		if(pw_false)begin
			start_delay<=1'b1;
			stop_beep<=1'b0;
			flag<=1'b1;
		end 
		else if(timeout_flag)begin
			start_delay<=1'b1;
			stop_beep<=1'b0;
			flag<=1'b0;
		end 
		else if(flag&(cnt_delay>=T_PW_ERROR-1'b1))begin
			start_delay<=1'b0;
			stop_beep<=1'b1;
		end 
		else if((!flag)&(cnt_delay>=T_TIMEOUT-1'b1))begin
			start_delay<=1'b0;
			stop_beep<=1'b1;
		end 
		else begin
			start_delay<=start_delay;
			stop_beep<=stop_beep;
		end
	end 	
end 

always@(posedge	clk or negedge rst_n)begin
	if(!rst_n)
		cnt_delay<=28'd0;
	else begin
		if(!start_delay)
			cnt_delay<=28'd0;
		else
			cnt_delay<=cnt_delay+1'b1;
	end 
end 

always@(posedge	clk or negedge rst_n)begin
	if(!rst_n)
		cnt_period<=24'd0;
	else begin
		if(stop_beep)
			cnt_period<=24'd0;
		else begin
			if(cnt_period>=T_FREQ-1'b1)
				cnt_period<=24'd0;
			else
				cnt_period<=cnt_period+1'b1;
		end 
	end 
end 
assign	beep_out=(cnt_period>=(T_FREQ/2))?1'b1:1'b0;

endmodule


/* 	
File name: keypad_3by4
Module Function: Interfacing with a 3x4 matrix keypad 

This example code can also be found in Chapter 5 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

module keypad_3by4 (
	input					clk,		
	input					rst_n,		
	input			[2:0]	col,		// the 3 output signals for 3 Columns 
	output	reg		[3:0]	row,		// the 4 input signals for 4 Rows 
	output	reg		[3:0]	keyPressed
	
	// output	reg		[8:0]	seg_led_1,
	// output	reg		[8:0]	seg_led_2
);

	localparam			NUM_FOR_200HZ = 60000;	// Used to generate a 200Hz frequency for column scanning
	localparam			ROW0_SCAN = 2'b00;      // the state when scanning first row
	localparam			ROW1_SCAN = 2'b01;      // the state when scanning second row
	localparam			ROW2_SCAN = 2'b10;      // the state when scanning third row
	localparam			ROW3_SCAN = 2'b11;		// the state when scanning forth row
 
	reg		[11:0]	key,key_r;
	reg		[11:0]	key_out;		// debounce all keys

	reg		[15:0]	cnt;
	reg				clk_200hz;
	
	// generate a 200Hz clock
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin		
			cnt <= 16'd0;
			clk_200hz <= 1'b0;
		end else begin
			if(cnt >= ((NUM_FOR_200HZ>>1) - 1)) begin	//  >>1 means divide by 2
				cnt <= 16'd0;
				clk_200hz <= ~clk_200hz;	
			end else begin
				cnt <= cnt + 1'b1;
				clk_200hz <= clk_200hz;
			end
		end
	end
 
	reg		[1:0]		c_state;
	always@(posedge clk_200hz or negedge rst_n) begin
		if(!rst_n) begin
			c_state <= ROW0_SCAN;
			row <= 4'b1110;
		end else begin
			case(c_state)
				ROW0_SCAN: begin c_state <= ROW1_SCAN; row <= 4'b1101; end	
				ROW1_SCAN: begin c_state <= ROW2_SCAN; row <= 4'b1011; end
				ROW2_SCAN: begin c_state <= ROW3_SCAN; row <= 4'b0111; end
				ROW3_SCAN: begin c_state <= ROW0_SCAN; row <= 4'b1110; end
				default:begin c_state <= ROW0_SCAN; row <= 4'b1110; end
			endcase
		end
	end
 
always@(negedge clk_200hz or negedge rst_n) begin
	if(!rst_n) begin
		key_out <= 12'hfff;
	end else begin
		case(c_state)
			ROW0_SCAN: begin 				// check for colum 0, 1, 2
						key[2:0] <= col;    
						key_r[2:0] <= key[2:0];    
						key_out[2:0] <= key_r[2:0]|key[2:0];   // double comfirm the pressed key
						
					end 
			ROW1_SCAN:begin 				// check for colum 3, 4, 5
						key[5:3] <= col;    
						key_r[5:3] <= key[5:3];    
						key_out[5:3] <= key_r[5:3]|key[5:3];   // double comfirm the pressed key
						
					end 
			ROW2_SCAN:begin 
						key[8:6] <= col;    // check for colum 6, 7, 8
						key_r[8:6] <= key[8:6];   
						key_out[8:6] <= key_r[8:6]|key[8:6];   // double comfirm the pressed key
						
					end 
			ROW3_SCAN:begin 
						key[11:9] <= col;    // check for colum 9, 10, 11
						key_r[11:9] <= key[11:9];    
						key_out[11:9] <= key_r[11:9]|key[11:9]; // double comfirm the pressed key
						
					end 
			default:key_out <= 12'hfff;
		endcase
	end
end
	
	
reg	[3:0]	key_code;	

reg		[11:0]		key_out_r;
wire	[11:0]		 key_pulse;
always @ ( posedge clk  or  negedge rst_n )begin
	if (!rst_n) key_out_r <= 12'hfff;
	else  key_out_r <= key_out;  
end 

assign key_pulse= key_out_r & (~key_out);   

always@(*)begin
	case(key_pulse)
		12'b0000_0000_0001: key_code=4'd1 ;	// key 1
		12'b0000_0000_0010: key_code=4'd2 ;	// key 2
		12'b0000_0000_0100: key_code=4'd3 ;	// key 3
		12'b0000_0000_1000: key_code=4'd4 ;	// key 4
		12'b0000_0001_0000: key_code=4'd5 ; // key 5
		12'b0000_0010_0000: key_code=4'd6 ; // key 6
		12'b0000_0100_0000: key_code=4'd7 ; // key 7
		12'b0000_1000_0000: key_code=4'd8 ; // key 8
		12'b0001_0000_0000: key_code=4'd9 ;	// key 9
		12'b0010_0000_0000: key_code=4'd10;	// key *
		12'b0100_0000_0000: key_code=4'd0 ;	// key 0
		12'b1000_0000_0000: key_code=4'd12;	// key #
		default: key_code=4'd15;           
	endcase                                
end                                        
                                           
always@(posedge clk or  negedge rst_n)begin
	if(!rst_n) 	keyPressed <= 4'd15;
	else			keyPressed<=key_code;
end 

/*	
always@(posedge clk)begin
	case(keyPressed)
	4'd0: begin seg_led_1<=9'h3f;			seg_led_2<=9'h3f;end 
	4'd1: begin seg_led_1<=9'h06;			seg_led_2<=9'h06;end 
	4'd2: begin seg_led_1<=9'h5b;			seg_led_2<=9'h5b;end
	4'd3: begin seg_led_1<=9'h4f;			seg_led_2<=9'h4f;end
	4'd4: begin seg_led_1<=9'h66;			seg_led_2<=9'h66;end
	4'd5: begin seg_led_1<=9'h6d;			seg_led_2<=9'h6d;end
	4'd6: begin seg_led_1<=9'h7d;			seg_led_2<=9'h7d;end 
	4'd7: begin seg_led_1<=9'h07;			seg_led_2<=9'h07;end
	4'd8: begin seg_led_1<=9'h7f;			seg_led_2<=9'h7f;end
	4'd9: begin seg_led_1<=9'h6f;			seg_led_2<=9'h6f;end 
	4'd10: begin seg_led_1<=9'h77;			seg_led_2<=9'h77;end
	4'd12: begin seg_led_1<=9'h39;			seg_led_2<=9'h39;end	
	default:begin seg_led_1<=seg_led_1;		seg_led_2<=seg_led_2;end
	endcase 
end 
*/
 
endmodule