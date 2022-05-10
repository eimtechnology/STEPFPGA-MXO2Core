/* 	
File name: dff
Module Function: Implementation of a 1-bit D Flip-Flop

This code implement the logic functions of a D Flip-Flop on STEPFPGA board using Verilog.
This example code can also be found in Chapter 3 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Copyright License: MIT
*/

module dff(input clk, D, output reg Q);
    always @ (posedge clk) begin
        Q <= D;
    end
endmodule
