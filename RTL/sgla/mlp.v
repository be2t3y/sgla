`timescale 1ns/10ps

module mlp(
	clk,
	reset,
	in_valid,
	x_in,
	w1,
	b1,
	w2,
	b2,
	out_valid,
	y_out
);
	parameter integer W = 16;
	parameter integer FRAC = 8;

	input wire clk;
	input wire reset;
	input wire in_valid;
	input wire signed [W-1:0] x_in;
	input wire signed [W-1:0] w1;
	input wire signed [W-1:0] b1;
	input wire signed [W-1:0] w2;
	input wire signed [W-1:0] b2;
	output wire out_valid;
	output wire signed [W-1:0] y_out;

	reg in_valid_d;
	reg signed [W-1:0] pre1;
	reg signed [W-1:0] pre2;
	wire gelu_valid;
	wire signed [W-1:0] gelu_y;
	wire signed [2*W-1:0] mul1_full;
	wire signed [2*W-1:0] mul2_full;
	wire signed [W-1:0] mul1_q;
	wire signed [W-1:0] mul2_q;

	assign mul1_full = x_in * w1;
	assign mul1_q = mul1_full[W+FRAC-1:FRAC];
	assign mul2_full = gelu_y * w2;
	assign mul2_q = mul2_full[W+FRAC-1:FRAC];
	assign out_valid = gelu_valid;
	assign y_out = pre2;

	gelu #(.W(W), .FRAC(FRAC)) u_gelu(
		.clk(clk),
		.reset(reset),
		.in_valid(in_valid_d),
		.x_in(pre1),
		.out_valid(gelu_valid),
		.y_out(gelu_y)
	);

	always @(posedge clk)
	begin
		if(reset)
			in_valid_d <= 1'b0;
		else
			in_valid_d <= in_valid;
	end

	always @(posedge clk)
	begin
		if(reset)
			pre1 <= {W{1'b0}};
		else if(in_valid)
			pre1 <= mul1_q + b1;
	end

	always @(posedge clk)
	begin
		if(reset)
			pre2 <= {W{1'b0}};
		else if(gelu_valid)
			pre2 <= mul2_q + b2;
	end

endmodule
