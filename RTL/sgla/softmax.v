`timescale 1ns/10ps

module softmax(
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

	wire signed [W-1:0] one_q;
	assign one_q = (1 << FRAC);

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
			y_out <= {W{1'b0}};
		else if(in_valid && x_in > one_q)
			y_out <= one_q;
		else if(in_valid)
			y_out <= x_in;
	end

endmodule
