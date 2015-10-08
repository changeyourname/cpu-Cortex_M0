module list_count(
		list_in,
		next_list, 
		dm_addr_in, 
		dm_addr_out, 
		reg_addr_out,

		multiple_pulse_delay,
		multiple_vector_delay,
		Rn,
		bit_count
		);
		
	input [9:0] list_in;
	input [31:0] dm_addr_in;
	
	input multiple_pulse_delay;
	input [1:0] multiple_vector_delay;
	
	input [31:0] Rn;
	input [31:0] bit_count;
	
	output [9:0] next_list;
	output [31:0] dm_addr_out;
	output [3:0] reg_addr_out;
			
	wire bit15or14;
	wire [9:0] bit_stand;
		
	assign dm_addr_out = 
		(multiple_pulse_delay)? 
		((multiple_vector_delay==2'b10)? Rn- bit_count:	Rn )//push: SP(n==13) - 4*bit_count
		: dm_addr_in + 32'd4;
	
	assign list_out =
		(multiple_pulse_delay)? list_in : next_list;
			
	assign bit_stand = list_in - next_list;
	assign bit15or14=(|bit_stand[9:8]);
	
	assign reg_addr_out[3]=(bit15or14);
	assign reg_addr_out[2]=(bit15or14| (|bit_stand[7:4]));
	assign reg_addr_out[1]=(bit15or14| (|bit_stand[7:6])|(|bit_stand[3:2]));
	assign reg_addr_out[0]=(bit_stand[9]| bit_stand[7]|bit_stand[5]|bit_stand[3]|bit_stand[1]);

	assign next_list[0]= 1'b0;
	assign next_list[1]= list_in[1]& ((list_in[0]));
	assign next_list[2]= list_in[2]& ((|list_in[1:0]));
	assign next_list[3]= list_in[3]& ((|list_in[2:0]));
	assign next_list[4]= list_in[4]& ((|list_in[3:0]));
	assign next_list[5]= list_in[5]& ((|list_in[4:0]));
	assign next_list[6]= list_in[6]& ((|list_in[5:0]));
	assign next_list[7]= list_in[7]& ((|list_in[6:0]));
	assign next_list[8]= list_in[8]& ((|list_in[7:0]));
	assign next_list[9]= list_in[9]& ((|list_in[8:0]));
		
endmodule