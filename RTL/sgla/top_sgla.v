`timescale 1ns/10ps

module top_sgla(
	clk,
	reset,
	start,
	in_valid,
	x_in,
	frame_start,
	map_valid,
	score_in,
	size_w_in,
	size_h_in,
	off_x_in,
	off_y_in,
	prev_x,
	prev_y,
	prev_w,
	prev_h,
	search_size_q,
	resize_factor_q,
	busy,
	done,
	active_block,
	pass_idx,
	phase,
	y_out,
	y_valid,
	bbox_valid,
	bbox_x,
	bbox_y,
	bbox_w,
	bbox_h
);
	parameter integer W = 16;
	parameter integer FRAC = 8;
	parameter integer FEAT_LOG2 = 2;
	parameter integer N_MUST = 6;
	parameter integer SELECTED_LAYER = 6;

	input wire clk;
	input wire reset;
	input wire start;
	input wire in_valid;
	input wire signed [W-1:0] x_in;
	input wire frame_start;
	input wire map_valid;
	input wire signed [W-1:0] score_in;
	input wire signed [W-1:0] size_w_in;
	input wire signed [W-1:0] size_h_in;
	input wire signed [W-1:0] off_x_in;
	input wire signed [W-1:0] off_y_in;
	input wire signed [W-1:0] prev_x;
	input wire signed [W-1:0] prev_y;
	input wire signed [W-1:0] prev_w;
	input wire signed [W-1:0] prev_h;
	input wire signed [W-1:0] search_size_q;
	input wire signed [W-1:0] resize_factor_q;
	output wire busy;
	output wire done;
	output wire [3:0] active_block;
	output wire [2:0] pass_idx;
	output wire [1:0] phase;
	output wire signed [W-1:0] y_out;
	output wire y_valid;
	output wire bbox_valid;
	output wire signed [W-1:0] bbox_x;
	output wire signed [W-1:0] bbox_y;
	output wire signed [W-1:0] bbox_w;
	output wire signed [W-1:0] bbox_h;

	wire signed [W-1:0] ln1_o;
	wire signed [W-1:0] attn_o;
	wire signed [W-1:0] sm_o;
	wire signed [W-1:0] ln2_o;
	wire signed [W-1:0] mlp_o;
	wire ln1_v;
	wire attn_v;
	wire sm_v;
	wire ln2_v;
	wire mlp_v;

	controller #(
		.N_MUST(N_MUST),
		.SELECTED_LAYER(SELECTED_LAYER)
	) u_ctrl(
		.clk(clk),
		.reset(reset),
		.start(start),
		.busy(busy),
		.done(done),
		.active_block(active_block),
		.pass_idx(pass_idx),
		.phase(phase)
	);

	layernorm #(.W(W), .FRAC(FRAC)) u_ln1(
		.clk(clk), .reset(reset), .in_valid(in_valid), .x_in(x_in),
		.gamma(16'sh0100), .beta(16'sh0000), .out_valid(ln1_v), .y_out(ln1_o)
	);

	attention #(.W(W), .FRAC(FRAC)) u_attn(
		.clk(clk), .reset(reset), .in_valid(ln1_v), .x_in(ln1_o),
		.attn_w(16'sh0040), .out_valid(attn_v), .y_out(attn_o)
	);

	softmax #(.W(W), .FRAC(FRAC)) u_sm(
		.clk(clk), .reset(reset), .in_valid(attn_v), .x_in(attn_o),
		.out_valid(sm_v), .y_out(sm_o)
	);

	layernorm #(.W(W), .FRAC(FRAC)) u_ln2(
		.clk(clk), .reset(reset), .in_valid(sm_v), .x_in(sm_o),
		.gamma(16'sh0100), .beta(16'sh0000), .out_valid(ln2_v), .y_out(ln2_o)
	);

	mlp #(.W(W), .FRAC(FRAC)) u_mlp(
		.clk(clk), .reset(reset), .in_valid(ln2_v), .x_in(ln2_o),
		.w1(16'sh0120), .b1(16'sh0000), .w2(16'sh00E0), .b2(16'sh0000),
		.out_valid(mlp_v), .y_out(mlp_o)
	);

	assign y_out = mlp_o;
	assign y_valid = mlp_v;

	bbox_decode #(.W(W), .FRAC(FRAC), .FEAT_LOG2(FEAT_LOG2)) u_bbox_decode(
		.clk(clk),
		.reset(reset),
		.frame_start(frame_start),
		.map_valid(map_valid),
		.score_in(score_in),
		.size_w_in(size_w_in),
		.size_h_in(size_h_in),
		.off_x_in(off_x_in),
		.off_y_in(off_y_in),
		.prev_x(prev_x),
		.prev_y(prev_y),
		.prev_w(prev_w),
		.prev_h(prev_h),
		.search_size_q(search_size_q),
		.resize_factor_q(resize_factor_q),
		.bbox_valid(bbox_valid),
		.bbox_x(bbox_x),
		.bbox_y(bbox_y),
		.bbox_w(bbox_w),
		.bbox_h(bbox_h)
	);

endmodule
