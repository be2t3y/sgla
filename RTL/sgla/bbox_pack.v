`timescale 1ns/10ps

module bbox_pack(
	clk,
	reset,
	in_valid,
	in_data,
	bbox_valid,
	bbox_x,
	bbox_y,
	bbox_w,
	bbox_h
);
	parameter integer W = 16;

	input wire clk;
	input wire reset;
	input wire in_valid;
	input wire signed [W-1:0] in_data;
	output reg bbox_valid;
	output reg signed [W-1:0] bbox_x;
	output reg signed [W-1:0] bbox_y;
	output reg signed [W-1:0] bbox_w;
	output reg signed [W-1:0] bbox_h;

	reg [1:0] idx;

	wire cap_x;
	wire cap_y;
	wire cap_w;
	wire cap_h;

	assign cap_x = in_valid && (idx == 2'd0);
	assign cap_y = in_valid && (idx == 2'd1);
	assign cap_w = in_valid && (idx == 2'd2);
	assign cap_h = in_valid && (idx == 2'd3);

	always @(posedge clk)
	begin
		if(reset)
			idx <= 2'd0;
		else if(in_valid && idx == 2'd3)
			idx <= 2'd0;
		else if(in_valid)
			idx <= idx + 1'b1;
	end

	always @(posedge clk)
	begin
		if(reset)
			bbox_x <= {W{1'b0}};
		else if(cap_x)
			bbox_x <= in_data;
	end

	always @(posedge clk)
	begin
		if(reset)
			bbox_y <= {W{1'b0}};
		else if(cap_y)
			bbox_y <= in_data;
	end

	always @(posedge clk)
	begin
		if(reset)
			bbox_w <= {W{1'b0}};
		else if(cap_w)
			bbox_w <= in_data;
	end

	always @(posedge clk)
	begin
		if(reset)
			bbox_h <= {W{1'b0}};
		else if(cap_h)
			bbox_h <= in_data;
	end

	always @(posedge clk)
	begin
		if(reset)
			bbox_valid <= 1'b0;
		else if(cap_h)
			bbox_valid <= 1'b1;
		else
			bbox_valid <= 1'b0;
	end

endmodule

