/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			RotEncoderTX.v
*- Top Module name: 	RotEncoderTX
  - Submodules:		RotEncoder, ByteGen, Uart_Send, BaudGen, Uart_Tx
*- Description:			Send the data of Incremental Rotary Encoder through TX line of UART
*- 
*- Example of Usage:
	With this module, you can connect to an incremental Rotary Encoder and send the data to computer
	COM port through TX line. If you have SerialPlot, you can view the plotted data.
	Make sure the Encoder is corrected powered (3.3V -> VCC, 0V -> GND)
	
*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module RotEncoderTX 
(
	input	clk, rst_n,
	input	key_A, key_B, key_S1,
	output	tx
);

// Instantiate RotEncoder module
wire	ROT_cc_pulse, ROT_ccw_pulse;
RotEncoder U1 (clk, rst_n, key_A, key_B, ROT_cc_pulse, ROT_ccw_pulse);

// Instantiate ByteGen module, which converts RotEncoder data into 8-bit TXdata to be sent
wire	[7:0]	txData;
ByteGen	U2 (clk, rst_n, ROT_cc_pulse, ROT_ccw_pulse, txData);

// The OR gate that triggers the 'tx_en' of the UART_Tx module
wire	enableCC_CCW;
or (enableCC_CCW, ROT_cc_pulse, ROT_ccw_pulse);

// Instantiate Uart_Send module to send data through TX
Uart_Send U3 (clk, rst_n, enableCC_CCW, txData, tx);
endmodule



/*********************************** Description of submodules: Uart_Send *********************************/
module Uart_Send #(parameter BPS_PARA = 1250) // For Baud Rate 9600
(
	input	clk, rst_n,
	input 	tx_en,				// enable tranmission when tx_en has a falling edge
	/**** bitstream data packet, if you want to communicate	to computer via
	the COM port, connect this tx to the TX pin of STEPFPGA-Core Board ***/
	input	[7:0]	tx_data,	// 8-bit data to be sent out through tx line
	output	tx					// bitstream datapack with '1' and '0' added at two ends
);		

/************ Instantiate BaudGen submodule to generate standard BaudRates ************/
wire	bps_en,bps_clk;
BaudGen # (.BPS_PARA(BPS_PARA)) U1 (
	.clk		(clk),	
	.rst_n		(rst_n),	
	.bps_en		(bps_en),	// Connects to bps_en on UART_Tx
	.bps_clk	(bps_clk)	// Connects to bps_clk on UART_Tx
);

/**************** Instantiate UART_Tx submodul ready to transmit data *****************/
Uart_Tx U2 (
	.clk		(clk),				
	.rst_n		(rst_n),			
	.bps_en		(bps_en),			// Connects to bps_en on BaudGen
	.bps_clk	(bps_clk),			// Connects to bps_clk on BaudGen
	.tx_en		(tx_en),
	.tx_data	(tx_data),		
	.tx			(tx)				// bitstream datapack sending to rx of hardware B
);
endmodule



/*********************************** Description of submodules: BaudGen *********************************/
module BaudGen # (parameter BPS_PARA = 1250)(
	input					clk, rst_n,	
	input					bps_en,		// Connects to bps_en on UART_Tx
	output	reg				bps_clk		// Connects to bps_clk on UART_Tx
);	
 
reg				[12:0]	cnt;
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) 
		cnt <= 1'b0;
	else if((cnt >= BPS_PARA-1)||(!bps_en)) // if bps_en is low, stop Bauds
		cnt <= 1'b0;						
	else 
		cnt <= cnt + 1'b1;
end
 
// Setup for different Bauds according to the parameter given
always @ (posedge clk or negedge rst_n)
	begin
		if(!rst_n) 
			bps_clk <= 1'b0;
		else if(cnt == (BPS_PARA>>1)) 	// Use the middle point for sampling, see Figure 5.6.x 
			bps_clk <= 1'b1;	
		else 
			bps_clk <= 1'b0;
	end
endmodule

/**************************************** Description of submodules: Uart_Tx *********************************/
module Uart_Tx (
	input					clk, rst_n,			
	input					bps_clk,			// Connects to bps_en on BaudGen
	output	reg				bps_en,				// Connects to bps_clk on BaudGen
	input					tx_en,				// Enable tranmission when tx_en is high
	input			[7:0]	tx_data,			// The 8-bit data to be sent to receiver (e.g. 8'b00001011)
	output	reg				tx					// The bitstream data packet for tx_data (e.g. 1_00001011_0)
);
 
reg	  tx_en_r;
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) 
		tx_en_r <= 1'b0;
	else 
		tx_en_r <= tx_en;
end
 
// When a falling edge is detected meaning start to transmit one data byte
wire	neg_tx_en = tx_en_r & (~tx_en);
reg				[3:0]	num;
reg				[9:0]	tx_data_r;	

// Based on UART protocol, add '1' at start and '0' at end of the data byte
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		bps_en <= 1'b0;
		tx_data_r <= 8'd0;
	end else if(neg_tx_en)begin	
		bps_en <= 1'b1;						// when bps_en is high, add '1' and '0' to the data byte
		tx_data_r <= {1'b1,tx_data,1'b0};	
	end else if(num==4'd10) begin			// when sent out 10 bits, go back to idle by setting bps_en to low
		bps_en <= 1'b0;	
	end
end
 
// Send the 10 bits data sequentially through tx line
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		num <= 1'b0;
		tx <= 1'b1;
	end else if(bps_en) begin
		if(bps_clk) begin
			num <= num + 1'b1;
			tx <= tx_data_r[num];
		end else if(num>=4'd10) 
			num <= 4'd0;	
	end
end
endmodule

/**************************************** Description of submodules: RotEncoder *********************************/
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

/**************************************** Description of submodules: ByteGen *********************************/
module ByteGen (
	input				clk,rst_n,			
	input				pulse1, pulse2,
	output	reg	[7:0]	dataByte
);

//key_pulse transfer to dataByte
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		dataByte <= 8'b0000_0000;
	end else begin
		if(pulse1) begin
			dataByte <= dataByte - 1'b1;
		end 
		else if(pulse2) begin
			dataByte <= dataByte + 1'b1;
		end 
		else begin
			dataByte <= dataByte;
		end
	end
end

endmodule