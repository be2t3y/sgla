`timescale 1ns/10ps

module attention(
	clk,
	reset,
	in_valid,
	x_in,
	attn_w,
	out_valid,
	y_out
);
	parameter integer W = 16;
	parameter integer FRAC = 8;

	input wire clk;
	input wire reset;
	input wire in_valid;
	input wire signed [W-1:0] x_in;
	input wire signed [W-1:0] attn_w;
	output reg out_valid;
	output reg signed [W-1:0] y_out;

	wire signed [2*W-1:0] mult_full;
	wire signed [W-1:0] mult_q;
	assign mult_full = x_in * attn_w;
	assign mult_q = mult_full[W+FRAC-1:FRAC];

	always @(posedge clk)
	begin
		if(reset)
			out_valid <= 1'b0;
		else
			out_valid <= in_valid;
	end

	always @(posedge clk)
	begin
		if(reset)
			y_out <= {W{1'b0}};
		else if(in_valid)
			y_out <= x_in + mult_q;
	end

endmodule
