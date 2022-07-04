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