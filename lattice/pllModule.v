module pllModule #(parameter DIVR=4'd0,
                   parameter DIVF=7'd79,
                   parameter DIVQ=3'd4,
                   parameter FILTER_RANGE=3'b1
                   )(input clkin, output clkout, output lock);
//icepll -i 12 -o 60 gives the numbers above
`ifdef VERILATOR 
   assign clkout=clkin;
   assign lock=1;   
`else
   wire                      g_clock_int;	
	SB_PLL40_CORE #(
		        .FEEDBACK_PATH("SIMPLE"),
		        //.PLLOUT_SELECT("GENCLK"),
		        .DIVR(DIVR),
		        .DIVF(DIVF),
		        .DIVQ(DIVQ),
		        .FILTER_RANGE(FILTER_RANGE)
	                ) uut (
		               .LOCK(lock),
		               .RESETB(1'b1),
		               .BYPASS(1'b0),
		               .REFERENCECLK(clkin),
		               //.PLLOUTCORE(clkout)
                               .PLLOUTGLOBAL(g_clock_int)				

	                       );


    SB_GB sbGlobalBuffer_inst( .USER_SIGNAL_TO_GLOBAL_BUFFER(g_clock_int)
			   , .GLOBAL_BUFFER_OUTPUT(clkout) );	

`endif
   
endmodule
