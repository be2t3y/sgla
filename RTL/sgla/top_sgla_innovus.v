`timescale 1ns/10ps

module top_sgla_innovus(
	clk,
	reset,
	start_decode,
	map_we,
	map_sel,
	map_waddr,
	map_wdata,
	prev_x,
	prev_y,
	prev_w,
	prev_h,
	search_over_resize_q,
	bbox_valid,
	bbox_x,
	bbox_y,
	bbox_w,
	bbox_h,
	stream_done
);
	parameter integer W = 16;
	parameter integer FRAC = 8;
	parameter integer FEAT_LOG2 = 2;
	parameter integer AW = (2*FEAT_LOG2);

	input wire clk;
	input wire reset;
	input wire start_decode;
	input wire map_we;
	input wire [2:0] map_sel;
	input wire [AW-1:0] map_waddr;
	input wire signed [W-1:0] map_wdata;
	input wire signed [W-1:0] prev_x;
	input wire signed [W-1:0] prev_y;
	input wire signed [W-1:0] prev_w;
	input wire signed [W-1:0] prev_h;
	input wire signed [W-1:0] search_over_resize_q;
	output wire bbox_valid;
	output wire signed [W-1:0] bbox_x;
	output wire signed [W-1:0] bbox_y;
	output wire signed [W-1:0] bbox_w;
	output wire signed [W-1:0] bbox_h;
	output wire stream_done;

	wire [AW-1:0] rd_addr;
	wire frame_start;
	wire map_valid;
	wire signed [W-1:0] score_rd;
	wire signed [W-1:0] sw_rd;
	wire signed [W-1:0] sh_rd;
	wire signed [W-1:0] ox_rd;
	wire signed [W-1:0] oy_rd;

	wire we_score;
	wire we_sw;
	wire we_sh;
	wire we_ox;
	wire we_oy;

	assign we_score = map_we && (map_sel == 3'd0);
	assign we_sw    = map_we && (map_sel == 3'd1);
	assign we_sh    = map_we && (map_sel == 3'd2);
	assign we_ox    = map_we && (map_sel == 3'd3);
	assign we_oy    = map_we && (map_sel == 3'd4);

	sgla_bbox_streamer #(
		.FEAT_LOG2(FEAT_LOG2)
	) u_stream (
		.clk(clk),
		.reset(reset),
		.start_decode(start_decode),
		.rd_addr(rd_addr),
		.frame_start(frame_start),
		.map_valid(map_valid),
		.stream_done(stream_done)
	);

	sgla_map_bank #(
		.W(W),
		.FEAT_LOG2(FEAT_LOG2)
	) u_score_bank (
		.clk(clk),
		.wr_en(we_score),
		.wr_addr(map_waddr),
		.wr_data(map_wdata),
		.rd_addr(rd_addr),
		.rd_data(score_rd)
	);

	sgla_map_bank #(
		.W(W),
		.FEAT_LOG2(FEAT_LOG2)
	) u_sw_bank (
		.clk(clk),
		.wr_en(we_sw),
		.wr_addr(map_waddr),
		.wr_data(map_wdata),
		.rd_addr(rd_addr),
		.rd_data(sw_rd)
	);

	sgla_map_bank #(
		.W(W),
		.FEAT_LOG2(FEAT_LOG2)
	) u_sh_bank (
		.clk(clk),
		.wr_en(we_sh),
		.wr_addr(map_waddr),
		.wr_data(map_wdata),
		.rd_addr(rd_addr),
		.rd_data(sh_rd)
	);

	sgla_map_bank #(
		.W(W),
		.FEAT_LOG2(FEAT_LOG2)
	) u_ox_bank (
		.clk(clk),
		.wr_en(we_ox),
		.wr_addr(map_waddr),
		.wr_data(map_wdata),
		.rd_addr(rd_addr),
		.rd_data(ox_rd)
	);

	sgla_map_bank #(
		.W(W),
		.FEAT_LOG2(FEAT_LOG2)
	) u_oy_bank (
		.clk(clk),
		.wr_en(we_oy),
		.wr_addr(map_waddr),
		.wr_data(map_wdata),
		.rd_addr(rd_addr),
		.rd_data(oy_rd)
	);

	bbox_decode #(
		.W(W),
		.FRAC(FRAC),
		.FEAT_LOG2(FEAT_LOG2)
	) u_decode (
		.clk(clk),
		.reset(reset),
		.frame_start(frame_start),
		.map_valid(map_valid),
		.score_in(score_rd),
		.size_w_in(sw_rd),
		.size_h_in(sh_rd),
		.off_x_in(ox_rd),
		.off_y_in(oy_rd),
		.prev_x(prev_x),
		.prev_y(prev_y),
		.prev_w(prev_w),
		.prev_h(prev_h),
		.search_size_q(search_over_resize_q),
		.resize_factor_q({{(W-1){1'b0}}, 1'b1}),
		.bbox_valid(bbox_valid),
		.bbox_x(bbox_x),
		.bbox_y(bbox_y),
		.bbox_w(bbox_w),
		.bbox_h(bbox_h)
	);

endmodule

