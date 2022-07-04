/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			Uart_Send.v
*- Top Module name: 	BaudGen, Uart_Tx
  - Submodules:		
*- Description:			UART Transmitter module that sends data at adjustable BAUDs
*- 
*- Example of Usage:
	This Uart_Send module is able to send data through the TX line of the STEPFPGA board.
	To use this module, you can set for different standard Baud Rates by changing the parameter
	'BPS_PARA', calculated with 12MHz/BAUDs if using the system clock on STEPFPGA Core board. 
	The 8-bit input 'tx_data' is the parallel data received by the module, and the output 'tx' is the 
	serial encoded UART data (no parity) to be sent out. 
	While assigning the FPGA pins, assign this tx signal to the TX pin (interal) on the STEPFPGA.
	
*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

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