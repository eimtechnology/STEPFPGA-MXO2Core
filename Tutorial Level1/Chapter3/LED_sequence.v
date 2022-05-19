/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			LED_sequence.v
*- Top Module name: 	LED_sequence
  - Submodules:		N/A
*- Description:			Experiment with counters
*- 
*- Example of Usage:
	You can implement this code on all variants of STEPFPGA family boards. 
	If you want to implement this code on board and observe the logic behaviors: 
		- assign clk to PCLK (12MHz) on-board clock
		- assign rst_n to any push-buttons on-board
		- assign led[3] ... led[0] to 4 on-board LEDs

*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module LED_sequence   (
    input       clk,             
    input       rst_n,           
    output      [3:0] led
) ; 

reg [25: 0] cnt;                 
parameter t_1s = 12_000_000,     
          t_2s = 24_000_000,     
          t_3s = 36_000_000,     
          t_4s = 48_000_000;     
           
always @  (posedge clk or negedge rst_n)  begin   
    if  (!rst_n)  
        cnt <= 0;               
    else
        cnt <= cnt + 1'b1;      
end

assign led[0] =  (cnt < t_1s)  ? 1 : 0;        // Conditional assignment
assign led[1] =  (cnt < t_2s)  ? 1 : 0;        // If (true), assign to 1; otherwise assign to 0
assign led[2] =  (cnt < t_3s)  ? 1 : 0;         
assign led[3] =  (cnt < t_4s)  ? 1 : 0;       

endmodule
