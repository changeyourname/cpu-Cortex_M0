module instruction_mem(clk, pc, instruction);
	
	input clk;
	input [31:0] pc;
	output [31:0] instruction;

	reg [31:0] ins;
	reg [7:0] MEM [0:2047];
	
	assign instruction = ins;
	
	always@(negedge clk)begin
		ins = {MEM[pc], MEM[pc+1], MEM[pc+2], MEM[pc+3]};
	end
	
endmodule