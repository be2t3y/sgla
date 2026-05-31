module pm(
	clk,
	reset,
	layer,
	pgen1,
	pgen2,
	pgen3,
	pgen4,
	pgen5,
	pgen6,
	pgen7,
	pgen8,
	pgen9,
	pgen10,
	pgen11,
	pgen12
);



input clk,reset;
input [2:0]layer;
reg [2:0] mode;
output reg pgen1,pgen2,pgen3,pgen4,pgen5,pgen6,pgen7,pgen8,pgen9,pgen10,pgen11,pgen12;
// sr1 2 rf1 2 3 4 romc12 c3 c4 romexit1 exit2 exit3


always @ (posedge clk)
begin
	if(reset)
		mode <= 1'b0;
	else mode <= layer;
end

always @ (negedge clk)
begin
	if(reset)
		pgen1 <= 1'b0;
	else if(mode == 3'd0 || mode == 3'd1)
		pgen1 <= 1'b0;
	else pgen1 <= 1'b1;
end

always @ (negedge clk)
begin
	if(reset)
		pgen2 <= 1'b0;
	else if(mode == 3'd0 || mode == 3'd1 || mode == 3'd2 || mode == 3'd3)
		pgen2 <= 1'b0;
	else pgen2 <= 1'b1;
end

always @ (negedge clk)
begin
	if(reset)
		pgen3 <= 1'b0;
	else if(mode == 3'd1 || mode == 3'd2 || mode == 3'd3 || mode == 3'd4)
		pgen3 <= 1'b0;
	else pgen3 <= 1'b1;
end


always @ (negedge clk)
begin
	if(reset)
		pgen4 <= 1'b0;
	else if(mode == 3'd1 || mode == 3'd2 || mode == 3'd4)
		pgen4 <= 1'b0;
	else pgen4 <= 1'b1;
end

always @ (negedge clk)
begin
	if(reset)
		pgen5 <= 1'b0;
	else if(mode == 3'd1 || mode == 3'd2)
		pgen5 <= 1'b0;
	else pgen5 <= 1'b1;
end

always @ (negedge clk)
begin
	if(reset)
		pgen6 <= 1'b0;
	else if(mode == 3'd1 || mode == 3'd2)
		pgen6 <= 1'b0;
	else pgen6 <= 1'b1;
end

always @ (negedge clk)
begin
	if(reset)
		pgen7 <= 1'b0;
	else if(mode == 3'd0 || mode == 3'd1 || mode == 3'd2)
		pgen7 <= 1'b0;
	else pgen7 <= 1'b1;
end

always @ (negedge clk)
begin
	if(reset)
		pgen8 <= 1'b0;
	else if(mode == 3'd3)
		pgen8 <= 1'b0;
	else pgen8 <= 1'b1;
end

always @ (negedge clk)
begin
	if(reset)
		pgen9 <= 1'b0;
	else if(mode == 3'd4)
		pgen9 <= 1'b0;
	else pgen9 <= 1'b1;
end

always @ (negedge clk)
begin
	if(reset)
		pgen10 <= 1'b0;
	else if(mode == 3'd2)
		pgen10 <= 1'b0;
	else pgen10 <= 1'b1;
end


always @ (negedge clk)
begin
	if(reset)
		pgen11 <= 1'b0;
	else if(mode == 3'd3)
		pgen11 <= 1'b0;
	else pgen11 <= 1'b1;
end


always @ (negedge clk)
begin
	if(reset)
		pgen12 <= 1'b0;
	else if(mode == 3'd4)
		pgen12 <= 1'b0;
	else pgen12 <= 1'b1;
end

endmodule
