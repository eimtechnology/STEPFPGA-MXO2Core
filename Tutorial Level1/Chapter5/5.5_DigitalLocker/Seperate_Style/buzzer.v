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