`include "cpu_top.v"

module tb();
	reg clk, rst;
	cpu_top u_m0(	.clk(clk),
					.rst(rst)
					);
					
	always #100 clk = ~clk;
	
	integer i = 0;
	initial begin
	
	
	/*	u_m0.s1.i_mem.MEM[0] = 8'b1011_1111;//nop
		u_m0.s1.i_mem.MEM[1] = 8'b0000_0000;
		
		u_m0.s1.i_mem.MEM[2] = 8'b0010_0000;//mov(immediate)
		u_m0.s1.i_mem.MEM[3] = 8'd3;
		
		u_m0.s1.i_mem.MEM[4] = 8'b1011_1111;//nop
		u_m0.s1.i_mem.MEM[5] = 8'b0000_0000;
		
		u_m0.s1.i_mem.MEM[6] = 8'b0100_1001;//mov(immediate)
		u_m0.s1.i_mem.MEM[7] = 8'd5;
		
		u_m0.s1.i_mem.MEM[8] = 8'b1011_1111;//nop
		u_m0.s1.i_mem.MEM[9] = 8'b0000_0000;
		
		u_m0.s1.i_mem.MEM[10] = 8'b0100_0001;//ADD
		u_m0.s1.i_mem.MEM[11] = 8'b0100_1000;
		
		u_m0.s1.i_mem.MEM[12] = 8'b1011_1111;//nop
		u_m0.s1.i_mem.MEM[13] = 8'b0000_0000;
		*/
		
		u_m0.s1.i_mem.MEM[i] = 8'b1011_1111;//nop
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0000_0000;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b0010_0000;//mov(immediate)
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'd60;
		i=i+1;
				
		u_m0.s1.i_mem.MEM[i] = 8'b0010_0001;//mov(immediate)
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'd5;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b0010_0010;//mov(immediate)
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'd7;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b0010_0011;//mov(immediate)
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'd9;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b0010_0100;//mov(immediate)
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'd11;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b0010_0101;//mov(immediate)
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'd13;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b0010_0110;//mov(immediate)
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'd15;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b1011_1111;//nop
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0000_0000;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b0100_0001;//ADD
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0100_1000;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b1011_1111;//nop
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0000_0000;
		i=i+1;
				
		u_m0.s1.i_mem.MEM[i] = 8'b0100_0100;//nop
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b1000_0101;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b0100_0001;//ADD
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0100_1000;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b1011_1111;//nop
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0000_0000;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b1011_0100;//POP
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0111_1111;//reglist
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b1011_1111;//nop
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0000_0000;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b1011_1111;//nop
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0000_0000;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b1011_1111;//nop
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0000_0000;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b1011_0100;//POP
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0111_1111;//reglist
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b1011_1111;//nop
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0000_0000;
		i=i+1;
		
		u_m0.s1.i_mem.MEM[i] = 8'b1011_1111;//nop
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0000_0000;
		i=i+1;

		u_m0.s1.i_mem.MEM[i] = 8'b1011_1111;//nop
		i=i+1;
		u_m0.s1.i_mem.MEM[i] = 8'b0000_0000;
		i=i+1;
		
		rst = 1;
		clk = 0;
		
		#250 rst = 0;
		#10000 $finish;
		
	end
endmodule