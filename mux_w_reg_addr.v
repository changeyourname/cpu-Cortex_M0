//存回Reg之addr (w_reg_addr_src)
`define S6_addr_d 3'd0
`define S6_addr_t 3'd1
`define S6_addr_i 3'd2//addr_i 來自list_count 的 reg_addr_out
`define S6_addr_n 3'd3	//Rn for LDM STM

module mux_w_reg_addr(
		w_reg_addr_src,
		w_reg_en_from_multiple,
		addr_d,
		addr_t,
		addr_i,
		addr_n,
		w_reg_addr
		);

input [2:0] w_reg_addr_src;
input w_reg_en_from_multiple;

input [3:0] addr_d;
input [3:0] addr_t;
input [3:0] addr_i;
input [3:0] addr_n;

output [3:0] w_reg_addr;
reg [3:0] w_reg_addr;

always@(w_reg_addr_src or w_reg_en_from_multiple or addr_d or addr_t or addr_i or addr_n)begin
	if(w_reg_en_from_multiple)
		w_reg_addr <= addr_i ;
	else
	case(w_reg_addr_src)
		`S6_addr_d:
			w_reg_addr <= addr_d ;
		`S6_addr_t:
			w_reg_addr <= addr_t ;
		`S6_addr_n:
			w_reg_addr <= addr_n ;
		
	endcase
end
		
endmodule