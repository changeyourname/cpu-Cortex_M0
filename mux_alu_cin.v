`define SC_0 2'd0
`define SC_1 2'd1
`define SC_APSR 2'd2

module mux_alu_cin(
	alu_src_cin_choose,
	apsr_c,
	alu_src_cin
);
	input [1:0]alu_src_cin_choose;
	input apsr_c;	
	output alu_src_cin;
	
	reg alu_src_cin;
	
	always@(alu_src_cin_choose or apsr_c)begin
		case(alu_src_cin_choose)
			`SC_0:	alu_src_cin <= 1'b0;
			`SC_1:	alu_src_cin <= 1'b1;
			`SC_APSR: alu_src_cin <= apsr_c;
			default: alu_src_cin <= 1'b0;//x
		endcase
	end
	
endmodule