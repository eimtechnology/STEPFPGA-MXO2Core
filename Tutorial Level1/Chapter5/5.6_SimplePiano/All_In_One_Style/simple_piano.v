module simple_piano (
	input 		clk, 
	input		keyC4,keyC4h,keyD4,keyD4h,keyE4,keyF4,
				keyF4h,keyG4,keyG4h,keyA4,keyA4h,keyB4,keyC5,
	output reg	[9:0] simpletone
);

wire [9:0] toneC4; 
sin_anyfreq #(93664)  C4 	 (clk, toneC4);
wire [9:0] toneC4half;       
sin_anyfreq #(99230)  C4half (clk, toneC4half);
wire [9:0] toneD4;           
sin_anyfreq #(105130) D4 	 (clk, toneD4);	 
wire [9:0] toneD4half;       
sin_anyfreq #(111385) D4half (clk, toneD4half);
wire [9:0] toneE4;           
sin_anyfreq #(118008) E4 	 (clk, toneE4);
wire [9:0] toneF4;           
sin_anyfreq #(125024) F4 	 (clk, toneF4);
wire [9:0] toneF4half;       
sin_anyfreq #(132456) F4half (clk, toneF4half);
wire [9:0] toneG4;           
sin_anyfreq #(140336) G4 	 (clk, toneG4);
wire [9:0] toneG4half;       
sin_anyfreq #(148677) G4half (clk, toneG4half);
wire [9:0] toneA4;           
sin_anyfreq #(157520) A4 	 (clk, toneA4);
wire [9:0] toneA4half;       
sin_anyfreq #(166885) A4half (clk, toneA4half);
wire [9:0] toneB4;           
sin_anyfreq #(176809) B4 	 (clk, toneB4);
wire [9:0] toneC5; 
sin_anyfreq #(187324) C5 	 (clk, toneC5);

wire [12:0] keyset;
assign keyset = {keyC4,keyC4h,keyD4,keyD4h,
				 keyE4,keyF4,keyF4h,keyG4,
				 keyG4h,keyA4,keyA4h,keyB4,keyC5};

always @ (posedge clk) begin
	case (keyset)
		13'b0_1111_1111_1111: simpletone = toneC4;
		13'b1_0111_1111_1111: simpletone = toneC4half;
		13'b1_1011_1111_1111: simpletone = toneD4;
		13'b1_1101_1111_1111: simpletone = toneD4half;
		13'b1_1110_1111_1111: simpletone = toneE4;
		13'b1_1111_0111_1111: simpletone = toneF4;
		13'b1_1111_1011_1111: simpletone = toneF4half;
		13'b1_1111_1101_1111: simpletone = toneG4;
		13'b1_1111_1110_1111: simpletone = toneG4half;
		13'b1_1111_1111_0111: simpletone = toneA4;
		13'b1_1111_1111_1011: simpletone = toneA4half;
		13'b1_1111_1111_1101: simpletone = toneB4;
		13'b1_1111_1111_1110: simpletone = toneC5;
		default: simpletone = 10'b0000000000;
	endcase
end
endmodule


/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			sin_anyfreq.v
*- Top Module name: 	sin_anyfreq
  - Submodules:		lookup_tables, SINE_LUT
*- Description:			Generate arbitrary frequency 10-bit sin wave
*- 
*- Example of Usage:
	Refer to the STEPFPGA tutorial book Chapter 5 for more details
		f_out = M * f_clk/(2^N), since f_clk = 12MHz, N = 32 bit, so we have:
			M = f_out * 358
	To obtain any desired frequency of the sinusoidal signal, you only need to tone for M
* - You can connect a parallel input 10 bit DAC to view the analog sinusoidal wave

*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module sin_anyfreq # (
    parameter M = 93664				// tone this value for different frequencies of the SIN wave
									// For M = 93664, you will get f_out = 261.63Hz
)
(
	input clk,               
	output [9:0] sin_digital      
);
	
reg [31:0] 	phase_acc;				// Here we used N = 32 thus the phase accumulator has 2^N states!
always @(posedge clk) begin
	phase_acc <= phase_acc + M;  	
end

lookup_tables u1 (
	.phase(phase_acc[31:24]), 		// Taking the first 8 bits from the phase accumulator
	.sin_out(sin_digital)			// - is sufficient for a decently smooth sin wave
);
endmodule


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
 
 
/**************** This module is a look-up table for 1/4 data of a 10-bit SIN wave **************/
module SINE_LUT (
	input  [5:0] address,
	output [8:0] sin
);
reg    [8:0] sin;
always @(address) begin
       case(address)	
           6'h0: sin=9'h0;
           6'h1: sin=9'hC;
           6'h2: sin=9'h19;
           6'h3: sin=9'h25;
           6'h4: sin=9'h32;
           6'h5: sin=9'h3E;
           6'h6: sin=9'h4B;
           6'h7: sin=9'h57;
           6'h8: sin=9'h63;
           6'h9: sin=9'h70;
           6'ha: sin=9'h7C;
           6'hb: sin=9'h88;
           6'hc: sin=9'h94;
           6'hd: sin=9'hA0;
           6'he: sin=9'hAC;
           6'hf: sin=9'hB8;
           6'h10: sin=9'hC3;
           6'h11: sin=9'hCF;
           6'h12: sin=9'hDA;
           6'h13: sin=9'hE6;
           6'h14: sin=9'hF1;
           6'h15: sin=9'hFC;
           6'h16: sin=9'h107;
           6'h17: sin=9'h111;
           6'h18: sin=9'h11C;
           6'h19: sin=9'h126;
           6'h1a: sin=9'h130;
           6'h1b: sin=9'h13A;
           6'h1c: sin=9'h144;
           6'h1d: sin=9'h14E;
           6'h1e: sin=9'h157;
           6'h1f: sin=9'h161;
           6'h20: sin=9'h16A;
           6'h21: sin=9'h172;
           6'h22: sin=9'h17B;
           6'h23: sin=9'h183;
           6'h24: sin=9'h18B;
           6'h25: sin=9'h193;
           6'h26: sin=9'h19B;
           6'h27: sin=9'h1A2;
           6'h28: sin=9'h1A9;
           6'h29: sin=9'h1B0;
           6'h2a: sin=9'h1B7;
           6'h2b: sin=9'h1BD;
           6'h2c: sin=9'h1C3;
           6'h2d: sin=9'h1C9;
           6'h2e: sin=9'h1CE;
           6'h2f: sin=9'h1D4;
           6'h30: sin=9'h1D9;
           6'h31: sin=9'h1DD;
           6'h32: sin=9'h1E2;
           6'h33: sin=9'h1E6;
           6'h34: sin=9'h1E9;
           6'h35: sin=9'h1ED;
           6'h36: sin=9'h1F0;
           6'h37: sin=9'h1F3;
           6'h38: sin=9'h1F6;
           6'h39: sin=9'h1F8;
           6'h3a: sin=9'h1FA;
           6'h3b: sin=9'h1FC;
           6'h3c: sin=9'h1FD;
           6'h3d: sin=9'h1FE;
           6'h3e: sin=9'h1FF;
           6'h3f: sin=9'h1FF;
       endcase
	end
endmodule