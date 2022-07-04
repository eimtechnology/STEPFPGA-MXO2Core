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
