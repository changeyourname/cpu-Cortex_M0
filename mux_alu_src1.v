`define S1_RN 3'd0
`define S1_RM 3'd1
`define S1_NOT_RN 3'd2
`define S1_PC_ALIGN 3'd3
`define S1_PC 3'd4

module mux_alu_src1(
	alu_src1_choose,
	Rn,
	Rm,
	PC,
	alu_src1
);
	input [2:0]alu_src1_choose;
	input [31:0]Rn;
	input [31:0]Rm;
	input [31:0]PC;
	
	output [31:0]alu_src1;
	
	reg [31:0]alu_src1;
	
	always@(alu_src1_choose or Rn or Rm or PC)begin
		case(alu_src1_choose)
			`S1_RN:	alu_src1 <= Rn;
			`S1_RM:	alu_src1 <= Rm;
			`S1_NOT_RN: alu_src1 <= ~Rn;
			`S1_PC_ALIGN: alu_src1 <= {PC[31:2],2'd0};
			`S1_PC: alu_src1 <= PC;
			default: alu_src1 <= 32'hffff;//x
		endcase
	end
endmodule