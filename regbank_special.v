module regbank_special(	
		rst,
		clk,
	
		w_N_en,
		w_Z_en,
		w_C_en,
		w_V_en,
		w_epsr_en,
		w_ipsr_en,
		w_primask_en,
		w_control_en,
		
		w_N_in,
		w_Z_in,
		w_C_in,
		w_V_in,
		w_epsr_in,
		w_ipsr_in,
		w_primask_in,
		w_control_in,
		
		r_psr_out,
		r_primask_out,
		r_control_out
		);
	
	input rst, clk;
	input w_N_en;
	input w_Z_en;
	input w_C_en;
	input w_V_en;
	input w_epsr_en;
	input w_ipsr_en;
	input w_primask_en;
	input w_control_en;
	input w_N_in;
	input w_Z_in;
	input w_C_in;
	input w_V_in;
	input w_epsr_in;
	input [5:0] w_ipsr_in;
	input [31:0] w_primask_in;
	input [31:0] w_control_in;
	
	output [31:0] r_psr_out;
	output [31:0] r_primask_out;
	output [31:0] r_control_out;
	
	reg [31:0] psr;
	reg [31:0] primask;
	reg [31:0] control;
	
	assign r_psr_out = psr;
	assign r_primask_out = primask;
	assign r_control_out = control;
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			psr <= 32'd0;
			primask <= 32'd0;
			control <= 32'd0;
		end
		else begin
			psr[31] <= (w_N_en)? w_N_in : psr[31];
			psr[30] <= (w_Z_en)? w_Z_in : psr[30];
			psr[29] <= (w_C_en)? w_C_in : psr[29];
			psr[28] <= (w_V_en)? w_V_in : psr[28];
			psr[24] <= (w_epsr_en)? w_epsr_in : psr[24];
			psr[5:0] <= (w_ipsr_en)? w_ipsr_in : psr[5:0];
			primask <= (w_primask_en)? w_primask_in : primask;
			control <= (w_control_en)? w_control_in : control;
		end
	end
endmodule