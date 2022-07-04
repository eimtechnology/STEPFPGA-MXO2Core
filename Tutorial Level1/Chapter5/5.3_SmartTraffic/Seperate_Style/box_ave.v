//   ==================================================================
//   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
//   ------------------------------------------------------------------
//   Copyright (c) 2014 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED 
//   ------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement. 
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
//   --------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02 
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
//   --------------------------------------------------------------------
// --------------------------------------------------------------------
//
//  Project:     ADC_lvds
//  File:        box_ave.v
//  Title:       Box Filter Average
//  Description: Returns average of last N samples, with /N decimation
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
// $Log: RD#rd1066_simple_sigma_delta_adc#rd1066#source#verilog#box_ave.v,v $
// Revision 1.1  2015-02-05 00:00:54-08  mbevinam
// Updated RD Placed in RD Folder. Previous versions are in RD_Dimensions Archive folder.
//
// Revision	Date		
// 1.0		10/16/2009	S. Hossner   Initial Revision
//
// --------------------------------------------------------------------



//*********************************************************************
//
//	'Box' Average 
//
//  Standard Mean Average Calculation
//   Can be modeled as FIR Low-Pass Filter where 
//   all coefficients are equal to '1'.
//
//*********************************************************************



module box_ave (
	clk,
	rstn,
	sample,
	raw_data_in,
	ave_data_out,
    data_out_valid);

parameter 
ADC_WIDTH = 8,				// ADC Convertor Bit Precision
LPF_DEPTH_BITS = 4;         // 2^LPF_DEPTH_BITS is decimation rate of averager

//input ports
input	clk;                                // sample rate clock
input	rstn;	                            // async reset, asserted low
input	sample;				                // raw_data_in is good on rising edge, 
input	[ADC_WIDTH-1:0]	raw_data_in;		// raw_data input

//output ports
output [ADC_WIDTH-1:0]	ave_data_out;		// ave data output
output data_out_valid;                      // ave_data_out is valid, single pulse

reg [ADC_WIDTH-1:0]	ave_data_out;		
//**********************************************************************
//
//	Internal Wire & Reg Signals
//
//**********************************************************************
reg [ADC_WIDTH+LPF_DEPTH_BITS-1:0]      accum;          // accumulator
reg [LPF_DEPTH_BITS-1:0]                count;          // decimation count
reg [ADC_WIDTH-1:0]  					raw_data_d1;    // pipeline register

reg sample_d1, sample_d2;                               // pipeline registers
reg result_valid;                                       // accumulator result 'valid'
wire accumulate;                                        // sample rising edge detected
wire latch_result;                                      // latch accumulator result

//***********************************************************************
//
//  Rising Edge Detection and data alignment pipelines
//
//***********************************************************************
always @(posedge clk or negedge rstn)
begin
	if( ~rstn ) begin
		sample_d1 <= 0;	
		sample_d2 <= 0;
        raw_data_d1 <= 0;
		result_valid <= 0;
	end else begin
		sample_d1 <= sample;                // capture 'sample' input
		sample_d2 <= sample_d1;             // delay for edge detection
		raw_data_d1 <= raw_data_in; 	    // pipeline 
		result_valid <= latch_result;		// pipeline for alignment with result
	end
end

assign		accumulate = sample_d1 && !sample_d2;	    // 'sample' rising_edge detect
assign		latch_result = accumulate && (count == 0);	// latch accum. per decimation count

//***********************************************************************
//
//  Accumulator Depth counter
//
//***********************************************************************
always @(posedge clk or negedge rstn)
begin
	if( ~rstn ) begin
		count <= 0;	  
	end else begin
	    if (accumulate)	count <= count + 1;         // incr. count per each sample
	end
end


//***********************************************************************
//
//  Accumulator
//
//***********************************************************************
always @(posedge clk or negedge rstn)
begin
	if( ~rstn ) begin
		accum <= 0;	
	end else begin
        if (accumulate)
            if(count == 0)                      // reset accumulator
    		    accum <= raw_data_d1;           // prime with first value
            else
                accum <= accum + raw_data_d1;   // accumulate
	end	
end
	
//***********************************************************************
//
//  Latch Result
//
//  ave = (summation of 'n' samples)/'n'  is right shift when 'n' is power of two
//
//***********************************************************************
always @(posedge clk or negedge rstn)
begin
	if( ~rstn ) begin
        ave_data_out <= 0;
    end else if (latch_result) begin            // at end of decimation period...
        ave_data_out <= accum >> LPF_DEPTH_BITS;	  // ... save accumulator/n result
    end
end

assign data_out_valid = result_valid;       // output assignment

endmodule
