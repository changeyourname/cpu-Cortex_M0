module is_mul_stable_odd(	instruction_from_mem,
							is32_from_stage1,
							multiple_stable_odd
							);

input [31:0] instruction_from_mem;
input is32_from_stage1;
output multiple_stable_odd;

reg multiple_stable_odd;


always@(instruction_from_mem or is32_from_stage1)begin
	if(is32_from_stage1)begin
		multiple_stable_odd = 0;
	end
	else begin
		multiple_stable_odd = 	(instruction_from_mem[31:28] == 4'b1100)? 1 :
									(instruction_from_mem[31:28] == 4'b1011)? 
									 ((instruction_from_mem[26:25] == 2'b10)? 1 : 0) : 0;
	end
end
endmodule