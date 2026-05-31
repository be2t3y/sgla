`timescale 1ns/10ps
`include "controller.v"
`include "accumulator.v"
`include "gelu.v"
`include "layernorm.v"
`include "softmax.v"
`include "attention.v"
`include "mlp.v"
`include "bbox_decode.v"
`include "top_sgla.v"

module tb_top_sgla;
	parameter CYCLE = 10.0;
	reg clk;
	reg reset;
	reg start;
	reg in_valid;
	reg signed [15:0] x_in;
	reg frame_start;
	reg map_valid;
	reg signed [15:0] score_in;
	reg signed [15:0] size_w_in;
	reg signed [15:0] size_h_in;
	reg signed [15:0] off_x_in;
	reg signed [15:0] off_y_in;
	reg signed [15:0] prev_x;
	reg signed [15:0] prev_y;
	reg signed [15:0] prev_w;
	reg signed [15:0] prev_h;
	reg signed [15:0] search_size_q;
	reg signed [15:0] resize_factor_q;
	wire busy;
	wire done;
	wire [3:0] active_block;
	wire [2:0] pass_idx;
	wire [1:0] phase;
	wire signed [15:0] y_out;
	wire y_valid;
	wire bbox_valid;
	wire signed [15:0] bbox_x;
	wire signed [15:0] bbox_y;
	wire signed [15:0] bbox_w;
	wire signed [15:0] bbox_h;

	top_sgla u_top(
		.clk(clk),
		.reset(reset),
		.start(start),
		.in_valid(in_valid),
		.x_in(x_in),
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
		.busy(busy),
		.done(done),
		.active_block(active_block),
		.pass_idx(pass_idx),
		.phase(phase),
		.y_out(y_out),
		.y_valid(y_valid),
		.bbox_valid(bbox_valid),
		.bbox_x(bbox_x),
		.bbox_y(bbox_y),
		.bbox_w(bbox_w),
		.bbox_h(bbox_h)
	);

	always #(CYCLE/2.0) clk = ~clk;

	initial begin
		clk = 1'b0;
		reset = 1'b1;
		start = 1'b0;
		in_valid = 1'b0;
		x_in = 16'sh0000;
		frame_start = 1'b0;
		map_valid = 1'b0;
		score_in = 16'sh0000;
		size_w_in = 16'sh0000;
		size_h_in = 16'sh0000;
		off_x_in = 16'sh0000;
		off_y_in = 16'sh0000;
		prev_x = 16'sh1000;
		prev_y = 16'sh0C00;
		prev_w = 16'sh0800;
		prev_h = 16'sh0600;
		search_size_q = 16'sh4000;
		resize_factor_q = 16'sh0100;
		#(2*CYCLE);
		reset = 1'b0;
		#(1*CYCLE);
		start = 1'b1;
		#(1*CYCLE);
		start = 1'b0;
		in_valid = 1'b1;
		x_in = 16'sh0080;
		#(1*CYCLE);
		x_in = 16'sh0100;
		#(1*CYCLE);
		x_in = -16'sh0040;
		#(1*CYCLE);
		in_valid = 1'b0;
		#(2*CYCLE);

		frame_start = 1'b1;
		#(1*CYCLE);
		frame_start = 1'b0;

		map_valid = 1'b1;
		score_in = 16'sh0010; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh0011; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh0012; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh0013; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh0014; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh0015; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh0100; size_w_in = 16'sh0280; size_h_in = 16'sh0200; off_x_in = 16'sh0040; off_y_in = 16'sh0030; #(1*CYCLE);
		score_in = 16'sh0017; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh0018; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh0019; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh001A; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh001B; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh001C; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh001D; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh001E; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		score_in = 16'sh001F; size_w_in = 16'sh0200; size_h_in = 16'sh0180; off_x_in = 16'sh0010; off_y_in = 16'sh0010; #(1*CYCLE);
		map_valid = 1'b0;
		#(120*CYCLE);
		$finish;
	end

	always @(posedge clk)
	begin
		if(y_valid)
			$display("t=%0t pass=%0d phase=%0d blk=%0d y=0x%h", $time, pass_idx, phase, active_block, y_out);
	end

	always @(posedge clk)
	begin
		if(done)
			$display("SGLA done at t=%0t", $time);
	end

	always @(posedge clk)
	begin
		if(bbox_valid)
			$display("bbox xywh = (%0d, %0d, %0d, %0d)", bbox_x, bbox_y, bbox_w, bbox_h);
	end

endmodule
