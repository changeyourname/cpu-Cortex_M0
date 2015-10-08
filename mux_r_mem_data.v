//讀MEM之data時, 要做 ZeroExtend還是SignExtend (r_mem_data_src)
`define S5_ZEROEXTEND 1'd0
`define S5_SIGNEXTEND 1'd1

//讀寫MEM之data時, 是 8bit, 16bit, 32bit? (HSIZE)
`define HSIZE_8bit 3'b000
`define HSIZE_16bit 3'b001
`define HSIZE_32bit 3'b010
//`define HSIZE_8bit 3'b000

module mux_r_mem_data(
		r_mem_data, 
		r_mem_data_src,
		HSIZE,
		r_mem_data_with_extend		);

input [31:0] r_mem_data;
input r_mem_data_src;
input [2:0] HSIZE;

output [31:0] r_mem_data_with_extend;

reg [31:0] r_mem_data_with_extend;


always@(r_mem_data or r_mem_data_src or HSIZE )begin
	case(HSIZE)
		`HSIZE_8bit:
			if(r_mem_data_src==`S5_ZEROEXTEND)
				r_mem_data_with_extend <= {24'd0, r_mem_data[7:0]};
			else	//if (r_mem_data_src==`S5_SIGNEXTEND)
				r_mem_data_with_extend <= {{24{r_mem_data[7]}}, r_mem_data[7:0]};
		`HSIZE_16bit:
			if(r_mem_data_src==`S5_ZEROEXTEND)
				r_mem_data_with_extend <= {16'd0, r_mem_data[15:0]};
			else	//if (r_mem_data_src==`S5_SIGNEXTEND)
				r_mem_data_with_extend <= {{16{r_mem_data[15]}}, r_mem_data[15:0]};
		`HSIZE_32bit:
			r_mem_data_with_extend <= r_mem_data;
		default:
			r_mem_data_with_extend <= 32'dx;
	endcase
end

endmodule