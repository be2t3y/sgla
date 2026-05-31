`timescale 1ns/10ps

module partial_sum(
	clk,
	reset,
	layer,
	add_start,
	bn_start,
	pool_start,
	in_channel,
	address,	
	write_in,
	bn_result,
	pool1,
	pool2,
	pool3,
	pool4	
);

input clk,reset;
input [2:0] layer;
input add_start, bn_start, pool_start;
input [3:0] in_channel;
input [11:0] address;
input signed[18:0] write_in;
output reg [18:0]bn_result;
output reg signed[18:0] pool1,pool2,pool3,pool4;

reg signed[18:0]sum1_img[0:1023];
reg signed[18:0]sum2_img[0:1023];
reg signed[18:0]sum3_img[0:1023];
reg signed[18:0]sum4_img[0:1023];

reg ena1;
reg ena2;
reg ena3;
reg ena4;

integer i;

always @ (*)
begin
	if(reset)
		bn_result = 19'b0;
	else if(layer == 3'd1 && address < 1024 && bn_start)
		bn_result = sum1_img[address];
	else if(layer == 3'd1 && address > 1023 && address < 2048 && bn_start)
		bn_result = sum2_img[address - 1024];

	else if(layer == 3'd1 && address > 2047 && address < 3072 && bn_start)
		bn_result = sum3_img[address - 2048];

	else if(layer == 3'd1 && address > 3071 && address < 4096 && bn_start)
		bn_result = sum4_img[address - 3072];

	else if(bn_start)
		bn_result = sum1_img[address];		
	else bn_result = 19'b0;
end

always @ (posedge clk)
begin
	if(reset)
		ena1 <= 1'b1;
end

always @ (posedge clk)
begin
	if(reset)
		ena2 <= 1'b1;
	else if(layer > 3'd1)
		ena2 <= 1'b0;
end

always @ (posedge clk)
begin
	if(reset)
		ena3 <= 1'b1;
	else if(layer > 3'd1)
		ena3 <= 1'b0;
end

always @ (posedge clk)
begin
	if(reset)
		ena4 <= 1'b1;
	else if(layer > 3'd1)
		ena4 <= 1'b0;
end
always @ (posedge clk)
begin
	if(reset)
	begin
		for(i=0; i<1024; i=i+1)
		sum1_img[i] <= 19'b0;	
	end
	else if(ena1)
	begin
		if(address < 1024 && !pool_start)
		begin
			if(bn_start)
				sum1_img[address] <= write_in;
			else if(add_start && !bn_start && in_channel == 4'd0)
				sum1_img[address] <= write_in;
			else if(add_start && !bn_start && in_channel != 4'd0)
				sum1_img[address] <= sum1_img[address] + write_in;
		end
	end 
end

always @ (posedge clk)
begin
	if(reset)
	begin
		for(i=0; i<1024; i=i+1)
		sum2_img[i] <= 19'b0;	
	end
	else if(ena2)
	begin
		if(address > 1023 && address < 2048 && !pool_start)
		begin
			if(layer == 3'd1 && bn_start)
				sum2_img[address - 1024]<= write_in;
			else if(layer == 3'd1 && add_start && !bn_start && in_channel == 4'd0)
				sum2_img[address - 1024] <= write_in;
			else if(layer == 3'd1 && add_start && !bn_start && in_channel != 4'd0)
				sum2_img[address - 1024] <= sum2_img[address - 1024] + write_in;
		end
	end 
end

always @ (posedge clk)
begin
	if(reset)
	begin
		for(i=0; i<1024; i=i+1)
		sum3_img[i] <= 19'b0;	
	end
	else if(ena3)
	begin
		if(address > 2047 && address < 3072 && !pool_start)
		begin
			if(layer == 3'd1 && bn_start)
				sum3_img[address - 2048] <= write_in;
			else if(layer == 3'd1 && add_start && !bn_start && in_channel == 4'd0)
				sum3_img[address - 2048] <= write_in;
			else if(layer == 3'd1 && add_start && !bn_start && in_channel != 4'd0)
				sum3_img[address - 2048] <= sum3_img[address - 2048] + write_in;
		end
	end 
end

always @ (posedge clk)
begin
	if(reset)
	begin
		for(i=0; i<1024; i=i+1)
		sum4_img[i] <= 19'b0;	
	end
	else if(ena4)
	begin
		if(address > 3071 && address < 4096 && !pool_start)
		begin
			if(layer == 3'd1 && bn_start)
				sum4_img[address - 3072] <= write_in;
			else if(layer == 3'd1 && add_start && !bn_start && in_channel == 4'd0)
				sum4_img[address - 3072] <= write_in;
			else if(layer == 3'd1 && add_start && !bn_start && in_channel != 4'd0)
				sum4_img[address - 3072] <= sum4_img[address - 3072] + write_in;
		end
	end 
end

always @ (*)
begin
	if(reset)
	begin
		pool1 = 19'b0;
	end
	else if(layer == 3'd1 && pool_start && address < 1024)
		pool1 = sum1_img[address];
	else if(layer == 3'd1 && pool_start && address < 2048)
		pool1 = sum2_img[address - 1024];
	else if(layer == 3'd1 && pool_start && address < 3072)
		pool1 = sum3_img[address - 2048];
	else if(layer == 3'd1 && pool_start && address < 4096)
		pool1 = sum4_img[address - 3072];
	else if(pool_start)
		pool1 = sum1_img[address];
	else pool1 = 19'b0;
end

always @ (*)
begin
	if(reset)
	begin
		pool2 = 19'b0;
	end
	else if(layer == 3'd1 && pool_start && address < 1024)
		pool2 = sum1_img[address + 1];
	else if(layer == 3'd1 && pool_start && address < 2048)
		pool2 = sum2_img[address - 1023];
	else if(layer == 3'd1 && pool_start && address < 3072)
		pool2 = sum3_img[address - 2047];
	else if(layer == 3'd1 && pool_start && address < 4096)
		pool2 = sum4_img[address - 3071];	
	else if(pool_start)
		pool2 = sum1_img[address+1];
	else pool2 = 19'b0;
end

always @ (*)
begin
	if(reset)
	begin
		pool3 = 19'b0;
	end
	else if(layer == 3'd1 && pool_start && address < 1024)
		pool3 = sum1_img[address + 64];
	else if(layer == 3'd1 && pool_start && address < 2048)
		pool3 = sum2_img[address - 960];
	else if(layer == 3'd1 && pool_start && address < 3072)
		pool3 = sum3_img[address - 1984];
	else if(layer == 3'd1 && pool_start && address < 4096)
		pool3 = sum4_img[address - 3008];
	else if(layer == 3'd2 && pool_start)
		pool3 = sum1_img[address+32];
	else if(layer == 3'd3 && pool_start)
		pool3 = sum1_img[address+16];
	else if(layer == 3'd4 && pool_start)
		pool3 = sum1_img[address+8];
	else pool3 = 19'b0;
end

always @ (*)
begin
	if(reset)
	begin
		pool4 = 19'b0;
	end
	else if(layer == 3'd1 && pool_start && address < 1024)
		pool4 = sum1_img[address + 65];
	else if(layer == 3'd1 && pool_start && address < 2048)
		pool4 = sum2_img[address - 959];
	else if(layer == 3'd1 && pool_start && address < 3072)
		pool4 = sum3_img[address - 1983];
	else if(layer == 3'd1 && pool_start && address < 4096)
		pool4 = sum4_img[address - 3007];
	else if(layer == 3'd2 && pool_start)
		pool4 = sum1_img[address + 33];
	else if(layer == 3'd3 && pool_start)
		pool4 = sum1_img[address + 17];
	else if(layer == 3'd4 && pool_start)
		pool4 = sum1_img[address + 9];
	else pool4 = 19'b0;
end

endmodule

