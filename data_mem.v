module data_mem(
		clk, 
		addr,
		HSIZE, 
		w_en, 
		write_data, 
		read_data	);

input [31:0] addr;
input clk;

input [2:0] HSIZE ;

input [31:0] write_data;
input w_en;

output [31:0] read_data;

reg [8:0] d_mem [0:1024];

assign read_data= 	(HSIZE==3'b000)?	{24'dx,d_mem[addr]}:
					(HSIZE==3'b001)?	{16'dx,d_mem[addr],d_mem[addr+1]}:
					(HSIZE==3'b010)?	{d_mem[addr],d_mem[addr+1],d_mem[addr+2],d_mem[addr+3]}:
					(HSIZE==3'b011)?		{32'dx}:
											32'dx;
											
											
always@(posedge clk)begin
	if(w_en)begin
		if(HSIZE==3'b000)
			d_mem[addr] <= write_data[7:0];
		else if(HSIZE==3'b001)
			{d_mem[addr],d_mem[addr+1]} <= write_data[15:0];
		else if(HSIZE==3'b010)
			{d_mem[addr],d_mem[addr+1],d_mem[addr+2],d_mem[addr+3]} <= write_data;
	end
end

endmodule


