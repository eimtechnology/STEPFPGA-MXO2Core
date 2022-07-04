module	DigitalLockerCtrl_top	(
	input		clk, rst_n,
	output		[3:0]	row,	
	input		[2:0]	col,
	output		buzzer_out,
	output		servo_pwm
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