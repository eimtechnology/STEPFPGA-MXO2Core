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
