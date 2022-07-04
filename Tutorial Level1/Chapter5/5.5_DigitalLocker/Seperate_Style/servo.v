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