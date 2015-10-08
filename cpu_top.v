`include "stage_fetch.v"
`include "stage_decode.v"
`include "stage_exe.v"
`include "reg_if_id.v"
`include "reg_id_exe.v"
`include "pc_decider.v"
`include "send_pc.v"

module cpu_top(clk, rst);
	input clk, rst;
	
	wire [31:0] pc_from_send_pc;
	
	wire [31:0] pc_from_decider;
	
	wire MM_cond_from_fetch;
	wire is32_from_fetch;
	wire mul_pulse_from_fetch;
	wire mul_stable_from_fetch;
	wire [15:0] ins16_from_fetch;
	wire [31:0] ins32_from_fetch;
	wire [31:0] pc_real_from_fetch;
	
	wire is32_from_if_id;
	wire MM_cond_from_if_id;
	wire mul_pulse_from_if_id;
	wire mul_stable_from_if_id;
	wire [15:0] ins16_from_if_id;
	wire [31:0] ins32_from_if_id;
	wire [31:0] pc_real_from_if_id;
	
	wire branch_from_stage2;
	wire w_N_en_from_decode_from_stage2;
	wire w_Z_en_from_decode_from_stage2;
	wire w_C_en_from_decode_from_stage2;
	wire w_V_en_from_decode_from_stage2;
	wire w_reg_en_from_decode_from_stage2;
	wire w_mem_en_from_decode_from_stage2;
	wire w_mem_en_from_multiple_from_stage2;
	wire w_reg_en_from_multiple_from_stage2;
	wire r_mem_data_src_from_stage2;
	wire [1:0] mem_addr_src_from_stage2;
	wire [1:0] alu_src_cin_choose_from_stage2;
	wire [2:0] alu_src1_choose_from_stage2;
	wire [2:0] alu_src2_choose_from_stage2;
	wire [2:0] w_reg_addr_src_from_stage2;
	wire [2:0] w_reg_data_src_from_stage2;
	wire [2:0] HSIZE_from_decode_from_stage2;
	wire [3:0] cond_from_stage2;
	wire [3:0] addr_n_from_stage2;
	wire [3:0] addr_d_from_stage2;
	wire [3:0] addr_t_from_stage2;
	wire [3:0] addr_i_from_stage2;
	wire [4:0] alu_op_from_stage2;
	wire [31:0] imm32_from_stage2;
	wire [31:0] Rn_from_stage2;
	wire [31:0] Rm_from_stage2;
	wire [31:0] Rt_from_stage2;
	wire [31:0] Ri_from_stage2;
	wire [31:0] pc_from_stage2;
	wire [31:0] bit_count_number_from_stage2;
	wire [31:0] dm_addr_from_delayer_from_stage2;
	wire [9:0] list_from_list_count_from_stage2;
	wire [9:0] list_from_regbank_from_stage2;
	wire [31:0] psr_out_from_stage2;
	wire cntrl_from_stage2;
	
	wire apsr_N_from_id_exe;
	wire apsr_Z_from_id_exe;
	wire apsr_C_from_id_exe;
	wire apsr_V_from_id_exe;
	wire r_mem_data_src_from_id_exe;
	wire w_mem_en_from_decode_from_id_exe;
	wire w_reg_en_from_decode_from_id_exe;
	wire w_mem_en_from_multiple_from_id_exe;
	wire w_reg_en_from_multiple_from_id_exe;
	wire [1:0] mem_addr_src_from_id_exe;
	wire [1:0] alu_src_cin_choose_from_id_exe;
	wire [2:0] alu_src1_choose_from_id_exe;
	wire [2:0] alu_src2_choose_from_id_exe;
	wire [2:0] w_reg_addr_src_from_id_exe;
	wire [2:0] w_reg_data_src_from_id_exe;
	wire [2:0] HSIZE_from_decode_from_id_exe;
	wire [3:0] cond_from_id_exe;
	wire [3:0] addr_d_from_id_exe;
	wire [3:0] addr_t_from_id_exe;
	wire [3:0] addr_n_from_id_exe;
	wire [3:0] addr_i_from_id_exe;
	wire [4:0] alu_op_from_id_exe;
	wire [31:0] Rn_from_id_exe;
	wire [31:0] Rm_from_id_exe;
	wire [31:0] Rt_from_id_exe;
	wire [31:0] Ri_from_id_exe;
	wire [31:0] imm32_from_id_exe;
	wire [31:0] pc_real_from_id_exe;
	wire [31:0] bit_count_number_from_id_exe;
	wire [31:0] addr_dm_out_from_id_exe;
	wire branch_from_id_exe;
	wire w_N_en_from_id_exe;
	wire w_Z_en_from_id_exe;
	wire w_C_en_from_id_exe;
	wire w_V_en_from_id_exe;
	
	wire alu_out_N_from_exe;
	wire alu_out_Z_from_exe;
	wire alu_out_C_from_exe;
	wire alu_out_V_from_exe;
	wire condition_pass_from_exe;
	wire [3:0] w_reg_addr_from_exe;
	wire [31:0] w_reg_data_from_exe;
	wire [31:0] alu_result_from_exe;
	wire w_reg_en_from_exe;
	
	stage_fetch 	s1(	.clk(clk),
						.rst(rst),
						.pc_d(pc_from_send_pc),
						.pc_r(pc_from_stage2),
						.list(list_from_regbank_from_stage2),
						.is32(is32_from_fetch),
						.multiple_pulse(mul_pulse_from_fetch),
						.multiple_stable(mul_stable_from_fetch),
						.instruction16(ins16_from_fetch),
						.instruction32(ins32_from_fetch),
						.MM_cond(MM_cond_from_fetch),
						.pc_real(pc_real_from_fetch)
						);
	reg_if_id		r1(	.clk(clk),
						.rst(rst),
						.instruction16_in(ins16_from_fetch),
						.instruction32_in(ins32_from_fetch),
						.is32_in(is32_from_fetch),
						.MM_cond_in(MM_cond_from_fetch),
						.pc_real_in(pc_real_from_fetch),
						.multiple_pulse_in(mul_pulse_from_fetch),
						.multiple_stable_in(mul_stable_from_fetch),
						.instruction16_out(ins16_from_if_id),
						.instruction32_out(ins32_from_if_id),
						.is32_out(is32_from_if_id),
						.MM_cond_out(MM_cond_from_if_id),
						.pc_real_out(pc_real_from_if_id),
						.multiple_pulse_out(mul_pulse_from_if_id),
						.multiple_stable_out(mul_stable_from_if_id)
						);	
	stage_decode 	s2(	.rst(rst),
						.clk(clk),
						.ins16(ins16_from_if_id),
						.ins32(ins32_from_if_id),
						.MM_cond(MM_cond_from_if_id),
						.is32(is32_from_if_id),
						.multiple_pulse(mul_pulse_from_if_id),
						.multiple_stable(mul_stable_from_if_id),
						.w_reg_en(w_reg_en_from_exe),
						.w_reg_addr(w_reg_addr_from_exe),
						.w_reg_in(w_reg_data_from_exe),
						.w_N_in(alu_out_N_from_exe),
						.w_Z_in(alu_out_Z_from_exe),
						.w_C_in(alu_out_C_from_exe),
						.w_V_in(alu_out_V_from_exe),
						.w_N_en(w_N_en_from_id_exe),
						.w_Z_en(w_Z_en_from_id_exe),
						.w_C_en(w_C_en_from_id_exe),
						.w_V_en(w_V_en_from_id_exe),
						.Rn_from_reg_id_exe(Rn_from_id_exe),
						.bit_count_number_from_reg_id_exe(bit_count_number_from_id_exe),						
						.w_pc_in(pc_from_decider),
						.pc(pc_from_stage2),
						.addr_n(addr_n_from_stage2),
						.addr_d(addr_d_from_stage2),
						.addr_t(addr_t_from_stage2),
						.addr_i(addr_i_from_stage2),
						.imm32(imm32_from_stage2),
						.Rn(Rn_from_stage2),
						.Rm(Rm_from_stage2),
						.Rt(Rt_from_stage2),
						.Ri(Ri_from_stage2),
						.w_N_en_from_decode(w_N_en_from_decode_from_stage2),
						.w_Z_en_from_decode(w_Z_en_from_decode_from_stage2),
						.w_C_en_from_decode(w_C_en_from_decode_from_stage2),
						.w_V_en_from_decode(w_V_en_from_decode_from_stage2),
						.w_reg_en_from_decode(w_reg_en_from_decode_from_stage2),
						.cond(cond_from_stage2),
						.branch(branch_from_stage2),
						.alu_src1_choose(alu_src1_choose_from_stage2),
						.alu_src2_choose(alu_src2_choose_from_stage2),
						.alu_src_cin_choose(alu_src_cin_choose_from_stage2),
						.alu_op(alu_op_from_stage2),
						.w_reg_addr_src(w_reg_addr_src_from_stage2),
						.w_reg_data_src(w_reg_data_src_from_stage2),
						.w_mem_en_from_decode(w_mem_en_from_decode_from_stage2),
						.mem_addr_src(mem_addr_src_from_stage2),
						.r_mem_data_src(r_mem_data_src_from_stage2),
						.HSIZE_from_decode(HSIZE_from_decode_from_stage2),
						.bit_count_number(bit_count_number_from_stage2),
						.dm_addr_from_delayer(dm_addr_from_delayer_from_stage2),
						.w_mem_en_from_multiple(w_mem_en_from_multiple_from_stage2),
						.w_reg_en_from_multiple(w_reg_en_from_multiple_from_stage2),
						.reglist_from_list_count(list_from_list_count_from_stage2),
						.psr_out(psr_out_from_stage2),
						.reglist_from_regbank(list_from_regbank_from_stage2),
						.cntrl(cntrl_from_stage2)
						);
	reg_id_exe		r2(.rst(rst),
						.clk(clk),
						.cond_in(cond_from_stage2),
						.apsr_N_in(psr_out_from_stage2[31]),
						.apsr_Z_in(psr_out_from_stage2[30]),
						.apsr_C_in(psr_out_from_stage2[29]),
						.apsr_V_in(psr_out_from_stage2[28]),
						.HSIZE_from_decode_in(HSIZE_from_decode_from_stage2),
						.w_mem_en_from_decode_in(w_mem_en_from_decode_from_stage2),
						.w_reg_en_from_decode_in(w_reg_en_from_decode_from_stage2),
						.w_mem_en_from_multiple_in(w_mem_en_from_multiple_from_stage2),
						.w_reg_en_from_multiple_in(w_reg_en_from_multiple_from_stage2),
						.alu_op_in(alu_op_from_stage2),
						.alu_src_cin_choose_in(alu_src_cin_choose_from_stage2),
						.alu_src1_choose_in(alu_src1_choose_from_stage2),
						.alu_src2_choose_in(alu_src2_choose_from_stage2),
						.mem_addr_src_in(mem_addr_src_from_stage2),
						.r_mem_data_src_in(r_mem_data_src_from_stage2),
						.w_reg_addr_src_in(w_reg_addr_src_from_stage2),
						.w_reg_data_src_in(w_reg_data_src_from_stage2),
						.Rn_in(Rn_from_stage2),
						.Rm_in(Rm_from_stage2),
						.Rt_in(Rt_from_stage2),
						.Ri_in(Ri_from_stage2),
						.imm32_in(imm32_from_stage2),
						.pc_real_in(pc_real_from_if_id),
						.bit_count_number_in(bit_count_number_from_stage2),
						.addr_dm_out_in(dm_addr_from_delayer_from_stage2),
						.addr_d_in(addr_d_from_stage2),
						.addr_t_in(addr_t_from_stage2),
						.addr_n_in(addr_n_from_stage2),
						.addr_i_in(addr_i_from_stage2),
						.branch_in(branch_from_stage2),
						.w_N_en_in(w_N_en_from_decode_from_stage2),
						.w_Z_en_in(w_Z_en_from_decode_from_stage2),
						.w_C_en_in(w_C_en_from_decode_from_stage2),
						.w_V_en_in(w_V_en_from_decode_from_stage2),
						.cond_out(cond_from_id_exe),
						.apsr_N_out(apsr_N_from_id_exe),
						.apsr_Z_out(apsr_Z_from_id_exe),
						.apsr_C_out(apsr_C_from_id_exe),
						.apsr_V_out(apsr_V_from_id_exe),
						.HSIZE_from_decode_out(HSIZE_from_decode_from_id_exe),
						.w_mem_en_from_decode_out(w_mem_en_from_decode_from_id_exe),
						.w_reg_en_from_decode_out(w_reg_en_from_decode_from_id_exe),
						.w_mem_en_from_multiple_out(w_mem_en_from_multiple_from_id_exe),
						.w_reg_en_from_multiple_out(w_reg_en_from_multiple_from_id_exe),
						.alu_op_out(alu_op_from_id_exe),
						.alu_src_cin_choose_out(alu_src_cin_choose_from_id_exe),
						.alu_src1_choose_out(alu_src1_choose_from_id_exe),
						.alu_src2_choose_out(alu_src2_choose_from_id_exe),
						.mem_addr_src_out(mem_addr_src_from_id_exe),
						.r_mem_data_src_out(r_mem_data_src_from_id_exe),
						.w_reg_addr_src_out(w_reg_addr_src_from_id_exe),
						.w_reg_data_src_out(w_reg_data_src_from_id_exe),
						.Rn_out(Rn_from_id_exe),
						.Rm_out(Rm_from_id_exe),
						.Rt_out(Rt_from_id_exe),
						.Ri_out(Ri_from_id_exe),
						.imm32_out(imm32_from_id_exe),
						.pc_real_out(pc_real_from_id_exe),
						.bit_count_number_out(bit_count_number_from_id_exe),
						.addr_dm_out_out(addr_dm_out_from_id_exe),
						.addr_d_out(addr_d_from_id_exe),
						.addr_t_out(addr_t_from_id_exe),
						.addr_n_out(addr_n_from_id_exe),
						.addr_i_out(addr_i_from_id_exe),
						.branch_out(branch_from_id_exe),
						.w_N_en_out(w_N_en_from_id_exe),
						.w_Z_en_out(w_Z_en_from_id_exe),
						.w_C_en_out(w_C_en_from_id_exe),
						.w_V_en_out(w_V_en_from_id_exe)
						);
	stage_exe		s3(	.clk(clk),
						.cond(cond_from_id_exe),
						.apsr_N(apsr_N_from_id_exe),
						.apsr_Z(apsr_Z_from_id_exe),
						.apsr_C(apsr_C_from_id_exe),
						.apsr_V(apsr_V_from_id_exe),
						.HSIZE_from_decode(HSIZE_from_decode_from_id_exe),
						.w_mem_en_from_decode(w_mem_en_from_decode_from_id_exe),
						.w_reg_en_from_decode(w_reg_en_from_decode_from_id_exe),
						.w_mem_en_from_multiple(w_mem_en_from_multiple_from_id_exe),
						.w_reg_en_from_multiple(w_reg_en_from_multiple_from_id_exe),
						.alu_op(alu_op_from_id_exe),
						.alu_src_cin_choose(alu_src_cin_choose_from_id_exe),
						.alu_src1_choose(alu_src1_choose_from_id_exe),
						.alu_src2_choose(alu_src2_choose_from_id_exe),
						.mem_addr_src(mem_addr_src_from_id_exe),
						.r_mem_data_src(r_mem_data_src_from_id_exe),
						.w_reg_addr_src(w_reg_addr_src_from_id_exe),
						.w_reg_data_src(w_reg_data_src_from_id_exe),
						.Rn(Rn_from_id_exe),
						.Rm(Rm_from_id_exe),
						.Rt(Rt_from_id_exe),
						.Ri(Ri_from_id_exe),
						.imm32(imm32_from_id_exe),
						.pc_real(pc_real_from_id_exe),
						.bit_count_number(bit_count_number_from_id_exe),
						.addr_dm_out(addr_dm_out_from_id_exe),
						.addr_d(addr_d_from_id_exe),
						.addr_t(addr_t_from_id_exe),
						.addr_n(addr_n_from_id_exe),
						.addr_i(addr_i_from_id_exe),
						.alu_result(alu_result_from_exe),
						.alu_out_N(alu_out_N_from_exe),
						.alu_out_Z(alu_out_Z_from_exe),
						.alu_out_C(alu_out_C_from_exe),
						.alu_out_V(alu_out_V_from_exe),
						.condition_pass(condition_pass_from_exe),
						.w_reg_addr(w_reg_addr_from_exe),
						.w_reg_data(w_reg_data_from_exe),
						.w_reg_en(w_reg_en_from_exe)
						);
	send_pc sp(			.pc_reg(pc_from_stage2),
						.cntrl(cntrl_from_stage2),
						.pc_send(pc_from_send_pc)
						);
	pc_decider pd(		.multiple_stable(mul_stable_from_fetch),
						.multiple_stable_from_if_id(mul_stable_from_if_id),
						.multiple_pulse_from_if_id(mul_pulse_from_if_id),
						.list_from_list_count(list_from_list_count_from_stage2),
						.pc_in(pc_from_stage2),
						.pc_branch(alu_result_from_exe),
						.branch(branch_from_id_exe),
						.nextpc_out(pc_from_decider)
						);
endmodule