module regbank(	rst, 
				clk,
				push_pop,
				addr_n,
				addr_m,
				addr_i,
				addr_t_read,
				
				w_reg_addr,
				w_reg_en,
				w_reg_in,
				
				Rn,
				Rm,
				Rt,
				Ri,
				
				w_pc_in,
				r_pc_out,
				
				is_mul_pulse,//is_mul_pulse
				
				list_from_decode,
				list_from_list_count,
				list,
				cntrl_out
				);
	input rst;
	input clk;
	input [1:0] push_pop;
	
	input[3:0] w_reg_addr;
	input w_reg_en;
	input[31:0] w_reg_in;
	
	input is_mul_pulse;
	input[9:0] list_from_decode;
	input[9:0] list_from_list_count;
	
	input[3:0] addr_n;
	input[3:0] addr_m;
	input[3:0] addr_i;
	input[3:0] addr_t_read;
	
	input [31:0] w_pc_in;
	
	output[31:0] Rn;
	output[31:0] Rm;
	output[31:0] Rt;
	output[31:0] Ri;
	output[31:0] r_pc_out;
	output [9:0] list;
	output cntrl_out;
	
	reg cntrl;
	reg [9:0] list;
	reg [31:0] register [0:15];

	
	assign Rn = register[addr_n];
	assign Rm = register[addr_m];
	assign Ri = register[addr_i];
	assign Rt = register[addr_t_read];
	assign cntrl_out = cntrl;
	assign r_pc_out= register[15];
	
	always@(posedge rst or posedge clk)begin
		if(rst)begin
			cntrl <= 0;
		end
		else begin
			cntrl <= ~cntrl;
		end
	end
		
	always@(posedge rst or posedge clk)begin
		if(rst) begin
			register[0] <= 32'd0;
			register[1] <= 32'd0;
			register[2] <= 32'd0;
			register[3] <= 32'd0;
			register[4] <= 32'd0;
			register[5] <= 32'd0;
			register[6] <= 32'd0;
			register[7] <= 32'd0;
			register[8] <= 32'd0;
			register[9] <= 32'd0;
			register[10] <= 32'd0;
			register[11] <= 32'd0;
			register[12] <= 32'd0;
			register[13] <= 32'd0;
			register[14] <= 32'd0;
			register[15] <= 32'd0;
		end
		else begin
			if(w_reg_en)begin
				case(w_reg_addr)
					4'd15 : register[15] <= w_reg_in;
					default : begin
						register[w_reg_addr] <= w_reg_in;
						register[15] <= w_pc_in ;
					end
				endcase
			end
			else begin
				register[15] <= w_pc_in ;
			end
		end
	end
	
	always@(posedge rst or posedge clk)begin
		if(rst) begin
			list <= 10'd0;
		end
		else begin
			if(is_mul_pulse)begin 
				list <= list_from_decode;
			end else 
				list <= list_from_list_count;
		end
	end
	
endmodule