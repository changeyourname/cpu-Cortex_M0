`include "alu.v"
`include "data_mem.v"
`include "condition_test.v"
`include "mux_alu_cin.v"
`include "mux_alu_src1.v"
`include "mux_alu_src2.v"
`include "mux_mem_addr.v"
`include "mux_r_mem_data.v"
`include "mux_w_mem_data.v"
`include "mux_w_reg_data.v"
`include "mux_w_reg_addr.v"

module stage_exe(
		clk,
		cond,
		apsr_N,
		apsr_Z,
		apsr_C,
		apsr_V,
		HSIZE_from_decode,
		w_mem_en_from_decode,
		w_reg_en_from_decode,
		w_mem_en_from_multiple,
		w_reg_en_from_multiple,
		alu_op,
		alu_src_cin_choose,
		alu_src1_choose,
		alu_src2_choose,
		mem_addr_src,
		r_mem_data_src,
		w_reg_addr_src,
		w_reg_data_src,
		Rn,
		Rm,
		Rt,
		Ri,
		imm32,
		pc_real,
		bit_count_number,
		addr_dm_out,
		addr_d,
		addr_t,
		addr_n,
		addr_i,

		alu_result,
		alu_out_N,
		alu_out_Z,
		alu_out_C,
		alu_out_V,
		condition_pass,
		w_reg_addr,
		w_reg_data,
		w_reg_en
);

input clk;

input [3:0] cond;
input apsr_N;
input apsr_Z;
input apsr_C;
input apsr_V;

input [2:0] HSIZE_from_decode;
input w_mem_en_from_decode;
input w_reg_en_from_decode;
input w_mem_en_from_multiple;
input w_reg_en_from_multiple;

input [4:0] alu_op;
input [1:0] alu_src_cin_choose;
input [2:0] alu_src1_choose;
input [2:0] alu_src2_choose;

input [1:0] mem_addr_src;
input r_mem_data_src;
input [2:0] w_reg_addr_src;
input [2:0] w_reg_data_src;

input [31:0] Rn;
input [31:0] Rm;
input [31:0] Rt;
input [31:0] Ri;
input [31:0] imm32;
input [31:0] pc_real;
input [31:0] bit_count_number;
input [31:0] addr_dm_out;

input [3:0] addr_d;
input [3:0] addr_t;
input [3:0] addr_n;
input [3:0] addr_i; 

output [31:0] alu_result;
output alu_out_N;
output alu_out_Z;
output alu_out_C;
output alu_out_V;
output condition_pass;

output [3:0] w_reg_addr;
output [31:0] w_reg_data;
output w_reg_en;

wire [31:0] alu_src1;
wire [31:0] alu_src2;
wire alu_src_cin;

wire w_mem_en;
wire [2:0] HSIZE;
wire [31:0] data_mem_addr;
wire [31:0] w_mem_data;
wire [31:0] r_mem_data;
wire [31:0] r_mem_data_with_extend;

wire multiple_working;

assign w_mem_en= w_mem_en_from_decode|w_mem_en_from_multiple;
assign w_reg_en= w_reg_en_from_decode|w_reg_en_from_multiple;

assign multiple_working= w_mem_en_from_multiple | w_reg_en_from_multiple;
assign HSIZE = (multiple_working)? 3'b010 : HSIZE_from_decode;	//3'b010 stands for "32bit"

alu	u_alu(
		.src1(alu_src1), 
		.src2(alu_src2), 
		.src_cin(alu_src_cin), 
		.alu_op(alu_op),
		.result(alu_result), 
		.N(alu_out_N),
		.Z(alu_out_Z),
		.C(alu_out_C),
		.V(alu_out_V)	);
		
data_mem u_data_mem(
		.clk(clk), 
		.addr(data_mem_addr), 
		.HSIZE(HSIZE), 
		.w_en(w_mem_en), 
		.write_data(w_mem_data), 
		.read_data(r_mem_data)	);

condition_test u_condition_test(
		.cond(cond),
		.N(apsr_N),
		.Z(apsr_Z),
		.C(apsr_C),
		.V(apsr_V),
		.pass(condition_pass)	);
		
mux_alu_cin u_mux_alu_cin(
		.alu_src_cin_choose(alu_src_cin_choose),
		.apsr_c(apsr_C),
		.alu_src_cin(alu_src_cin)	);

mux_alu_src1 u_mux_alu_src1(
		.alu_src1_choose(alu_src1_choose),
		.Rn(Rn),
		.Rm(Rm),
		.PC(pc_real),
		.alu_src1(alu_src1)	);

mux_alu_src2 u_mux_alu_src2(
		.alu_src2_choose(alu_src2_choose),
		.Rm(Rm),
		.imm32(imm32),
		.bit_count_number(bit_count_number),
		.alu_src2(alu_src2)	);

mux_mem_addr u_mux_mem_addr(
		.Rn(Rn),
		.Rm(Rm),
		.imm32(imm32),
		.pc_real(pc_real),
		.addr_dm_out(addr_dm_out),
		.multiple_working(multiple_working),
		.mem_addr_src(mem_addr_src),
		.mem_addr(data_mem_addr)	);
		
mux_r_mem_data u_mux_r_mem_data(
		.r_mem_data(r_mem_data), 
		.r_mem_data_src(r_mem_data_src),
		.HSIZE(HSIZE),
		.r_mem_data_with_extend(r_mem_data_with_extend)		);
		
mux_w_mem_data u_mux_w_mem_data(
		.w_mem_en_from_multiple(w_mem_en_from_multiple),
		.Rt(Rt),
		.Ri(Ri),
		.w_mem_data(w_mem_data)	);
		
mux_w_reg_addr u_mux_w_reg_addr(
		.w_reg_addr_src(w_reg_addr_src),
		.w_reg_en_from_multiple(w_reg_en_from_multiple),
		.addr_d(addr_d),
		.addr_t(addr_t),
		.addr_i(addr_i),
		.addr_n(addr_n),
		.w_reg_addr(w_reg_addr)	);
		
mux_w_reg_data u_mux_w_reg_data(
		.w_reg_data_src(w_reg_data_src),
		.w_reg_en_from_multiple(w_reg_en_from_multiple),
		.Ri(Ri),
		.alu_result(alu_result),
		.r_mem_data_with_extend(r_mem_data_with_extend),
		.pc_real(pc_real),
		.w_reg_data(w_reg_data)	);
		

endmodule