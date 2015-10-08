`define nop 16'hbf00

module is_32(	clk,
				rst,
				pc,
				multiple,
				list,
				instruction,
				is32,
				instruction_out32,
				instruction_out16,
				pc_real,
				multiple_stable_even
				);
	input clk;
	input rst;
	input multiple;
	input [9:0] list;
	input [31:0] pc;
	input [31:0] instruction;
	
	output is32;
	output [15:0] instruction_out16;
	output [31:0] instruction_out32;
	output [31:0] pc_real;
	output multiple_stable_even;

	reg output_flag;
	reg multiple_stable_even;
	//reg e_o;
	reg [31:0] pc_real;
	reg even32;
	reg odd32;
	reg is32_valid;
	
	reg [15:0] last16;
	
	//reg [15:0] tmp1, tmp2;
	reg [15:0] out16;
	reg [31:0] out32;
	
	assign instruction_out16 = out16;
	assign instruction_out32 = out32;
	
	assign is32 = is32_valid;
	
	always@(posedge rst or posedge clk)begin
		if(rst) begin
			out16 <= 0;
			out32 <= 0;
			last16 <= 0;
			is32_valid <= 0;
			even32 <= 0;
			odd32 <= 0;
			output_flag <= 1;
			pc_real <= 0;
			multiple_stable_even <= 0;
		end
		else if(multiple || (list!=10'd0))begin
			out16 <= `nop;
			is32_valid <= 0;
			pc_real <= pc + 32'd4;
		end
		else begin
			output_flag <= ~output_flag;
			if(odd32)begin
				out32 <= instruction;
				pc_real <= pc + 32'd2;
				is32_valid <= 1;
				odd32 <= 0;
			end
			else if(even32)begin
				out32 <= {last16, instruction[31:16]};
				if(instruction[15:13]==3'b111 && instruction[12:11]!=2'b00)begin
					multiple_stable_even <= 0;
				end
				else begin
					if(instruction[15:12]==4'b1100) begin
						multiple_stable_even <= 1;
					end
					else if(instruction[15:12]==4'b1011) begin
						multiple_stable_even <= (instruction[10:9]==2'b10)? 1 : 0;
					end
					else begin
						multiple_stable_even <= 0;
					end
				end
				pc_real <= pc + 32'd2;
				is32_valid <= 1;
				last16 <= 16'd0;
				even32 <= 0;
			end
			else begin
				pc_real <= pc + 32'd4;
				is32_valid <= 0;
				if(instruction[31:29]==3'b111 && instruction[28:27]!=2'b00)begin
					out16 <= `nop;
					odd32 <= 1;
				end
				else begin
					if(output_flag)begin
						if(instruction[15:13]==3'b111 && instruction[12:11]!=2'b00)begin
							out16 <= instruction[31:16];
							last16 <= instruction[15:0];
						end
						else begin
							out16 <= instruction[31:16];
							if(instruction[15:13]==3'b111 && instruction[12:11]!=2'b00)begin
								multiple_stable_even <= 0;
							end
							else begin
								if(instruction[15:12]==4'b1100) begin
									multiple_stable_even <= 1;
								end
								else if(instruction[15:12]==4'b1011) begin
									multiple_stable_even <= (instruction[10:9]==2'b10)? 1 : 0;
								end
								else begin
									multiple_stable_even <= 0;
								end
							end
						end
					end
					else begin
						if(last16 != 16'd0)begin
							out16 <= `nop;
							even32 <= 1;
						end
						else begin
							if(instruction[15:13]==3'b111 && instruction[12:11]!=2'b00)begin
								out16 <= `nop;
								even32 <= 1;
								last16 <= instruction[15:0];
							end
							else begin
								out16 <= instruction[15:0];
							end
						end
					end
				end
			end
		end
	end
	
	/*always@(posedge rst or posedge clk)begin
		if(rst)begin
			e_o <= 0;
			tmp1 <= 0;
			tmp2 <= 0;
			odd32 <= 0;
			even32 <= 0;
			out16 <= 0;
			out32 <= 0; 
			last16 <= 0;
			is32_valid <= 0;
			pc_real <= 0;
		end 
		else if((multiple == 1) || (list != 10'd0))begin
			e_o <= e_o;
			tmp1 <= 0;
			tmp2 <= 0;
			odd32 <= odd32;
			even32 <= even32;
			out16 <= 0;
			out32 <= 0;
			last16 <= last16;
			is32_valid <= is32_valid;
			pc_real <= pc + 32'd4;
		end
		else begin
			e_o <= ~e_o;
			if(e_o == 0 )begin
				tmp1 <= instruction[31:16];
				tmp2 <= instruction[15:0];
				if((tmp2[15:13] == 3'b111) && (tmp2[12:11] != 2'b00))begin
					out16 <= 0;
					out32 <= 0;
					odd32 <= odd32;
					even32 <= (odd32)? 0 : 1;
					last16 <= tmp2;
					is32_valid <= 0;
					pc_real <= pc + 32'd4;
				end
				else begin
					out16 <= (odd32)? 0 : tmp2;
					out32 <= 0;
					odd32 <= odd32;
					even32 <= 0;
					last16 <= 0;
					is32_valid <= 0;
					pc_real <= pc + 32'd4;
				end
			end
			else begin
				tmp1 <= tmp1;
				tmp2 <= tmp2;
				if((tmp1[15:13] == 3'b111) && (tmp1[12:11] != 2'b00))begin
					out16 <= 0;
					out32 <= (even32)? {last16,tmp1}:{tmp1, tmp2};
					odd32 <= (even32)? 0 : 1;
					even32 <= even32;
					last16 <= 0;
					is32_valid <= 1;
					pc_real <= (even32) ? pc + 32'd2 : pc + 32'd4;
				end
				else begin
					out16 <= (even32)? 0 : tmp1;
					out32 <= (even32)? {last16,tmp1}:0;
					odd32 <= 0;
					even32 <= even32;
					last16 <= 0;
					is32_valid <= (even32)? 1: 0;
					pc_real <= (even32) ? pc + 32'd2 : pc + 32'd4;
				end
			end
		end	
	end*/
endmodule