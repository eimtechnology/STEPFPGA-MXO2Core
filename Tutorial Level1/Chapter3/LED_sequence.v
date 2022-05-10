/* 
A visible simple example to understand how a Counter works
The code can be found in Chapter 3 of the STEPFPGA book written by EIM Technology  
This code uses a counter with 4 time flags to sequentially turn on 4 LEDs 

Copyright License: MIT
*/

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
           
always @  (posedge clk)  begin   
    if  (!rst_n)  
        cnt <= 0;               
    else
        cnt <= cnt + 1'b1;      
end

assign led[0] =  (cnt < t_1s)  ? 1 : 0;
assign led[1] =  (cnt < t_2s)  ? 1 : 0;   
assign led[2] =  (cnt < t_3s)  ? 1 : 0;   
assign led[3] =  (cnt < t_4s)  ? 1 : 0;   

endmodule
