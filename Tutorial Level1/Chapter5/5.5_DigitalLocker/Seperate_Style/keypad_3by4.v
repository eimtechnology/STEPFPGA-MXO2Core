/* 	
File name: keypad_3by4
Module Function: Interfacing with a 3x4 matrix keypad 

This example code can also be found in Chapter 5 of the STEPFPGA tutorial book written by EIM Technology.
Website: www.eimtechnology.com

Note: You need to connect 3 PULL UP resistors at the 3 col pins (1k-10k)
Copyright License: MIT
*/

module keypad_3by4 (
	input					clk,		
	input					rst_n,		
	input			[2:0]	col,		// the 3 output signals for 3 Columns 
	output	reg		[3:0]	row,		// the 4 input signals for 4 Rows 
	output	reg		[3:0]	keyPressed,
	
	 output	reg		[8:0]	seg_led_1,
	 output	reg		[8:0]	seg_led_2
);

	localparam			NUM_FOR_200HZ = 60000;	// Used to generate a 200Hz frequency for column scanning
	localparam			ROW0_SCAN = 2'b00;      // the state when scanning first row
	localparam			ROW1_SCAN = 2'b01;      // the state when scanning second row
	localparam			ROW2_SCAN = 2'b10;      // the state when scanning third row
	localparam			ROW3_SCAN = 2'b11;		// the state when scanning forth row
 
	reg		[11:0]	key,key_r;
	reg		[11:0]	key_out;		// debounce all keys

	reg		[15:0]	cnt;
	reg				clk_200hz;
	
	// generate a 200Hz clock
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin		
			cnt <= 16'd0;
			clk_200hz <= 1'b0;
		end else begin
			if(cnt >= ((NUM_FOR_200HZ>>1) - 1)) begin	//  >>1 means divide by 2
				cnt <= 16'd0;
				clk_200hz <= ~clk_200hz;	
			end else begin
				cnt <= cnt + 1'b1;
				clk_200hz <= clk_200hz;
			end
		end
	end
 
	reg		[1:0]		c_state;
	always@(posedge clk_200hz or negedge rst_n) begin
		if(!rst_n) begin
			c_state <= ROW0_SCAN;
			row <= 4'b1110;
		end else begin
			case(c_state)
				ROW0_SCAN: begin c_state <= ROW1_SCAN; row <= 4'b1101; end	
				ROW1_SCAN: begin c_state <= ROW2_SCAN; row <= 4'b1011; end
				ROW2_SCAN: begin c_state <= ROW3_SCAN; row <= 4'b0111; end
				ROW3_SCAN: begin c_state <= ROW0_SCAN; row <= 4'b1110; end
				default:begin c_state <= ROW0_SCAN; row <= 4'b1110; end
			endcase
		end
	end
 
always@(negedge clk_200hz or negedge rst_n) begin
	if(!rst_n) begin
		key_out <= 12'hfff;
	end else begin
		case(c_state)
			ROW0_SCAN: begin 				// check for colum 0, 1, 2
						key[2:0] <= col;    
						key_r[2:0] <= key[2:0];    
						key_out[2:0] <= key_r[2:0]|key[2:0];   // double comfirm the pressed key
						
					end 
			ROW1_SCAN:begin 				// check for colum 3, 4, 5
						key[5:3] <= col;    
						key_r[5:3] <= key[5:3];    
						key_out[5:3] <= key_r[5:3]|key[5:3];   // double comfirm the pressed key
						
					end 
			ROW2_SCAN:begin 
						key[8:6] <= col;    // check for colum 6, 7, 8
						key_r[8:6] <= key[8:6];   
						key_out[8:6] <= key_r[8:6]|key[8:6];   // double comfirm the pressed key
						
					end 
			ROW3_SCAN:begin 
						key[11:9] <= col;    // check for colum 9, 10, 11
						key_r[11:9] <= key[11:9];    
						key_out[11:9] <= key_r[11:9]|key[11:9]; // double comfirm the pressed key
						
					end 
			default:key_out <= 12'hfff;
		endcase
	end
end
	
	
reg	[3:0]	key_code;	

reg		[11:0]		key_out_r;
wire	[11:0]		 key_pulse;
always @ ( posedge clk  or  negedge rst_n )begin
	if (!rst_n) key_out_r <= 12'hfff;
	else  key_out_r <= key_out;  
end 

assign key_pulse= key_out_r & (~key_out);   

always@(*)begin
	case(key_pulse)
		12'b0000_0000_0001: key_code=4'd1 ;	// key 1
		12'b0000_0000_0010: key_code=4'd2 ;	// key 2
		12'b0000_0000_0100: key_code=4'd3 ;	// key 3
		12'b0000_0000_1000: key_code=4'd4 ;	// key 4
		12'b0000_0001_0000: key_code=4'd5 ; // key 5
		12'b0000_0010_0000: key_code=4'd6 ; // key 6
		12'b0000_0100_0000: key_code=4'd7 ; // key 7
		12'b0000_1000_0000: key_code=4'd8 ; // key 8
		12'b0001_0000_0000: key_code=4'd9 ;	// key 9
		12'b0010_0000_0000: key_code=4'd10;	// key *
		12'b0100_0000_0000: key_code=4'd0 ;	// key 0
		12'b1000_0000_0000: key_code=4'd12;	// key #
		default: key_code=4'd15;           
	endcase                                
end                                        
                                           
always@(posedge clk or  negedge rst_n)begin
	if(!rst_n) 	keyPressed <= 4'd15;
	else			keyPressed<=key_code;
end 

	
always@(posedge clk)begin
	case(keyPressed)
	4'd0: begin seg_led_1<=9'h3f;			seg_led_2<=9'h3f;	end 
	4'd1: begin seg_led_1<=9'h06;			seg_led_2<=9'h06;	end 
	4'd2: begin seg_led_1<=9'h5b;			seg_led_2<=9'h5b;	end
	4'd3: begin seg_led_1<=9'h4f;			seg_led_2<=9'h4f;	end
	4'd4: begin seg_led_1<=9'h66;			seg_led_2<=9'h66;	end
	4'd5: begin seg_led_1<=9'h6d;			seg_led_2<=9'h6d;	end
	4'd6: begin seg_led_1<=9'h7d;			seg_led_2<=9'h7d;	end 
	4'd7: begin seg_led_1<=9'h07;			seg_led_2<=9'h07;	end
	4'd8: begin seg_led_1<=9'h7f;			seg_led_2<=9'h7f;	end
	4'd9: begin seg_led_1<=9'h6f;			seg_led_2<=9'h6f;	end 
	4'd10: begin seg_led_1<=9'h77;			seg_led_2<=9'h77;	end
	4'd12: begin seg_led_1<=9'h39;			seg_led_2<=9'h39;	end	
	default:begin seg_led_1<=seg_led_1;		seg_led_2<=seg_led_2;	end
	endcase 
end 
endmodule
