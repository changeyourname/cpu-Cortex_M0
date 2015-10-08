`define S2_RM 3'd0
`define S2_IMM32 3'd1
`define S2_NOT_RM 3'd2
`define S2_NOT_IMM32 3'd3
`define S2_BIT_COUNT 3'd4
`define S2_NOT_BIT_COUNT 3'd5

module mux_alu_src2(
	alu_src2_choose,
	Rm,
	imm32,
	bit_count_number,
	alu_src2
);
	input [2:0]alu_src2_choose;
	input [31:0]Rm;
	input [31:0]imm32;
	input [31:0]bit_count_number;
	
	output [31:0]alu_src2;
	
	reg [31:0]alu_src2;
	
	always@(alu_src2_choose or Rm or imm32)begin
		case(alu_src2_choose)
			`S2_RM:	alu_src2 <= Rm;
			`S2_IMM32:	alu_src2 <= imm32;
			`S2_NOT_RM: alu_src2 <= ~Rm;
			`S2_NOT_IMM32: alu_src2 <= ~imm32;
			`S2_BIT_COUNT: alu_src2 <= bit_count_number;
			`S2_NOT_BIT_COUNT: alu_src2 <= ~bit_count_number;
			default: alu_src2 <= 32'hffff;//x
		endcase
	end	
endmodule