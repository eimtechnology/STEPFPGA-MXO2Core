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

module RotEncoderTX_Top 
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