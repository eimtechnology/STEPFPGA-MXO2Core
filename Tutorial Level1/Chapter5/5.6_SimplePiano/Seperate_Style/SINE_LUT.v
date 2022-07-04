 
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