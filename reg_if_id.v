module reg_if_id(	clk,
					rst,
					
					instruction16_in,
					instruction32_in,
					is32_in,
					MM_cond_in,
					pc_real_in,
					multiple_pulse_in,
					multiple_stable_in,
					
					instruction16_out,
					instruction32_out,
					is32_out,
					MM_cond_out,
					pc_real_out,
					multiple_pulse_out,
					multiple_stable_out
					);

	input clk, rst;
	input multiple_pulse_in, multiple_stable_in;
	input [15:0] instruction16_in;
	input [31:0] instruction32_in;
	input is32_in;
	input MM_cond_in;
	input [31:0] pc_real_in;

	output multiple_pulse_out, multiple_stable_out;
	output [15:0] instruction16_out;
	output [31:0] instruction32_out;
	output is32_out;
	output MM_cond_out;
	output [31:0] pc_real_out;
	
	reg multiple_pulse, multiple_stable;
	reg [15:0] instruction16;
	reg [31:0] instruction32;
	reg is32;
	reg MM_cond;
	reg [31:0] pc_real;
	
	assign instruction16_out = instruction16;
	assign instruction32_out = instruction32;
	assign is32_out = is32;
	assign MM_cond_out = MM_cond;
	assign pc_real_out = pc_real;
	assign multiple_pulse_out = multiple_pulse;
	assign multiple_stable_out = multiple_stable;

	always@(negedge clk or posedge rst)begin
		if(rst) begin
			instruction16 <= 0;
			instruction32 <= 0;
			is32 <= 0;
			MM_cond <= 0;
			pc_real <= 0;
			multiple_pulse <= 0;
			multiple_stable <= 0;
		end
		else begin
			instruction16 <= instruction16_in;
			instruction32 <= instruction32_in;
			is32 <= is32_in;
			MM_cond <= MM_cond_in;
			pc_real <= pc_real_in;
			multiple_pulse <= multiple_pulse_in;
			multiple_stable <= multiple_stable_in;
		end
	end
endmodule