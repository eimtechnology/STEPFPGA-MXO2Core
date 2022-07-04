module Crossroad_Smart (
	input 					clk, rst_n,
	input					WalkSignal_2, WalkSignal_4, CarSignal_2, CarSignal_4,
	input					LDR_Sen,
	input					comp_out,
	output					pwm_in,
	output	reg				road_light,
	output	reg		[2:0]	TrafficLights_Main,		//R,G,Y
	output	reg		[2:0]	TrafficLights_Small,	//R,G,Y
	
	// **** optional
	output			[7:0] 	digital_out,
	output 			[8:0]	segment_led_1,  		//MSB~LSB = SEG,DP,G,F,E,D,C,B,A
	output 			[8:0]	segment_led_2   		//MSB~LSB = SEG,DP,G,F,E,D,C,B,A
);


wire			[7:0] 	bcdcode;
localparam      S1 = 3'b000,	   	//master green	,	small red
				S2 = 3'b001,    	//master yellow 	,	small red
				S3 = 3'b010,	   	//master red 		,	small green
				S4 = 3'b011,    	//master red 		,	small yellow
				S5 = 3'b100,		//master green 	,	small red
				S6 = 3'b101,		//master yellow 	,	small red
				S7 = 3'b110,		//master red 		,	small green
				S8 = 3'b111;		//master red 		,	small yellow
				
localparam      RED = 3'b100, GREEN = 3'b010, YELLOW = 3'b001;	

wire	pedestrain2; 
debounce debU1 (clk, WalkSignal_2, pedestrain2);
wire 	pedestrain4;
debounce debU2 (clk, WalkSignal_4, pedestrain4);




// ***** Segment 1 - Synchronize the transition of the 8 states ****** 
// Generate 1Hz signal
reg clk_1Hz;
reg [23:0] cnt;
always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n) begin
			cnt <= 0;
			clk_1Hz <= 0;
		end else if(cnt == 24'd5_999_999) begin		
			cnt<=0;
			clk_1Hz <= ~clk_1Hz;			
		end else cnt<=cnt+1'b1;		
	end

reg [7:0] timecnt;
always @(posedge clk_1Hz or negedge rst_n)
	if(!rst_n) c_state <= S1;
	else c_state <= n_state;
end
		
// Segment 2 - Describe the transitions of states
reg	[2:0] c_state,n_state;
wire SmallAve_Wakeup = pedestrain2 & pedestrain4 & CarSignal_2 & CarSignal_4;
always @(*) begin
	if(!rst_n)begin
		n_state = S1;
	end 
	else begin
		case(c_state)
			S1: if(!timecnt)begin 
					if(LDR_Sen) n_state = S5;					
					else n_state = S2;					
					end
				else n_state = S1;			
			S2: if(!timecnt)begin 
					if(LDR_Sen) n_state = S5;				
					else n_state = S3;					
					end 
				else n_state = S2;		
			S3: if(!timecnt)begin 
					if(LDR_Sen) n_state = S5;
					else n_state = S4;
					end 
				else n_state = S3;		
			S4: if(!timecnt)begin 
					if(LDR_Sen) n_state = S5;					
					else n_state = S1;	
					end 
				else n_state = S4;
			S5:	if(!LDR_Sen) n_state = S3;		
				else if (SmallAve_Wakeup) n_state = S5; 				
				else n_state = S6;			
			S6: if(!timecnt) begin 
					if(!LDR_Sen) n_state = S1;			
					else n_state = S7;	
					end 
				else n_state = S6;			
			S7: if(!timecnt)begin 
					if(!LDR_Sen) n_state = S1;				
					else n_state = S8;					
					end  
				else n_state = S7;	
			S8: if(!timecnt)begin 
					if(!LDR_Sen) n_state = S1;		
					else n_state = S5;		
					end  
				else n_state = S8;				
			default:n_state = S1;
		endcase
	end
end

// Segment 3 - Describe the actions implemented in each state, synchronized to clock 
always @(posedge clk_1Hz or negedge rst_n) begin
	if(!rst_n)begin
		timecnt <= 8'd15;
		TrafficLights_Main <= GREEN; TrafficLights_Small <= RED;
	end 
	else begin
		case(n_state)
			S1: begin
				TrafficLights_Main <= GREEN; TrafficLights_Small <= RED;
				if(timecnt==0) timecnt <= 8'd15;	
				else timecnt <= timecnt - 1'b1;
			end
			S2: begin
				TrafficLights_Main <= YELLOW; TrafficLights_Small <= RED;		
				if(timecnt==0) timecnt <= 8'd2;
				else timecnt <= timecnt - 1'b1;
			end
			S3: begin
				TrafficLights_Main <= RED; TrafficLights_Small <= GREEN;	
				if(timecnt==0) timecnt <= 8'd7;				
				else timecnt <= timecnt - 1'b1;
			end
			S4: begin
				TrafficLights_Main <= RED; TrafficLights_Small <= YELLOW;				
				if(timecnt==0) timecnt <= 8'd2;
				else timecnt <= timecnt - 1'b1;
			end
			S5:begin
				TrafficLights_Main <= GREEN; 
				TrafficLights_Small <= RED;
				timecnt <= 8'd0;
			end
			S6: begin
				TrafficLights_Main <= YELLOW; TrafficLights_Small <= RED;
				if(timecnt==0) timecnt <= 8'd2;
				else timecnt <= timecnt - 1'b1;
			end
			S7: begin
				TrafficLights_Main <= RED; TrafficLights_Small <= GREEN;
				if(timecnt==0) timecnt <= 8'd5;	
				else timecnt <= timecnt - 1'b1;
			end
			S8: begin
				TrafficLights_Main <= RED; TrafficLights_Small <= YELLOW;
				if(timecnt==0) timecnt <= 8'd2;
				else timecnt <= timecnt - 1'b1;
			end
			default:;
		endcase
	end
end

// Turn on all road lights when dark (LDR_Sen = 1 when dark) 
always@(posedge clk) begin
	if(!LDR_Sen) road_light <= 0;
	else road_light <= 1;
end

////Segment led display
//Segment_led Segment_led_u1(
//				.seg_data_1(bcdcode[7:4]),		//(timecnt[7:4]),  //seg_data input
//				.seg_data_2(bcdcode[3:0]),		//(timecnt[3:0]),  //seg_data input
//				.segment_led_1(segment_led_1),  //MSB~LSB = SEG,DP,G,F,E,D,C,B,A
//				.segment_led_2(segment_led_2)   //MSB~LSB = SEG,DP,G,F,E,D,C,B,A
//			);


			
//ADC_top adc_top_u1(
//				.clk_in(clk),
//				.rstn(rst_n),
//				.digital_out(digital_out),
//				.analog_cmp(comp_out),	
//				.analog_out(pwm_in),
//				.sample_rdy()
//				);
//				
//bin2bcd	bin2bcd_u1(
//				.bitcode(timecnt),
//				.bcdcode(bcdcode)
//				);

endmodule



/* 	
File name: debounce
Module Function: Soft-debouncing of a mechanical switch

This example code can also be found in Chapter 5 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

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

module dff(input clk, D, output reg Q);
    always @ (posedge clk) begin
        Q <= D;
    end
endmodule


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
