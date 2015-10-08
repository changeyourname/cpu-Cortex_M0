
module mux_w_mem_data(
		w_mem_en_from_multiple,
		Rt,
		Ri,
		w_mem_data	);

input w_mem_en_from_multiple;
input [31:0] Rt;
input [31:0] Ri;
output [31:0] w_mem_data;

assign w_mem_data= w_mem_en_from_multiple? Ri : Rt;

endmodule