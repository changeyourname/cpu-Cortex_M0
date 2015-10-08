//要讀或寫MEM之addr (mem_addr_src) (讀寫同一條)
`define S4_RN_RM 2'd0
`define S4_RN_IMM32 2'd1
`define S4_PC_ALIGN_IMM32 2'd2
`define S4_addr_dm_out 2'd3

module mux_mem_addr(
		Rn,
		Rm,
		imm32,
		pc_real,
		addr_dm_out,
		multiple_working,
		mem_addr_src,
		mem_addr	);

input [31:0] Rn;
input [31:0] Rm;
input [31:0] imm32;
input [31:0] pc_real;
input [31:0] addr_dm_out;

input multiple_working;
input [1:0] mem_addr_src;

output [31:0] mem_addr;

reg [31:0] mem_addr;

always@(Rn or Rm or imm32 or pc_real or addr_dm_out or multiple_working or mem_addr_src)begin
	if(multiple_working)
		mem_addr <= addr_dm_out;
	else
		case(mem_addr_src)
			`S4_RN_RM: mem_addr<= Rn+Rm;
			`S4_RN_IMM32: mem_addr<=Rn+imm32;
			`S4_PC_ALIGN_IMM32: mem_addr<= {pc_real[31:1],2'd0}+imm32;
			`S4_addr_dm_out: mem_addr<= addr_dm_out;
			default: mem_addr<=0;
		endcase
end
endmodule