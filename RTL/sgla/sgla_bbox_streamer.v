`timescale 1ns/10ps

module sgla_bbox_streamer(
	clk,
	reset,
	start_decode,
	rd_addr,
	frame_start,
	map_valid,
	stream_done
);
	parameter integer FEAT_LOG2 = 2;
	parameter integer N_ELEM = (1 << (2*FEAT_LOG2));
	parameter integer AW = (2*FEAT_LOG2);

	input wire clk;
	input wire reset;
	input wire start_decode;
	output wire [AW-1:0] rd_addr;
	output reg frame_start;
	output reg map_valid;
	output reg stream_done;

	localparam S_IDLE = 1'b0;
	localparam S_RUN  = 1'b1;

	reg st;
	reg [AW-1:0] addr_r;

	assign rd_addr = addr_r;

	always @(posedge clk)
	begin
		if(reset)
			st <= S_IDLE;
		else if(st == S_IDLE && start_decode)
			st <= S_RUN;
		else if(st == S_RUN && addr_r == N_ELEM-1)
			st <= S_IDLE;
	end

	always @(posedge clk)
	begin
		if(reset)
			addr_r <= {AW{1'b0}};
		else if(st == S_IDLE && start_decode)
			addr_r <= {AW{1'b0}};
		else if(st == S_RUN && addr_r == N_ELEM-1)
			addr_r <= {AW{1'b0}};
		else if(st == S_RUN)
			addr_r <= addr_r + 1'b1;
	end

	always @(posedge clk)
	begin
		if(reset)
			frame_start <= 1'b0;
		else if(st == S_IDLE && start_decode)
			frame_start <= 1'b1;
		else
			frame_start <= 1'b0;
	end

	always @(posedge clk)
	begin
		if(reset)
			map_valid <= 1'b0;
		else if(st == S_IDLE && start_decode)
			map_valid <= 1'b1;
		else if(st == S_RUN && addr_r == N_ELEM-1)
			map_valid <= 1'b1;
		else if(st == S_RUN)
			map_valid <= 1'b1;
		else
			map_valid <= 1'b0;
	end

	always @(posedge clk)
	begin
		if(reset)
			stream_done <= 1'b0;
		else if(st == S_RUN && addr_r == N_ELEM-1)
			stream_done <= 1'b1;
		else
			stream_done <= 1'b0;
	end

endmodule

