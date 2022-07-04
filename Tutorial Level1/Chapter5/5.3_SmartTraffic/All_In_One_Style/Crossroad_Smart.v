module Crossroad_Smart (
	input 					clk, rst_n,
	input					WalkSignal_2, WalkSignal_4, CarSignal_2, CarSignal_4,
	input					LDR_Sen,
	input					comp_out,
	output					pwm_in,
	output			[7:0]	digital_out,
	output	reg				road_light,
	output	reg		[2:0]	TrafficLights_Main,		//R,G,Y
	output	reg		[2:0]	TrafficLights_Small	//R,G,Y

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
always @(posedge clk_1Hz or negedge rst_n) begin
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


ADC_top adc_top_u1(
	.clk_in(clk),
	.rstn(rst_n),
	.digital_out(digital_out),
	.analog_cmp(comp_out),	
	.analog_out(pwm_in),
	.sample_rdy()
);

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



//*********************************************************************
//
//	ADC Top Level Module
//
//*********************************************************************



module ADC_top (
	clk_in,
	rstn,
	digital_out,
	analog_cmp,	
	analog_out,
	sample_rdy);

parameter 
ADC_WIDTH = 8,              // ADC Convertor Bit Precision
ACCUM_BITS = 10,            // 2^ACCUM_BITS is decimation rate of accumulator
LPF_DEPTH_BITS = 3,         // 2^LPF_DEPTH_BITS is decimation rate of averager
INPUT_TOPOLOGY = 0;         // 0: DIRECT: Analog input directly connected to + input of comparitor
                            // 1: NETWORK:Analog input connected through R divider to - input of comp.

//input ports
input	clk_in;				// 62.5Mhz on Control Demo board
input	rstn;	 
input	analog_cmp;			// from LVDS buffer or external comparitor

//output ports
output	analog_out;         // feedback to RC network
output  sample_rdy;
output [7:0] digital_out;   // connected to LED field on control demo bd.
 

//**********************************************************************
//
//	Internal Wire & Reg Signals
//
//**********************************************************************
wire							clk;
wire							analog_out_i;
wire							sample_rdy_i;
wire [ADC_WIDTH-1:0]			digital_out_i;
wire [ADC_WIDTH-1:0]			digital_out_abs;



assign clk = clk_in;


//***********************************************************************
//
//  SSD ADC using onboard LVDS buffer or external comparitor
//
//***********************************************************************
sigmadelta_adc #(
	.ADC_WIDTH(ADC_WIDTH),
	.ACCUM_BITS(ACCUM_BITS),
	.LPF_DEPTH_BITS(LPF_DEPTH_BITS)
	)
SSD_ADC(
	.clk(clk),
	.rstn(rstn),
	.analog_cmp(analog_cmp),
	.digital_out(digital_out_i),
	.analog_out(analog_out_i),
	.sample_rdy(sample_rdy_i)
	);

assign digital_out_abs = INPUT_TOPOLOGY ? ~digital_out_i : digital_out_i;  

//***********************************************************************
//
//  output assignments
//
//***********************************************************************


assign digital_out   = ~digital_out_abs;	 // invert bits for LED display 
assign analog_out    =  analog_out_i;
assign sample_rdy    =  sample_rdy_i;

endmodule


//*********************************************************************
//
//	SSD Top Level Module
//
//*********************************************************************



module sigmadelta_adc (
	clk,                    
	rstn,                   
	digital_out,            
	analog_cmp,	            
	analog_out,             
	sample_rdy);            

parameter 
ADC_WIDTH = 8,              // ADC Convertor Bit Precision
ACCUM_BITS = 10,            // 2^ACCUM_BITS is decimation rate of accumulator
LPF_DEPTH_BITS = 3;         // 2^LPF_DEPTH_BITS is decimation rate of averager

//input ports
input	clk;                            // sample rate clock
input	rstn;                           // async reset, asserted low
input	analog_cmp ;                    // input from LVDS buffer (comparitor)

//output ports
output	analog_out;                     // feedback to comparitor input RC circuit
output  sample_rdy;                     // digital_out is ready
output [ADC_WIDTH-1:0]	digital_out;    // digital output word of ADC


//**********************************************************************
//
//	Internal Wire & Reg Signals
//
//**********************************************************************
reg                         delta;          // captured comparitor output
reg [ACCUM_BITS-1:0]	    sigma;          // running accumulator value
reg [ADC_WIDTH-1:0]	        accum;          // latched accumulator value
reg [ACCUM_BITS-1:0]	    counter;        // decimation counter for accumulator
reg							rollover;       // decimation counter terminal count
reg							accum_rdy;      // latched accumulator value 'ready' 




//***********************************************************************
//
//  SSD 'Analog' Input - PWM
//
//	External Comparator Generates High/Low Value
//
//***********************************************************************

always @ (posedge clk)
begin
    delta <= analog_cmp;        // capture comparitor output
end

assign analog_out = delta;      // feedback to comparitor LPF

//***********************************************************************
//
//  Accumulator Stage
//
//	Adds PWM positive pulses over accumulator period
//
//***********************************************************************

