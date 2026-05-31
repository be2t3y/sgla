`timescale 1ns/10ps

module sgla_map_bank(
	clk,
	wr_en,
	wr_addr,
	wr_data,
	rd_addr,
	rd_data
);
	parameter integer W = 16;
	parameter integer FEAT_LOG2 = 2;
	parameter integer N_ELEM = (1 << (2*FEAT_LOG2));
	parameter integer AW = (2*FEAT_LOG2);

	input wire clk;
	input wire wr_en;
	input wire [AW-1:0] wr_addr;
	input wire signed [W-1:0] wr_data;
	input wire [AW-1:0] rd_addr;
	output wire signed [W-1:0] rd_data;

	reg signed [W-1:0] mem [0:N_ELEM-1];

	assign rd_data = mem[rd_addr];

	always @(posedge clk)
	begin
		if(wr_en)
			mem[wr_addr] <= wr_data;
	end

endmodule

