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
//  Project:     Simple Sigma Delta (SSD)
//  File:        sigmadelta_adc.v
//  Title:       SSD Top Level
//  Description: Top level of SSD Analog to Digital Convertor
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
// $Log: rd1066#source#verilog#sigmadelta_adc.v,v $
// Revision 1.1  2015-02-05 00:00:52-08  mbevinam
// Updated RD Placed in RD Folder. Previous versions are in RD_Dimensions Archive folder.
//
// Revision	Date		
// 1.0		10/12/2009	Initial Revision
//
// --------------------------------------------------------------------



//*********************************************************************
//
//	SSD Top Level Module
//
//*********************************************************************



module sigmadelta_adc (
	clk,                    
	rstn,                   
	digital_out,            
	analog_cmp,	            
	analog_out,             
	sample_rdy);            

parameter 
ADC_WIDTH = 8,              // ADC Convertor Bit Precision
ACCUM_BITS = 10,            // 2^ACCUM_BITS is decimation rate of accumulator
LPF_DEPTH_BITS = 3;         // 2^LPF_DEPTH_BITS is decimation rate of averager

//input ports
input	clk;                            // sample rate clock
input	rstn;                           // async reset, asserted low
input	analog_cmp ;                    // input from LVDS buffer (comparitor)

//output ports
output	analog_out;                     // feedback to comparitor input RC circuit
output  sample_rdy;                     // digital_out is ready
output [ADC_WIDTH-1:0]	digital_out;    // digital output word of ADC


//**********************************************************************
//
//	Internal Wire & Reg Signals
//
//**********************************************************************
reg                         delta;          // captured comparitor output
reg [ACCUM_BITS-1:0]	    sigma;          // running accumulator value
reg [ADC_WIDTH-1:0]	        accum;          // latched accumulator value
reg [ACCUM_BITS-1:0]	    counter;        // decimation counter for accumulator
reg							rollover;       // decimation counter terminal count
reg							accum_rdy;      // latched accumulator value 'ready' 




//***********************************************************************
//
//  SSD 'Analog' Input - PWM
//
//	External Comparator Generates High/Low Value
//
//***********************************************************************

always @ (posedge clk)
begin
    delta <= analog_cmp;        // capture comparitor output
end

assign analog_out = delta;      // feedback to comparitor LPF

//***********************************************************************
//
//  Accumulator Stage
//
//	Adds PWM positive pulses over accumulator period
//
//***********************************************************************

always @ (posedge clk or negedge rstn)
begin
	if( ~rstn ) 
    begin
		sigma       <= 0;
		accum       <= 0;
		accum_rdy   <= 0;
    end else begin
        if (rollover) begin
            // latch top ADC_WIDTH bits of sigma accumulator (drop LSBs)
            accum <= sigma[ACCUM_BITS-1:ACCUM_BITS-ADC_WIDTH];
            sigma <= delta;         // reset accumulator, prime with current delta value
        end else begin
            if (&sigma != 1'b1)         // if not saturated
                sigma <= sigma + delta; // accumulate 
        end
        accum_rdy <= rollover;     // latch 'rdy' (to align with accum)
    end
end



//***********************************************************************
//
//  Box filter Average
//
//	Acts as simple decimating Low-Pass Filter
//
//***********************************************************************

box_ave #(
    .ADC_WIDTH(ADC_WIDTH),
    .LPF_DEPTH_BITS(LPF_DEPTH_BITS))
box_ave (
    .clk(clk),
    .rstn(rstn),
    .sample(accum_rdy),
    .raw_data_in(accum),
    .ave_data_out(digital_out),
    .data_out_valid(sample_rdy)
);

//************************************************************************
//
// Sample Control - Accumulator Timing
//	
//************************************************************************

always @(posedge clk or negedge rstn)
begin
	if( ~rstn ) begin
		counter <= 0;
		rollover <= 0;
		end
	else begin
		counter <= counter + 1;       // running count
		rollover <= &counter;         // assert 'rollover' when counter is all 1's
		end
end

endmodule
