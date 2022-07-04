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
