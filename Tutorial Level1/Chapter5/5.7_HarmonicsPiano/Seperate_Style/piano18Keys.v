/*--------------------------------------------------------------------------------------------------- 	
*- File name: 			piano18key.v
*- Top Module name: 	piano18key
  - Submodules:			HarmonicGen_EN, sin_anyfreq, ampAdjust, lookup_tables, SINE_LUT, ampAdjust, DeltaSigma
*- Description:			Generate 1-bit PDM signal containing the fundamental frequency and 2nd harmonics
					
*- Example of Usage:
       - This code generates 1-bit PDM signal 00for 18 input keys (piano module), where all keys are set to pull-up
	network with 1kohm. You can assign the output to any GPIO and then place a low pass filter to obtain an 
	analog output wave. The 'sum18' sums all 11-bit data (2nd harmoncis added), which in theorey should have 
	16 bit. But using 16 bit will signicantly attentuate the magnitude, so we use 12 bit data in this code, and keep
	in mind that some frequencies may get clipped when you press multiple keys simulaneously
	
       - Addional note: you can use a larger gain audio amplifier to boost up the volume
	   
* - Read more details in Chapter 5 (complex piano) of the tutorial book.
   
*- Copyright of this code: MIT License
--------------------------------------------------------------------------------------------------- */

module piano18key_top (
	input clk,
	input [17:0] key,
	output PDMHarmout		// connects to a low pass RC filter (1k, 10nF)
);

wire [10:0] toneC4;
HarmonicGen_EN #(93664)	  C4	 	(clk, key[0], !key[0], toneC4);
wire [10:0] toneC4half;                              
HarmonicGen_EN #(99230)	  C4half	(clk, key[1], !key[1], toneC4half);
wire [10:0] toneD4;                                  
HarmonicGen_EN #(105130)  D4		(clk, key[2], !key[2], toneD4);
wire [10:0] toneD4half;                               
HarmonicGen_EN #(111385)  D4half	(clk, key[3], !key[3], toneD4half);
wire [10:0] toneE4;                                   
HarmonicGen_EN #(118008)  E4	 	(clk, key[4], !key[4], toneE4);
wire [10:0] toneF4;                                   
HarmonicGen_EN #(125024)  F4	 	(clk, key[5], !key[5], toneF4);
wire [10:0] toneF4half;                               
HarmonicGen_EN #(132456)  F4half	(clk, key[6], !key[6], toneF4half);
wire [10:0] toneG4;                                   
HarmonicGen_EN #(140336)  G4	 	(clk, key[7], !key[7], toneG4);
wire [10:0] toneG4half;                              
HarmonicGen_EN #(148677)  G4half	(clk, key[8], !key[8], toneG4half);
wire [10:0] toneA4;                                  
HarmonicGen_EN #(157520)  A4	 	(clk, key[9], !key[9], toneA4);
wire [10:0] toneA4half;                              
HarmonicGen_EN #(166885)  A4half	(clk, key[10], !key[10], toneA4half);
wire [10:0] toneB4;                                    
HarmonicGen_EN #(176809)  B4	 	(clk, key[11], !key[11], toneB4);
wire [10:0] toneC5;                                    
HarmonicGen_EN #(187324)  C5	 	(clk, key[12], !key[12], toneC5);
wire [10:0] toneC5half;                                
HarmonicGen_EN #(198464)  C5half	(clk, key[13], !key[13], toneC5half);
wire [10:0] toneD5;                                    
HarmonicGen_EN #(210264)  D5	 	(clk, key[14], !key[14], toneD5);
wire [10:0] toneD5half;                                
HarmonicGen_EN #(222766)  D5half	(clk, key[15], !key[15], toneD5half);
wire [10:0] toneE5;                                    
HarmonicGen_EN #(236012)  E5	 	(clk, key[16], !key[16], toneE5);
wire [10:0] toneF5;                                    
HarmonicGen_EN #(250049)  F5	 	(clk, key[17], !key[17], toneF5);

wire [11:0] sum18;
assign sum18 = toneC4 + toneC4half + toneD4 + toneD4half + toneE4 + toneF4 + toneF4half + toneG4 + 
toneG4half + toneA4 + toneA4half + toneB4 + toneC5 + toneC5half + toneD5 + toneD5half + toneE5 + toneF5;

DeltaSigma PDMGen (clk, sum18, PDMHarmout);
endmodule


/**************************************************************************************************************************/
/******************  Instantiate this module to generate 11-bit data for base and 2nd harmonics *******************/
module HarmonicGen_EN # (parameter M = 93664)
(
	input clk, key, EN_n,
	output wire [10:0] HarmOut
);

wire [9:0] signal1;
wire [9:0] dac_Data1;	
sin_anyfreq # (.M(M)) SIN1 (clk, signal1);						
ampAdjust #(.numerator(256)) ampSIN1 (clk, signal1, dac_Data1);

wire [9:0] signal2;
wire [9:0] dac_Data2;
sin_anyfreq # (.M(M*2)) SIN2 (clk, signal2);						
ampAdjust #(.numerator(64)) ampSIN2 (clk, signal2, dac_Data2);

assign HarmOut = EN_n ?(dac_Data1 + dac_Data2):0;

endmodule

/**********************************************************************************************/
/******************  Instantiate this module to generate 10-bit sin data *******************/
module sin_anyfreq # (
    parameter M = 93664				// Tune this value for different frequencies of the SIN wave
									// For M = 93664, you will get f_out = 261.63Hz
)
(
	input clk,               
	output [9:0] sin_digital      
);
	
reg [31:0] 	accumulator;				// Here we used N = 32 thus the phase accumulator has 2^N states!
always @(posedge clk) begin
	accumulator <= accumulator + M;  	
end

lookup_tables u1 (accumulator[31:24],sin_digital);
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

/**********************************************************************************************/
/********************************  Instantiate ampAdjust module ***************************/
module ampAdjust #(parameter numerator = 256)				
(	
    input clk,
    input [9:0] digitalSignal,
    output[9:0] dac_Data
);

reg [17:0] amp_data;
always @(posedge clk) 
	amp_data = digitalSignal * numerator;	
	
assign dac_Data = amp_data[17:8]; 	
endmodule

/*************************************************************************************************************************************/
/********************************  Instantiate DeltaSigma module to convert a single bit PDM output ***************************/
module DeltaSigma (
	input	clk,
	input 	[11:0] data_in,
	output	PDM_out
);

// Sigma to delta conversion; reserve 1 extra bit than the input data
reg [12:0] accumulator;
always @(posedge clk) begin
	accumulator <= accumulator[11:0] + data_in;
end

assign PDM_out = accumulator[12]; 			// The MSB of the accumulator represents the pulses of PDM signal
endmodule
