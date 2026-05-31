`timescale 1ns/10ps

module bbox_decode(
	clk,
	reset,
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
	bbox_valid,
	bbox_x,
	bbox_y,
	bbox_w,
	bbox_h
);
	parameter integer W = 16;
	parameter integer FRAC = 8;
	parameter integer FEAT_LOG2 = 2;
	parameter integer FEAT_SZ = (1 << FEAT_LOG2);
	parameter integer N_ELEM = (1 << (2*FEAT_LOG2));

	input wire clk;
	input wire reset;
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
	output reg bbox_valid;
	output reg signed [W-1:0] bbox_x;
	output reg signed [W-1:0] bbox_y;
	output reg signed [W-1:0] bbox_w;
	output reg signed [W-1:0] bbox_h;

	reg [15:0] idx_r;
	reg [15:0] best_idx_r;
	reg first_r;
	reg signed [W-1:0] best_score_r;
	reg signed [W-1:0] best_sw_r;
	reg signed [W-1:0] best_sh_r;
	reg signed [W-1:0] best_ox_r;
	reg signed [W-1:0] best_oy_r;
	reg emit_r;

	wire update_best;
	assign update_best = map_valid && (first_r || (score_in > best_score_r));

	wire [15:0] idx_x_w;
	wire [15:0] idx_y_w;
	assign idx_x_w = best_idx_r[FEAT_LOG2-1:0];
	assign idx_y_w = best_idx_r[(2*FEAT_LOG2)-1:FEAT_LOG2];

	wire signed [W-1:0] idx_x_q_w;
	wire signed [W-1:0] idx_y_q_w;
	assign idx_x_q_w = $signed({{(W-16){1'b0}}, idx_x_w}) <<< FRAC;
	assign idx_y_q_w = $signed({{(W-16){1'b0}}, idx_y_w}) <<< FRAC;

	// 為避免合成器導入大型可變除法器，外部直接餵 precomputed search_size/resize_factor（Q format）
	wire signed [W-1:0] sdr_q_w;
	assign sdr_q_w = search_size_q;

	wire signed [W-1:0] half_side_w;
	assign half_side_w = sdr_q_w >>> 1;

	wire signed [W-1:0] cx_norm_w;
	wire signed [W-1:0] cy_norm_w;
	assign cx_norm_w = (idx_x_q_w + best_ox_r) >>> FEAT_LOG2;
	assign cy_norm_w = (idx_y_q_w + best_oy_r) >>> FEAT_LOG2;

	wire signed [2*W-1:0] cx_mul_w;
	wire signed [2*W-1:0] cy_mul_w;
	wire signed [2*W-1:0] bw_mul_w;
	wire signed [2*W-1:0] bh_mul_w;
	assign cx_mul_w = cx_norm_w * sdr_q_w;
	assign cy_mul_w = cy_norm_w * sdr_q_w;
	assign bw_mul_w = best_sw_r * sdr_q_w;
	assign bh_mul_w = best_sh_r * sdr_q_w;

	wire signed [W-1:0] pred_cx_w;
	wire signed [W-1:0] pred_cy_w;
	wire signed [W-1:0] pred_w_w;
	wire signed [W-1:0] pred_h_w;
	assign pred_cx_w = cx_mul_w >>> FRAC;
	assign pred_cy_w = cy_mul_w >>> FRAC;
	assign pred_w_w = bw_mul_w >>> FRAC;
	assign pred_h_w = bh_mul_w >>> FRAC;

	wire signed [W-1:0] cx_prev_w;
	wire signed [W-1:0] cy_prev_w;
	assign cx_prev_w = prev_x + (prev_w >>> 1);
	assign cy_prev_w = prev_y + (prev_h >>> 1);

	wire signed [W-1:0] cx_real_w;
	wire signed [W-1:0] cy_real_w;
	assign cx_real_w = pred_cx_w + (cx_prev_w - half_side_w);
	assign cy_real_w = pred_cy_w + (cy_prev_w - half_side_w);

	wire signed [W-1:0] out_x_w;
	wire signed [W-1:0] out_y_w;
	assign out_x_w = cx_real_w - (pred_w_w >>> 1);
	assign out_y_w = cy_real_w - (pred_h_w >>> 1);

	always @(posedge clk)
	begin
		if(reset)
			idx_r <= 16'd0;
		else if(frame_start)
			idx_r <= 16'd0;
		else if(map_valid && idx_r == N_ELEM-1)
			idx_r <= 16'd0;
		else if(map_valid)
			idx_r <= idx_r + 1'b1;
	end

	always @(posedge clk)
	begin
		if(reset)
			first_r <= 1'b1;
		else if(frame_start)
			first_r <= 1'b1;
		else if(map_valid)
			first_r <= 1'b0;
	end

	always @(posedge clk)
	begin
		if(reset)
			best_score_r <= {W{1'b1}};
		else if(frame_start)
			best_score_r <= {W{1'b1}};
		else if(update_best)
			best_score_r <= score_in;
	end

	always @(posedge clk)
	begin
		if(reset)
			best_idx_r <= 16'd0;
		else if(frame_start)
			best_idx_r <= 16'd0;
		else if(update_best)
			best_idx_r <= idx_r;
	end

	always @(posedge clk)
	begin
		if(reset)
			best_sw_r <= {W{1'b0}};
		else if(frame_start)
			best_sw_r <= {W{1'b0}};
		else if(update_best)
			best_sw_r <= size_w_in;
	end

	always @(posedge clk)
	begin
		if(reset)
			best_sh_r <= {W{1'b0}};
		else if(frame_start)
			best_sh_r <= {W{1'b0}};
		else if(update_best)
			best_sh_r <= size_h_in;
	end

	always @(posedge clk)
	begin
		if(reset)
			best_ox_r <= {W{1'b0}};
		else if(frame_start)
			best_ox_r <= {W{1'b0}};
		else if(update_best)
			best_ox_r <= off_x_in;
	end

	always @(posedge clk)
	begin
		if(reset)
			best_oy_r <= {W{1'b0}};
		else if(frame_start)
			best_oy_r <= {W{1'b0}};
		else if(update_best)
			best_oy_r <= off_y_in;
	end

	always @(posedge clk)
	begin
		if(reset)
			emit_r <= 1'b0;
		else if(map_valid && idx_r == N_ELEM-1)
			emit_r <= 1'b1;
		else
			emit_r <= 1'b0;
	end

	always @(posedge clk)
	begin
		if(reset)
			bbox_valid <= 1'b0;
		else
			bbox_valid <= emit_r;
	end

	always @(posedge clk)
	begin
		if(reset)
			bbox_x <= {W{1'b0}};
		else if(emit_r)
			bbox_x <= out_x_w;
	end

	always @(posedge clk)
	begin
		if(reset)
			bbox_y <= {W{1'b0}};
		else if(emit_r)
			bbox_y <= out_y_w;
	end

	always @(posedge clk)
	begin
		if(reset)
			bbox_w <= {W{1'b0}};
		else if(emit_r)
			bbox_w <= pred_w_w;
	end

	always @(posedge clk)
	begin
		if(reset)
			bbox_h <= {W{1'b0}};
		else if(emit_r)
			bbox_h <= pred_h_w;
	end

endmodule

