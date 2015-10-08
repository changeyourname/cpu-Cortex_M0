`include "addr_decoder.v"
`include "regbank.v"
`include "bit_count.v"
`include "list_count.v"
`include "regbank_special.v"
`include "list_addr_delay.v"

module stage_decode(
		rst,
		clk,
		ins16,
		ins32,
		MM_cond,
		is32,
		multiple_pulse,
		multiple_stable,
		w_reg_en,
		w_reg_addr,
		w_reg_in,
		w_N_in,
		w_Z_in,
		w_C_in,
		w_V_in,
		w_N_en,
		w_Z_en,
		w_C_en,
		w_V_en,
		Rn_from_reg_id_exe,
		bit_count_number_from_reg_id_exe,
		w_pc_in,

		pc,	
		addr_n,
		addr_d,
		addr_t,
		addr_i,
		imm32,
		Rn,
		Rm,
		Rt,
		Ri,
		w_N_en_from_decode,
		w_Z_en_from_decode,
		w_C_en_from_decode,
		w_V_en_from_decode,
		w_reg_en_from_decode,
		cond,
		branch,
		alu_src1_choose,
		alu_src2_choose,
		alu_src_cin_choose,
		alu_op,
		w_reg_addr_src,
		w_reg_data_src,
		w_mem_en_from_decode,
		mem_addr_src,
		r_mem_data_src,
		HSIZE_from_decode,
		bit_count_number,
		dm_addr_from_delayer,
		w_mem_en_from_multiple,
		w_reg_en_from_multiple,
		reglist_from_list_count,
		psr_out,
		reglist_from_regbank,
		cntrl
);

input rst;
input clk;
input [15:0] ins16;
input [31:0] ins32;
input MM_cond;
input is32;
input multiple_pulse;
input multiple_stable;
input w_reg_en;
input [3:0] w_reg_addr;
input [31:0] w_reg_in;
input w_N_in;
input w_Z_in;
input w_C_in;
input w_V_in;
input w_N_en;
input w_Z_en;
input w_C_en;
input w_V_en;
input [31:0] Rn_from_reg_id_exe;
input [31:0] bit_count_number_from_reg_id_exe;
input [31:0] w_pc_in;

output [31:0] pc;	//pc used to fetch instruction
output [3:0] addr_n;
output [3:0] addr_d;
output [3:0] addr_t;
output [3:0] addr_i; 
output [31:0] imm32;
output [31:0] Rn;
output [31:0] Rm;
output [31:0] Rt;
output [31:0] Ri;
output w_N_en_from_decode;
output w_Z_en_from_decode;
output w_C_en_from_decode;
output w_V_en_from_decode;
output w_reg_en_from_decode;
output [3:0] cond;
output branch;
output [2:0] alu_src1_choose;
output [2:0] alu_src2_choose;
output [1:0] alu_src_cin_choose;
output [4:0] alu_op;
output [2:0] w_reg_addr_src;
output [2:0] w_reg_data_src;
output w_mem_en_from_decode;
output [1:0] mem_addr_src ;
output r_mem_data_src;
output [2:0] HSIZE_from_decode;
output [31:0] bit_count_number;
output [31:0] dm_addr_from_delayer;
output w_mem_en_from_multiple;
output w_reg_en_from_multiple;
output [9:0] reglist_from_list_count;
output [31:0] psr_out;
output [9:0] reglist_from_regbank;
output cntrl;

wire [3:0] addr_m;
wire [1:0] push_pop;
wire [9:0] reglist_from_decode;
wire [31:0] dm_addr_from_list_count;

wire multiple_pulse_delay;
wire [1:0] multiple_vector_delay;
wire [3:0] reg_addr_from_list_count;


