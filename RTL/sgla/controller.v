`timescale 1ns/10ps

module controller(
	clk,
	reset,
	start,
	busy,
	done,
	active_block,
	pass_idx,
	phase
);
	parameter integer N_MUST = 6;
	parameter integer SELECTED_LAYER = 6;

	input wire clk;
	input wire reset;
	input wire start;
	output wire busy;
	output wire done;
	output wire [3:0] active_block;
	output wire [2:0] pass_idx;
	output wire [1:0] phase;

	localparam S_IDLE = 1'b0;
	localparam S_RUN  = 1'b1;
	localparam PH_LN1  = 2'd0;
	localparam PH_ATTN = 2'd1;
	localparam PH_LN2  = 2'd2;
	localparam PH_MLP  = 2'd3;

	reg run_st;
	reg [2:0] pass_r;
	reg [1:0] phase_r;
	reg done_r;

	assign busy = (run_st == S_RUN);
	assign done = done_r;
	assign pass_idx = pass_r;
	assign phase = phase_r;
	assign active_block = (pass_r < N_MUST) ? {1'b0, pass_r} : SELECTED_LAYER[3:0];

	always @(posedge clk)
	begin
		if(reset)
			run_st <= S_IDLE;
		else if(run_st == S_IDLE && start)
			run_st <= S_RUN;
		else if(run_st == S_RUN && phase_r == PH_MLP && pass_r == N_MUST)
			run_st <= S_IDLE;
	end

	always @(posedge clk)
	begin
		if(reset)
			pass_r <= 3'd0;
		else if(run_st == S_IDLE && start)
			pass_r <= 3'd0;
		else if(run_st == S_RUN && phase_r == PH_MLP && pass_r < N_MUST)
			pass_r <= pass_r + 1'b1;
		else if(run_st == S_RUN && phase_r == PH_MLP && pass_r == N_MUST)
			pass_r <= 3'd0;
	end

	always @(posedge clk)
	begin
		if(reset)
			phase_r <= PH_LN1;
		else if(run_st == S_IDLE && start)
			phase_r <= PH_LN1;
		else if(run_st == S_RUN && phase_r != PH_MLP)
			phase_r <= phase_r + 1'b1;
		else if(run_st == S_RUN && phase_r == PH_MLP)
			phase_r <= PH_LN1;
	end

	always @(posedge clk)
	begin
		if(reset)
			done_r <= 1'b0;
		else if(run_st == S_RUN && phase_r == PH_MLP && pass_r == N_MUST)
			done_r <= 1'b1;
		else
			done_r <= 1'b0;
	end

endmodule
