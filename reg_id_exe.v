module reg_id_exe(
		rst,
		clk,

		cond_in,
		apsr_N_in,
		apsr_Z_in,
		apsr_C_in,
		apsr_V_in,
		HSIZE_from_decode_in,
		w_mem_en_from_decode_in,
		w_reg_en_from_decode_in,
		w_mem_en_from_multiple_in,
		w_reg_en_from_multiple_in,
		alu_op_in,
		alu_src_cin_choose_in,
		alu_src1_choose_in,
		alu_src2_choose_in,
		mem_addr_src_in,
		r_mem_data_src_in,
		w_reg_addr_src_in,
		w_reg_data_src_in,
		Rn_in,
		Rm_in,
		Rt_in,
		Ri_in,
		imm32_in,
		pc_real_in,
		bit_count_number_in,
		addr_dm_out_in,
		addr_d_in,
		addr_t_in,
		addr_n_in,
		addr_i_in,
		branch_in,
		w_N_en_in,
		w_Z_en_in,
		w_C_en_in,
		w_V_en_in,

		cond_out,
		apsr_N_out,
		apsr_Z_out,
		apsr_C_out,
		apsr_V_out,
		HSIZE_from_decode_out,
		w_mem_en_from_decode_out,
		w_reg_en_from_decode_out,
		w_mem_en_from_multiple_out,
		w_reg_en_from_multiple_out,
		alu_op_out,
		alu_src_cin_choose_out,
		alu_src1_choose_out,
		alu_src2_choose_out,
		mem_addr_src_out,
		r_mem_data_src_out,
		w_reg_addr_src_out,
		w_reg_data_src_out,
		Rn_out,
		Rm_out,
		Rt_out,
		Ri_out,
		imm32_out,
		pc_real_out,
		bit_count_number_out,
		addr_dm_out_out,
		addr_d_out,
		addr_t_out,
		addr_n_out,
		addr_i_out,
		branch_out,
		w_N_en_out,
		w_Z_en_out,
		w_C_en_out,
		w_V_en_out
);

input rst;
input clk;

input [3:0] cond_in ;
input apsr_N_in ;
input apsr_Z_in ;
input apsr_C_in ;
input apsr_V_in ;
input [2:0] HSIZE_from_decode_in ;
input w_mem_en_from_decode_in ;
input w_reg_en_from_decode_in ;
input w_mem_en_from_multiple_in ;
input w_reg_en_from_multiple_in ;
input [4:0] alu_op_in ;
input [1:0] alu_src_cin_choose_in ;
input [2:0] alu_src1_choose_in ;
input [2:0] alu_src2_choose_in ;
input [1:0] mem_addr_src_in ;
input r_mem_data_src_in ;
input [2:0] w_reg_addr_src_in ;
input [2:0] w_reg_data_src_in ;
input [31:0] Rn_in ;
input [31:0] Rm_in ;
input [31:0] Rt_in ;
input [31:0] Ri_in ;
input [31:0] imm32_in ;
input [31:0] pc_real_in ;
input [31:0] bit_count_number_in ;
input [31:0] addr_dm_out_in ;
input [3:0] addr_d_in ;
input [3:0] addr_t_in ;
input [3:0] addr_n_in ;
input [3:0] addr_i_in ; 
input branch_in;
input w_N_en_in;
input w_Z_en_in;
input w_C_en_in;
input w_V_en_in;

output [3:0] cond_out ;
output apsr_N_out ;
output apsr_Z_out ;
output apsr_C_out ;
output apsr_V_out ;
output [2:0] HSIZE_from_decode_out ;
output w_mem_en_from_decode_out ;
output w_reg_en_from_decode_out ;
output w_mem_en_from_multiple_out ;
output w_reg_en_from_multiple_out ;
output [4:0] alu_op_out ;
output [1:0] alu_src_cin_choose_out ;
output [2:0] alu_src1_choose_out ;
output [2:0] alu_src2_choose_out ;
output [1:0] mem_addr_src_out ;
output r_mem_data_src_out ;
output [2:0] w_reg_addr_src_out ;
output [2:0] w_reg_data_src_out ;
output [31:0] Rn_out ;
output [31:0] Rm_out ;
output [31:0] Rt_out ;
output [31:0] Ri_out ;
output [31:0] imm32_out ;
output [31:0] pc_real_out ;
output [31:0] bit_count_number_out ;
output [31:0] addr_dm_out_out ;
output [3:0] addr_d_out ;
output [3:0] addr_t_out ;
output [3:0] addr_n_out ;
output [3:0] addr_i_out ; 
output branch_out;
output w_N_en_out;
output w_Z_en_out;
output w_C_en_out;
output w_V_en_out;

