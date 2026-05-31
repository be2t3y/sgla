`timescale 1ns/10ps

module accumulator(
	clk,
	reset,
	clr,
	en,
	mul_a,
	mul_b,
	acc
);
	parameter integer W = 16;
	parameter integer ACC_W = 40;

	input wire clk;
	input wire reset;
	input wire clr;
	input wire en;
	input wire signed [W-1:0] mul_a;
	input wire signed [W-1:0] mul_b;
	output reg signed [ACC_W-1:0] acc;

	wire signed [2*W-1:0] prod;
	assign prod = mul_a * mul_b;

	always @(posedge clk)
	begin
		if(reset)
			acc <= {ACC_W{1'b0}};
		else if(en && clr)
			acc <= {{(ACC_W-2*W){prod[2*W-1]}}, prod};
		else if(en)
			acc <= acc + {{(ACC_W-2*W){prod[2*W-1]}}, prod};
	end

endmodule
