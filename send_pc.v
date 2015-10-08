module send_pc(pc_reg, cntrl, pc_send);
	
	input [31:0] pc_reg;
	input cntrl;
	
	output [31:0] pc_send;
	
	assign pc_send = (cntrl)? pc_send : pc_reg;
	
endmodule