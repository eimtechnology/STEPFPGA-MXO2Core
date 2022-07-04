/* 	
File name: LEDchaser
Module Function: The 8 LED on STEPFPGA board sequentially turning ON and OFF

This example code can also be found in Chapter 5.1 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

module LEDchaser  (
    input clk,
    output reg [7:0] LEDs
) ;

/********************** Defining the 8 states with binary numbers *********************/
parameter   S0 = 3'b000,   
            S1 = 3'b001,   
            S2 = 3'b010,   
            S3 = 3'b011,   
            S4 = 3'b100,   
            S5 = 3'b101,   
            S6 = 3'b110,   
            S7 = 3'b111; 

/***********************  Describing the LED actions in each state  **********************
	>> According to the state diagram in the book, the LEDs lighting pattern
	in each state is different; there is only 1 LED turning on at each state so
	the rest bits should be 1 (LED is connected via inverting logic.
*******************************************************************************************/
reg [2: 0] state;                   
always @ (posedge clk)   begin     
    case   (state)  
        S0:  LEDs = 8'b11111110;  
        S1:  LEDs = 8'b11111101;  
        S2:  LEDs = 8'b11111011;  
        S3:  LEDs = 8'b11110111;  
        S4:  LEDs = 8'b11101111;  
        S5:  LEDs = 8'b11011111;  
        S6:  LEDs = 8'b10111111;  
        S7:  LEDs = 8'b01111111;  
    endcase
end

/***********************  Enable jumping among different states  **********************
	>> The time interval between the ON and OFF time of two adjacent LEDs is 50ms
	which is equal to 600000 counts of a 12MHz clock; use a counter for 24-bits to 
	hold enough space for 600000.
*******************************************************************************************/
reg [23: 0] cnt; 
parameter CNT_NUM = 600000;       
always @  (posedge clk)   begin
    if   (cnt == CNT_NUM-1)  
        cnt <= 20'b0; 
    else
        cnt <= cnt + 1'b1;           
end
always @  (posedge clk)   begin
    if   (cnt == CNT_NUM-1)  
        state <= state + 1'b1; 
end
endmodule
