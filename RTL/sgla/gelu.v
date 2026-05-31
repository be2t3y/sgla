`timescale 1ns/10ps

module gelu(
	clk,
	reset,
	in_valid,
	x_in,
	out_valid,
	y_out
);
	parameter integer W = 16;
	parameter integer FRAC = 8;

	input wire clk;
	input wire reset;
	input wire in_valid;
	input wire signed [W-1:0] x_in;
	output reg out_valid;
	output reg signed [W-1:0] y_out;

	wire signed [W-1:0] half_x;
	wire signed [W-1:0] x_div4;
	assign half_x = x_in >>> 1;
	assign x_div4 = x_in >>> 2;

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
		else if(in_valid && x_in[W-1])
			y_out <= x_div4;
		else if(in_valid)
			y_out <= half_x + x_div4;
	end

endmodule