reg [3:0] cond_out ;
reg apsr_N_out ;
reg apsr_Z_out ;
reg apsr_C_out ;
reg apsr_V_out ;
reg [2:0] HSIZE_from_decode_out ;
reg w_mem_en_from_decode_out ;
reg w_reg_en_from_decode_out ;
reg w_mem_en_from_multiple_out ;
reg w_reg_en_from_multiple_out ;
reg [4:0] alu_op_out ;
reg [1:0] alu_src_cin_choose_out ;
reg [2:0] alu_src1_choose_out ;
reg [2:0] alu_src2_choose_out ;
reg [1:0] mem_addr_src_out ;
reg r_mem_data_src_out ;
reg [2:0] w_reg_addr_src_out ;
reg [2:0] w_reg_data_src_out ;
reg [31:0] Rn_out ;
reg [31:0] Rm_out ;
reg [31:0] Rt_out ;
reg [31:0] Ri_out ;
reg [31:0] imm32_out ;
reg [31:0] pc_real_out ;
reg [31:0] bit_count_number_out ;
reg [31:0] addr_dm_out_out ;
reg [3:0] addr_d_out ;
reg [3:0] addr_t_out ;
reg [3:0] addr_n_out ;
reg [3:0] addr_i_out ; 
reg branch_out;
reg w_N_en_out;
reg w_Z_en_out;
reg w_C_en_out;
reg w_V_en_out;

always@(posedge rst or negedge clk)begin
	if(rst)begin
		cond_out <=0 ;
		apsr_N_out <=0 ;
		apsr_Z_out <=0 ;
		apsr_C_out <=0 ;
		apsr_V_out <=0 ;
		HSIZE_from_decode_out <=0 ;
		w_mem_en_from_decode_out <=0 ;
		w_reg_en_from_decode_out <=0 ;
		w_mem_en_from_multiple_out <=0 ;
		w_reg_en_from_multiple_out <=0 ;
		alu_op_out <=0 ;
		alu_src_cin_choose_out <=0 ;
		alu_src1_choose_out <=0 ;
		alu_src2_choose_out <=0 ;
		mem_addr_src_out <=0 ;
		r_mem_data_src_out <=0 ;
		w_reg_addr_src_out <=0 ;
		w_reg_data_src_out <=0 ;
		Rn_out <=0 ;
		Rm_out <=0 ;
		Rt_out <=0 ;
		Ri_out <=0 ;
		imm32_out <=0 ;
		pc_real_out <=0 ;
		bit_count_number_out <=0 ;
		addr_dm_out_out <=0 ;
		addr_d_out <=0 ;
		addr_t_out <=0 ;
		addr_n_out <=0 ;
		addr_i_out <=0 ;
		branch_out <=0 ;
		w_N_en_out <=0 ;
		w_Z_en_out <=0 ;
		w_C_en_out <=0 ;
		w_V_en_out <=0 ;
	end else begin
		cond_out  <=  cond_in ;
		apsr_N_out  <=  apsr_N_in ;
		apsr_Z_out  <=  apsr_Z_in ;
		apsr_C_out  <=  apsr_C_in ;
		apsr_V_out  <=  apsr_V_in ;
		HSIZE_from_decode_out  <=  HSIZE_from_decode_in ;
		w_mem_en_from_decode_out  <=  w_mem_en_from_decode_in ;
		w_reg_en_from_decode_out  <=  w_reg_en_from_decode_in ;
		w_mem_en_from_multiple_out  <=  w_mem_en_from_multiple_in ;
		w_reg_en_from_multiple_out  <=  w_reg_en_from_multiple_in ;
		alu_op_out  <=  alu_op_in ;
		alu_src_cin_choose_out  <=  alu_src_cin_choose_in ;
		alu_src1_choose_out  <=  alu_src1_choose_in ;
		alu_src2_choose_out  <=  alu_src2_choose_in ;
		mem_addr_src_out  <=  mem_addr_src_in ;
		r_mem_data_src_out  <=  r_mem_data_src_in ;
		w_reg_addr_src_out  <=  w_reg_addr_src_in ;
		w_reg_data_src_out  <=  w_reg_data_src_in ;
		Rn_out  <=  Rn_in ;
		Rm_out  <=  Rm_in ;
		Rt_out  <=  Rt_in ;
		Ri_out  <=  Ri_in ;
		imm32_out  <=  imm32_in ;
		pc_real_out  <=  pc_real_in ;
		bit_count_number_out  <=  bit_count_number_in ;
		addr_dm_out_out  <=  addr_dm_out_in ;
		addr_d_out  <=  addr_d_in ;
		addr_t_out  <=  addr_t_in ;
		addr_n_out  <=  addr_n_in ;
		addr_i_out  <=  addr_i_in ;
		branch_out <=  branch_in ;
		w_N_en_out <=  w_N_en_in ;
		w_Z_en_out <=  w_Z_en_in ;
		w_C_en_out <=  w_C_en_in ;
		w_V_en_out <=  w_V_en_in ;
	end
end

endmodule