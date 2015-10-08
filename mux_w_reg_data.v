
`define S8_ALU_RESULT 3'd0
`define S8_MEM_RESULT 3'd1
`define S8_FOR_BLX 3'd5
`define S8_FOR_BL 3'd6

module mux_w_reg_data(
		w_reg_data_src,
		w_reg_en_from_multiple,
		Ri,
		alu_result,
		r_mem_data_with_extend,
		pc_real,
		w_reg_data
		);
		
input [2:0] w_reg_data_src;
input w_reg_en_from_multiple;
input [31:0] Ri;
input [31:0] alu_result;
input [31:0] r_mem_data_with_extend;
input [31:0] pc_real;

output [31:0] w_reg_data;
reg [31:0] w_reg_data;

always@(w_reg_data_src or w_reg_en_from_multiple or Ri or alu_result or r_mem_data_with_extend or pc_real)begin
	if(w_reg_en_from_multiple)
		w_reg_data <= Ri;
	else
		case(w_reg_data_src)
			`S8_ALU_RESULT:
				w_reg_data <= alu_result;
			`S8_MEM_RESULT:
				w_reg_data <= r_mem_data_with_extend;
			`S8_FOR_BLX:
				w_reg_data <= {pc_real[31:1],1'b1};		
			`S8_FOR_BL:
				w_reg_data <= {pc_real[31:1],1'b1} -32'd2 ;//discussion
		endcase
end

endmodule