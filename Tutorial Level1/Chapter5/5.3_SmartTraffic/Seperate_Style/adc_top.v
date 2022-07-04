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
//
//  Project:     ADC_lvds
//  File:        adc_top.v
//  Title:       ADC Top Level
//  Description: Top level of Analog to Digital Convertor
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
// $Log: RD#rd1066_simple_sigma_delta_adc#rd1066#source#verilog#adc_top.v,v $
// Revision 1.1  2015-02-05 00:00:56-08  mbevinam
// Updated RD Placed in RD Folder. Previous versions are in RD_Dimensions Archive folder.
//
// Revision	Date		
// 1.0		10/12/2009	Initial Revision
//
// --------------------------------------------------------------------



//*********************************************************************
//
//	ADC Top Level Module
//
//*********************************************************************



module ADC_top (
	clk_in,
	rstn,
	digital_out,
	analog_cmp,	
	analog_out,
	sample_rdy);

parameter 
ADC_WIDTH = 8,              // ADC Convertor Bit Precision
ACCUM_BITS = 10,            // 2^ACCUM_BITS is decimation rate of accumulator
LPF_DEPTH_BITS = 3,         // 2^LPF_DEPTH_BITS is decimation rate of averager
INPUT_TOPOLOGY = 0;         // 0: DIRECT: Analog input directly connected to + input of comparitor
                            // 1: NETWORK:Analog input connected through R divider to - input of comp.

//input ports
input	clk_in;				// 62.5Mhz on Control Demo board
input	rstn;	 
input	analog_cmp;			// from LVDS buffer or external comparitor

//output ports
output	analog_out;         // feedback to RC network
output  sample_rdy;
output [7:0] digital_out;   // connected to LED field on control demo bd.
 

//**********************************************************************
//
//	Internal Wire & Reg Signals
//
//**********************************************************************
wire							clk;
wire							analog_out_i;
wire							sample_rdy_i;
wire [ADC_WIDTH-1:0]			digital_out_i;
wire [ADC_WIDTH-1:0]			digital_out_abs;



assign clk = clk_in;


//***********************************************************************
//
//  SSD ADC using onboard LVDS buffer or external comparitor
//
//***********************************************************************
sigmadelta_adc #(
	.ADC_WIDTH(ADC_WIDTH),
	.ACCUM_BITS(ACCUM_BITS),
	.LPF_DEPTH_BITS(LPF_DEPTH_BITS)
	)
SSD_ADC(
	.clk(clk),
	.rstn(rstn),
	.analog_cmp(analog_cmp),
	.digital_out(digital_out_i),
	.analog_out(analog_out_i),
	.sample_rdy(sample_rdy_i)
	);

assign digital_out_abs = INPUT_TOPOLOGY ? ~digital_out_i : digital_out_i;  

//***********************************************************************
//
//  output assignments
//
//***********************************************************************


assign digital_out   = ~digital_out_abs;	 // invert bits for LED display 
assign analog_out    =  analog_out_i;
assign sample_rdy    =  sample_rdy_i;

endmodule