always @ (posedge clk or negedge rstn)
begin
	if( ~rstn ) 
    begin
		sigma       <= 0;
		accum       <= 0;
		accum_rdy   <= 0;
    end else begin
        if (rollover) begin
            // latch top ADC_WIDTH bits of sigma accumulator (drop LSBs)
            accum <= sigma[ACCUM_BITS-1:ACCUM_BITS-ADC_WIDTH];
            sigma <= delta;         // reset accumulator, prime with current delta value
        end else begin
            if (&sigma != 1'b1)         // if not saturated
                sigma <= sigma + delta; // accumulate 
        end
        accum_rdy <= rollover;     // latch 'rdy' (to align with accum)
    end
end



//***********************************************************************
//
//  Box filter Average
//
//	Acts as simple decimating Low-Pass Filter
//
//***********************************************************************

box_ave #(
    .ADC_WIDTH(ADC_WIDTH),
    .LPF_DEPTH_BITS(LPF_DEPTH_BITS))
box_ave (
    .clk(clk),
    .rstn(rstn),
    .sample(accum_rdy),
    .raw_data_in(accum),
    .ave_data_out(digital_out),
    .data_out_valid(sample_rdy)
);

//************************************************************************
//
// Sample Control - Accumulator Timing
//	
//************************************************************************

always @(posedge clk or negedge rstn)
begin
	if( ~rstn ) begin
		counter <= 0;
		rollover <= 0;
		end
	else begin
		counter <= counter + 1;       // running count
		rollover <= &counter;         // assert 'rollover' when counter is all 1's
		end
end

endmodule


//*********************************************************************
//
//	'Box' Average 
//
//  Standard Mean Average Calculation
//   Can be modeled as FIR Low-Pass Filter where 
//   all coefficients are equal to '1'.
//
//*********************************************************************



module box_ave (
	clk,
	rstn,
	sample,
	raw_data_in,
	ave_data_out,
    data_out_valid);

parameter 
ADC_WIDTH = 8,				// ADC Convertor Bit Precision
LPF_DEPTH_BITS = 4;         // 2^LPF_DEPTH_BITS is decimation rate of averager

//input ports
input	clk;                                // sample rate clock
input	rstn;	                            // async reset, asserted low
input	sample;				                // raw_data_in is good on rising edge, 
input	[ADC_WIDTH-1:0]	raw_data_in;		// raw_data input

//output ports
output [ADC_WIDTH-1:0]	ave_data_out;		// ave data output
output data_out_valid;                      // ave_data_out is valid, single pulse

reg [ADC_WIDTH-1:0]	ave_data_out;		
//**********************************************************************
//
//	Internal Wire & Reg Signals
//
//**********************************************************************
reg [ADC_WIDTH+LPF_DEPTH_BITS-1:0]      accum;          // accumulator
reg [LPF_DEPTH_BITS-1:0]                count;          // decimation count
reg [ADC_WIDTH-1:0]  					raw_data_d1;    // pipeline register

reg sample_d1, sample_d2;                               // pipeline registers
reg result_valid;                                       // accumulator result 'valid'
wire accumulate;                                        // sample rising edge detected
wire latch_result;                                      // latch accumulator result

//***********************************************************************
//
//  Rising Edge Detection and data alignment pipelines
//
//***********************************************************************
always @(posedge clk or negedge rstn)
begin
	if( ~rstn ) begin
		sample_d1 <= 0;	
		sample_d2 <= 0;
        raw_data_d1 <= 0;
		result_valid <= 0;
	end else begin
		sample_d1 <= sample;                // capture 'sample' input
		sample_d2 <= sample_d1;             // delay for edge detection
		raw_data_d1 <= raw_data_in; 	    // pipeline 
		result_valid <= latch_result;		// pipeline for alignment with result
	end
end

assign		accumulate = sample_d1 && !sample_d2;	    // 'sample' rising_edge detect
assign		latch_result = accumulate && (count == 0);	// latch accum. per decimation count

//***********************************************************************
//
//  Accumulator Depth counter
//
//***********************************************************************
always @(posedge clk or negedge rstn)
begin
	if( ~rstn ) begin
		count <= 0;	  
	end else begin
	    if (accumulate)	count <= count + 1;         // incr. count per each sample
	end
end


//***********************************************************************
//
//  Accumulator
//
//***********************************************************************
always @(posedge clk or negedge rstn)
begin
	if( ~rstn ) begin
		accum <= 0;	
	end else begin
        if (accumulate)
            if(count == 0)                      // reset accumulator
    		    accum <= raw_data_d1;           // prime with first value
            else
                accum <= accum + raw_data_d1;   // accumulate
	end	
end
	
//***********************************************************************
//
//  Latch Result
//
//  ave = (summation of 'n' samples)/'n'  is right shift when 'n' is power of two
//
//***********************************************************************
always @(posedge clk or negedge rstn)
begin
	if( ~rstn ) begin
        ave_data_out <= 0;
    end else if (latch_result) begin            // at end of decimation period...
        ave_data_out <= accum >> LPF_DEPTH_BITS;	  // ... save accumulator/n result
    end
end

assign data_out_valid = result_valid;       // output assignment

endmodule
