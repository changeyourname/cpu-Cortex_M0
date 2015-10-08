module is_mul_pulse(instruction16_in,
					instruction32_in,
					is32,
					multiple_pulse,
					MM_cond
					);
input [15:0] instruction16_in;
input [31:0] instruction32_in;
input is32;

output multiple_pulse;
output MM_cond;

reg multiple_pulse;

assign MM_cond = ~(	 ((instruction32_in[7:0]>= 8'd5)&(instruction32_in[7:0]<= 8'd9))
					|(instruction32_in[7:0]<= 8'd3)
					|(instruction32_in[7:0]==8'd16)
					|(instruction32_in[7:0]==8'd20)
					);

always@(instruction16_in or is32)begin
	if(is32)begin
		multiple_pulse = 0;
	end
	else begin
		multiple_pulse = 	(instruction16_in[15:12] == 4'b1100)? 1 :
								(instruction16_in[15:12] == 4'b1011)? 
								 ((instruction16_in[10:9] == 2'b10)? 1 : 0) : 0;
	end
end
endmodule