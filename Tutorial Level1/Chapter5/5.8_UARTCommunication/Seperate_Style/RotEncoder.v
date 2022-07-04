/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			RotEncoder.v
*- Top Module name: 	RotEncoder
  - Submodules:		
*- Description:			Interface with an incremental rotary encoder
					
*- Example of Usage:
       - This code interfaces with an incremental rotary encoder. Connect Key_A and Key_B to
	the two phase outputs of the encoder; you can also add additional input to interface with
	the OK Press function of the encoder which is essentially a pushbutton. 
	CC_pulse and CCW_pulse indicates for rotating orientations. 
	
* - Read more details in Chapter 5 (UART Communication) of the tutorial book.
   
*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module RotEncoder (
	input			clk, rst_n,	
	input			key_A, key_B,			
	output	reg		CC_pulse, CCW_pulse
);
	
localparam				NUM_250US = 3_000;

/************* Eliminate the glitches unstable signals during movement ********/
reg	[12:0]	cnt;											//
//count for clk_500us                                                                                                         //
always@(posedge clk or negedge rst_n) begin                 //
	if(!rst_n) cnt <= 0;                                    //
	else if(cnt >= NUM_250US-1) cnt <= 1'b0;                //
	else cnt <= cnt + 1'b1;                                 //
end                                                         //
reg	clk_500us;	                                            //
always@(posedge clk or negedge rst_n) begin                 //
	if(!rst_n) clk_500us <= 0;                              //
	else if(cnt == NUM_250US-1) clk_500us <= ~clk_500us;    //
	else clk_500us <= clk_500us;                            //
end                                                         //
reg	key_A_r,key_A_r1,key_A_r2;                              //
always@(posedge clk_500us) begin                            //
	key_A_r		<=	key_A;                                  //
	key_A_r1	<=	key_A_r;                                //
	key_A_r2	<=	key_A_r1;                               //
end                                                         //
reg	A_state;                                                //
always@(key_A_r1 or key_A_r2) begin                         //
	case({key_A_r1,key_A_r2})                               //
		2'b11:	A_state <= 1'b1;                            //
		2'b00:	A_state <= 1'b0;                            //
		default: A_state <= A_state;                        //
	endcase                                                 //
end                                                         //
reg	key_B_r,key_B_r1,key_B_r2;                              //
always@(posedge clk_500us) begin                            //
	key_B_r		<=	key_B;                                  //
	key_B_r1	<=	key_B_r;                                //
	key_B_r2	<=	key_B_r1;                               //
end                                                         //
reg	B_state;                                                //
always@(key_B_r1 or key_B_r2) begin                         //
	case({key_B_r1,key_B_r2})                               //
		2'b11:	B_state <= 1'b1;                            //
		2'b00:	B_state <= 1'b0;                            //
		default: B_state <= B_state;                        //
	endcase                                                 //
end                                                         //
/*************************************************************************************/

// Detects the edge transition of Signal A on Rotary Encoder
reg A_state_r,A_state_r1;
always@(posedge clk) begin
	A_state_r <= A_state; 
	A_state_r1 <= A_state_r;
end
wire	A_pos	= (!A_state_r1) && A_state_r;
wire	A_neg	= A_state_r1 && (!A_state_r);

// If A is posedge and B is HIGH, or if A is falling edge and B is LOW, then clockwise
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) CC_pulse <= 1'b0;
	else if((A_pos&&B_state)||(A_neg&&(!B_state))) CC_pulse <= 1'b1;
	else CC_pulse <= 1'b0;
end 

// If A is posedge and B is LOW, or if A is falling edge and B is HIGH, then counterclockwise
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) CCW_pulse <= 1'b0;
	else if((A_pos&&(!B_state))||(A_neg&&B_state)) CCW_pulse <= 1'b1;
	else CCW_pulse <= 1'b0;
end 
endmodule