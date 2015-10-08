module bit_count(list_in, bit_count_out);

	input [9:0] list_in;
	output [31:0] bit_count_out;
	wire [1:0] bitAdd1;
	wire [1:0] bitAdd2;
	wire [1:0] bitAdd3;
	wire [1:0] bitAdd4;
	wire [2:0] bitAdd5;
	wire [2:0] bitAdd6;
	wire [3:0] bitAdd7;
	
	assign bitAdd1 = (	{ 1'b0, list_in[9]}+
						{ 1'b0, list_in[8]}+
						{ 1'b0, list_in[7]}	);
	assign bitAdd2 = (	{ 1'b0, list_in[6]}+
						{ 1'b0, list_in[5]}+
						{ 1'b0, list_in[4]}	);
	assign bitAdd3 = (	{ 1'b0, list_in[3]}+
						{ 1'b0, list_in[2]}	);
	assign bitAdd4 = (	{ 1'b0, list_in[1]}+
						{ 1'b0, list_in[0]}	);
						
	assign bitAdd5	= { 1'b0, bitAdd1}+{ 1'b0, bitAdd2};
	assign bitAdd6	= { 1'b0, bitAdd3}+{ 1'b0, bitAdd4};
	
	assign bitAdd7	= { 1'b0, bitAdd5}+{ 1'b0, bitAdd6};
						
	assign bit_count_out= {26'd0, bitAdd7, 2'b00};
	
endmodule