addr_decoder u_addr_decoder(
		.instruction16(ins16),
		.instruction32(ins32),
		.MM_cond(MM_cond),
		.is32(is32),
		.addr_m(addr_m),
		.addr_n(addr_n),
		.addr_d(addr_d),
		.addr_t(addr_t),
		.imm32(imm32),
		.reglist(reglist_from_decode),
		.option(),
		.SYSm(),
		.push_pop(push_pop),
		.w_N_en(w_N_en_from_decode),
		.w_Z_en(w_Z_en_from_decode),
		.w_C_en(w_C_en_from_decode),
		.w_V_en(w_V_en_from_decode),
		.w_reg_en(w_reg_en_from_decode),
		.cond(cond),
		.branch(branch),
		.alu_src1_choose(alu_src1_choose),
		.alu_src2_choose(alu_src2_choose),
		.alu_src_cin_choose(alu_src_cin_choose),
		.alu_op(alu_op),
		
		.w_reg_addr_src(w_reg_addr_src),
		.w_reg_data_src(w_reg_data_src),
		
		.w_mem_en(w_mem_en_from_decode),
		.mem_addr_src(mem_addr_src),
		.r_mem_data_src(r_mem_data_src),
		.HSIZE(HSIZE_from_decode),
		
		.udf(), 
		.upd()	
		);
regbank u_regbank(	
		.rst(rst), 
		.clk(clk),
		.push_pop(push_pop),
		.addr_n(addr_n),
		.addr_m(addr_m),
		.addr_i(addr_i),	//for regbank to output Ri at correct clk
		.addr_t_read(addr_t),

		.w_reg_addr(w_reg_addr),
		.w_reg_en(w_reg_en),
		.w_reg_in(w_reg_in),
		
		.Rn(Rn),
		.Rm(Rm),
		.Rt(Rt),
		.Ri(Ri),

		.w_pc_in(w_pc_in),
		.r_pc_out(pc),

		.is_mul_pulse(multiple_pulse),//is_mul
		
		.list_from_decode(reglist_from_decode),
		.list_from_list_count(reglist_from_list_count),
		.list(reglist_from_regbank),
		.cntrl_out(cntrl)
		);
		
list_count u_list_count(
				
		.list_in(reglist_from_regbank),
		.next_list(reglist_from_list_count), 
		.dm_addr_in(dm_addr_from_delayer), 
		.dm_addr_out(dm_addr_from_list_count), 
		.reg_addr_out(reg_addr_from_list_count),

		.multiple_pulse_delay(multiple_pulse_delay),
		.multiple_vector_delay(multiple_vector_delay),
		.Rn(Rn_from_reg_id_exe),
		.bit_count(bit_count_number_from_reg_id_exe)
		);

		
bit_count bc(
		.list_in(reglist_from_decode), //maybe it's reglist_from_regbank, i am not sure
		.bit_count_out(bit_count_number)
		);
		
list_addr_delay lad(
		.rst(rst),
		.clk(clk),
		
		.multiple_vector(ins16[12:11]),		
		.multiple_pulse(multiple_pulse),
		.multiple_stable(multiple_stable),
		.list(reglist_from_regbank),

		.dm_addr_in(dm_addr_from_list_count),
		.dm_addr_out(dm_addr_from_delayer),
		
		.reg_addr_in(reg_addr_from_list_count),
		.reg_addr_out(addr_i),
		
		.multiple_pulse_delay(multiple_pulse_delay),
		.multiple_vector_delay(multiple_vector_delay),
		.w_mem_en_from_multiple(w_mem_en_from_multiple),
		.w_reg_en_from_multiple(w_reg_en_from_multiple)

		);
regbank_special u_regbank_special(	
		.rst(rst),
		.clk(clk),
	
		.w_N_en(w_N_en),
		.w_Z_en(w_Z_en),
		.w_C_en(w_C_en),
		.w_V_en(w_V_en),
		.w_epsr_en(),
		.w_ipsr_en(),
		.w_primask_en(),
		.w_control_en(),
		
		.w_N_in(w_N_in),
		.w_Z_in(w_Z_in),
		.w_C_in(w_C_in),
		.w_V_in(w_V_in),
		.w_epsr_in(),
		.w_ipsr_in(),
		.w_primask_in(),
		.w_control_in(),
		
		.r_psr_out(psr_out),
		.r_primask_out(),
		.r_control_out()
		);
		

		
endmodule