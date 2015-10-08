`include "instruction_mem.v"
`include "is_32.v"
`include "is_mul_pulse.v"
`include "is_mul_stable_odd.v"

module stage_fetch(	clk,
					rst,
					pc_d,
					pc_r,
					list,
					is32,
					multiple_pulse,
					multiple_stable,
					instruction16,
					instruction32,
					MM_cond,
					pc_real
					);

	input clk, rst;
	input [31:0] pc_d, pc_r;
	input [9:0] list;
	
	output multiple_pulse, multiple_stable;
	output is32;
	output MM_cond;
	output [31:0] pc_real;
	output [15:0]instruction16;
	output [31:0]instruction32;
	
	wire [31:0] new_instruction;
	wire [15:0] ins16;
	wire [31:0] ins32;
	wire multiple_stable_even, multiple_stable_odd;
	
	assign instruction16 = ins16;
	assign instruction32 = ins32;
	assign multiple_stable = multiple_stable_even | multiple_stable_odd;
	
	instruction_mem i_mem(	.clk(clk),
							.pc(pc_d),
							.instruction(new_instruction)
							);
	is_32 i3(	.clk(clk),
				.rst(rst),
				.pc(pc_r),
				.multiple(multiple_pulse),
				.list(list),
				.instruction(new_instruction),
				.is32(is32),
				.instruction_out32(instruction32),
				.instruction_out16(instruction16),
				.pc_real(pc_real),
				.multiple_stable_even(multiple_stable_even)
				);
	/*fetch f1(	.rst(rst),
				.clk(clk),
				.ins(new_instruction),
				.instruction16(ins16),
				.instruction32(ins32),
				.reglist_over(list),
				.is_mul(multiple_stable1),
				.is_mul_coming(multiple_pulse1),
				.is_32(is32),
				.pc_in(pc_r),
				.pc_out(pc_real),
				.MM_cond(MM_cond)
				);*/
	is_mul_pulse imp(	.instruction16_in(instruction16),
						.instruction32_in(instruction32),
						.is32(is32),
						.multiple_pulse(multiple_pulse),
						.MM_cond(MM_cond)
						);
	is_mul_stable_odd imso(	.instruction_from_mem(new_instruction),
							.is32_from_stage1(is32),
							.multiple_stable_odd(multiple_stable_odd)
							);
endmodule