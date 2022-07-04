/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			simple_traffic.v
*- Top Module name: 	simple_traffic
  - Submodules:		divider_integer
*- Description:			Using a state machine to control two RGB LEDs to simulate a traffic light
					
*- Example of Usage:
       - You may assign the output directly to the 2 RGB LEDs on the STEPFPGA board

* - Read more details in Chapter 5 (simple traffic light) of the tutorial book.
   
*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module simple_traffic (
	input clk, rst_n,
	output reg [5:0] RGB_out		// connects the TWO RGB lights
);

// The four states
reg             [1:0] state;
parameter       S1 = 2'b00,       
                S2 = 2'b01,   
                S3 = 2'b10,   
                S4 = 2'b11; 

// RGB light, inverted logic; 111 means all OFF; 011 means R is ON, G and B are OFF
parameter       led_s1 = 6'b101011,   // '101' for Green, '011' for RED
                led_s2 = 6'b001011,   // '001' for Yellow, '011' for RED (yellow is not obvious)
                led_s3 = 6'b011101,   // '011' for Red, '101' for Green
                led_s4 = 6'b011001;   // '011' for Red, '001' for Yellow

// RGB light behaviors in each state
always @ (*)   begin
    case  (state)  
        S1:  RGB_out = led_s1; 
        S2:  RGB_out = led_s2; 
        S3:  RGB_out = led_s3; 
        S4:  RGB_out = led_s4; 
        default:  RGB_out = led_s1; 
    endcase
end

/**************************************   Integer Clock Divider  **********************************
	>>	Instantiate the clock divider module, and divide the 12MHz clock frequency by
	12000000 time thus generated a 1Hz clock signal
  *************************************************************************************************/	
wire clk1hz;
divider_integer # (.WIDTH (24),.N (12_000_000)) u1  (    
    .clk        (clk),      
    .clkout     (clk1hz)     
);

/***********************************   Traffic Control State Machine  ****************************/
// Implementing the state machine; use the 1Hz clock signal
reg	[4:0] time_cnt;		// Reserve 5 bit register space for timer counter
always @ (posedge clk1hz or negedge rst_n) begin
    if(!rst_n) begin
        state <= S1; 
        time_cnt <= 0;
    end
    else begin
        case  (state)  
            S1: if  (time_cnt < 4'd15) begin	// 15s
                    state <= S1; 
                    time_cnt <= time_cnt + 1; 
                end
                else begin
                    state <= S2; 
                    time_cnt <= 0; 
                end
            S2: if  (time_cnt < 4'd3) begin		// 3s
                    state <= S2; 
                    time_cnt <= time_cnt + 1; 
                end
                else begin
                    state <= S3; 
                    time_cnt <= 0; 
                end
            S3: if  (time_cnt < 4'd7) begin		// 7s
                    state <= S3; 
                    time_cnt <= time_cnt + 1; 
                end
                else begin
                    state <= S4; 
                    time_cnt <= 0; 
                end 
            S4: if  (time_cnt < 4'd3) begin		// 3s
                    state <= S4; 
                    time_cnt <= time_cnt + 1; 
                end
                else begin
                    state <= S1; 
                    time_cnt <= 0; 
                end
            default: begin
                    state <= S1; 
                    time_cnt <= 0;
            end
        endcase 
    end
end 
endmodule



/**************************************   Integer Clock Divider  **********************************
	>>	Frequency divider code; seen in Section 3.7 of the book
  *************************************************************************************************/	
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

