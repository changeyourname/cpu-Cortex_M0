module list_addr_delay(
		rst,
		clk,
		
		multiple_vector,		
		multiple_pulse,
		multiple_stable,
		list,

		dm_addr_in,
		dm_addr_out,
		
		reg_addr_in,
		reg_addr_out,
		
		multiple_pulse_delay,
		multiple_vector_delay,
		w_mem_en_from_multiple,
		w_reg_en_from_multiple
);

input rst;
input clk;
input [1:0] multiple_vector;	// ins16[12:11] (indicates it is pop, push, LDM or STM)

input multiple_pulse;
input multiple_stable;

input [31:0] dm_addr_in;
input [3:0] reg_addr_in;
input [9:0] list;

output [31:0] dm_addr_out;
output [3:0] reg_addr_out;

output multiple_pulse_delay;
output [1:0]multiple_vector_delay;
output w_mem_en_from_multiple;
output w_reg_en_from_multiple;

reg multiple_pulse_delay;
reg [31:0] dm_addr_out;
reg [3:0] reg_addr_out;
reg [1:0] multiple_vector_delay;
reg w_mem_en_from_multiple;
reg w_reg_en_from_multiple;


always@(posedge rst or posedge clk)begin
	if(rst)begin
		multiple_pulse_delay <= 0;
		multiple_vector_delay<= 0;
	end else begin
		multiple_pulse_delay <= multiple_pulse;
		multiple_vector_delay<= multiple_vector;
	end
end

always@(posedge rst or posedge clk)begin
	if(rst)begin
		dm_addr_out <= 0;
		reg_addr_out <= 0;
	end else begin
		dm_addr_out <= dm_addr_in;
		reg_addr_out <= reg_addr_in;
	end
end

always@(posedge rst or posedge clk)begin
	if(rst)
		w_mem_en_from_multiple <= 0;
	else if(multiple_pulse_delay)
		w_mem_en_from_multiple <= ~ multiple_vector_delay[0];
	else if(multiple_stable&(|list))
		w_mem_en_from_multiple <= w_mem_en_from_multiple;	
	else
		w_mem_en_from_multiple <= 0;
end

always@(posedge rst or posedge clk)begin
	if(rst)
		w_reg_en_from_multiple <= 0;
	else if(multiple_pulse_delay)
		w_reg_en_from_multiple <= multiple_vector_delay[0];
	else if(multiple_stable&(|list))
		w_reg_en_from_multiple <= w_reg_en_from_multiple;	
	else
		w_reg_en_from_multiple <= 0;
end

endmodule