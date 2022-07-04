
/**************** This module generates a complete cycle of a 10-bit SIN wave **************/
module lookup_tables (
	input  	[7:0] 	phase,
	output 	[9:0] 	sin_out
);
wire    [9:0]   sin_out;
reg   	[5:0] 	address;
wire   	[1:0] 	sel;
wire   	[8:0] 	sine_table_out;
reg     [9:0]   sine_onecycle_amp;
assign sin_out = sine_onecycle_amp[9:0];
assign sel = phase[7:6];
SINE_LUT u1 (address, sine_table_out);
always @(sel or sine_table_out) begin
	case(sel)
	2'b00: 	begin
			sine_onecycle_amp = 9'h1ff + sine_table_out[8:0];
			address = phase[5:0];
	     	end
  	2'b01: 	begin
			sine_onecycle_amp = 9'h1ff + sine_table_out[8:0];
			address = ~phase[5:0];
	     	end
  	2'b10: 	begin
			sine_onecycle_amp = 9'h1ff - sine_table_out[8:0];
			address = phase[5:0];
     		end
  	2'b11: 	begin
			sine_onecycle_amp = 9'h1ff - sine_table_out[8:0];
			address = ~ phase[5:0];
     		end
	endcase
end
endmodule