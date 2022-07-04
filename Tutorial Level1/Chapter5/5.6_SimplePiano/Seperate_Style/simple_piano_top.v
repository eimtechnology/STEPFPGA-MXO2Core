module simple_piano_top (
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