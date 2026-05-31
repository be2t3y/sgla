`timescale 1ns/10ps
`include "conv.v"

module TEST;

parameter CYCLE = 10.0;

reg clk;
reg reset;
reg in_valid;
reg [7:0] img_in; // pass to CONV
reg [7:0] IN_NUM [0:12287]; // image store

reg [13:0] IN_CNT;
wire signed[10:0]exit1, exit2, exit3;
conv conv(.clk(clk), .reset(reset), .in_valid(in_valid), .img_in(img_in),
.exit1(exit1), .exit2(exit2), .exit3(exit3));

always #(CYCLE/2.0) clk = ~clk;

initial begin
	$toggle_count("TEST.conv");
	//$fsdbDumpfile("conv.fsdb");
	//$sdf_annotate("partial_sym.sdf", TEST.conv);
	$fsdbDumpvars;
	$fsdbDumpMDA;
	$readmemb("./input_data/input_0.txt", IN_NUM);
	clk = 0; reset = 1;
	#(CYCLE) reset = 1'b1;
    #(CYCLE) reset = 1'b0;
	#(232370*CYCLE);	//exit1
	//#(CYCLE) reset = 1'b1;
	#(84480*CYCLE);
	//#(CYCLE) reset = 1'b0;
	//#(CYCLE) reset = 1'b1;
    $display("Exit1: %b", exit1);
	$display("Exit2: %b", exit2);
	$display("Exit3: %b", exit3);
	$toggle_count_report_flat("conv_rtl_exit1.tcf", "TEST.conv");
	#(10*CYCLE) $finish;
end

always @ (negedge clk)
begin
	if(reset)
		in_valid <= 0;
	else if(IN_CNT == 12287)
		in_valid <= 0;
	else if(IN_CNT < 12288)
		in_valid <= 1;
	else
		in_valid <= 0;
end

always @ (negedge clk)
begin
	if(reset)
		IN_CNT <= 0;
	else if(IN_CNT == 12289)
		IN_CNT <= IN_CNT;
	else if(in_valid)
		IN_CNT <= IN_CNT+1;
	else
		IN_CNT <= IN_CNT;
end

always @ (negedge clk)
begin
	if(reset)
		img_in <= 8'b0;
	else if(in_valid)
		img_in <= IN_NUM[IN_CNT];
	else
		img_in <= 8'd0;
end



endmodule
