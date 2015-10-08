`define S1_RN 3'd0
`define S1_RM 3'd1
`define S1_NOT_RN 3'd2
`define S1_PC_ALIGN 3'd3
`define S1_PC 3'd4

`define S2_RM 3'd0
`define S2_IMM32 3'd1
`define S2_NOT_RM 3'd2
`define S2_NOT_IMM32 3'd3
`define S2_BIT_COUNT 3'd4
`define S2_NOT_BIT_COUNT 3'd5

`define SC_0 2'd0
`define SC_1 2'd1
`define SC_APSR 2'd2

`define ADC 5'd0
`define AND 5'd1
`define OR 5'd2
`define EOR 5'd3
`define LSL 5'd4
`define LSR 5'd5
`define ASR 5'd6
`define ROR 5'd7
`define MUL 5'd8
`define SRC1 5'd9
`define SRC2 5'd10
`define REV 5'd11
`define REV16 5'd12
`define REVSH 5'd13
`define SXTB 5'd14
`define SXTH 5'd15
`define UXTB 5'd16
`define UXTH 5'd17

//存回Reg之addr (w_reg_addr_src)
`define S6_addr_d 3'd0
`define S6_addr_t 3'd1
`define S6_addr_i 3'd2//addr_i 來自list_count 的 reg_addr_out
`define S6_addr_n 3'd3	//Rn for LDM STM
`define S6_13 3'd4	//SP for pop push

//存還Reg之data (w_reg_data_src)
`define S8_ALU_RESULT 3'd0
`define S8_MEM_RESULT 3'd1
`define S8_RN_plus_4BITCOUNT 3'd2
`define S8_SP_plus_4BITCOUNT 3'd3
`define S8_SP_minus_4BITCOUNT 3'd4
`define S8_FOR_BLX 3'd5
`define S8_FOR_BL 3'd6


//要讀或寫MEM之addr (mem_addr_src) (讀寫同一條)
`define S4_RN_RM 2'd0
`define S4_RN_IMM32 2'd1
`define S4_PC_ALIGN_IMM32 2'd2
`define S4_addr_dm_out 2'd3

//讀寫MEM之data時, 是 8bit, 16bit, 32bit? (HSIZE)
`define HSIZE_8bit 3'b000
`define HSIZE_16bit 3'b001
`define HSIZE_32bit 3'b010
//`define HSIZE_8bit 3'b000

//讀MEM之data時, 要做 ZeroExtend還是SignExtend (r_mem_data_src)
`define S5_ZEROEXTEND 1'd0
`define S5_SIGNEXTEND 1'd1


module addr_decoder(instruction16,
					instruction32,
					MM_cond,
					is32,
					addr_m,
					addr_n,
					addr_d,
					addr_t,
					imm32,
					reglist,
					option,
					SYSm,
					push_pop,
					w_N_en,
					w_Z_en,
					w_C_en,
					w_V_en,
					w_reg_en,
					cond,
					branch,
					alu_src1_choose,
					alu_src2_choose,
					alu_src_cin_choose,
					alu_op,
					
					w_reg_addr_src,
					w_reg_data_src,
					
					w_mem_en,
					mem_addr_src,
					r_mem_data_src,
					HSIZE,
					
					udf, /////undefined
					upd);/////unpredictable

	input [15:0] instruction16;
	input [31:0] instruction32;
	input is32;
	input MM_cond;
	
	output [3:0] addr_m;
	output [3:0] addr_n;
	output [3:0] addr_d;
	output [3:0] addr_t;
	output [31:0] imm32;
	output [9:0] reglist;
	output [3:0] option;
	output [7:0] SYSm;
	output udf;
	output upd;
	output [1:0] push_pop;
	output w_N_en;
	output w_Z_en;
	output w_C_en;
	output w_V_en;
	output w_reg_en;
	output branch;
	output [3:0] cond;
	
	output [2:0] alu_src1_choose;
	output [2:0] alu_src2_choose;
	output [1:0] alu_src_cin_choose;
	output [4:0] alu_op;
	
	output [2:0] w_reg_addr_src;
	output [2:0] w_reg_data_src;
			
	output w_mem_en;
	output [1:0] mem_addr_src;
	output [2:0] HSIZE;
	output r_mem_data_src;

		
	reg [3:0] addr_m;
	reg [3:0] addr_n;
	reg [3:0] addr_d;
	reg [3:0] addr_t;
	reg [31:0] imm32;
	reg [9:0] reglist;
	reg [3:0] option;
	reg [7:0] SYSm;
	reg udf;
	reg upd;
	reg [1:0] push_pop;
	reg w_N_en;
	reg w_Z_en;
	reg w_C_en;
	reg w_V_en;
	reg w_reg_en;
	reg branch;
	reg [3:0] cond;

	reg [2:0] alu_src1_choose;
	reg [2:0] alu_src2_choose;
	reg [1:0] alu_src_cin_choose;
	reg [4:0] alu_op;
	
	reg	[2:0] w_reg_addr_src;
	reg	[2:0] w_reg_data_src;
			
	reg w_mem_en;
	reg	[1:0] mem_addr_src;
	reg	[2:0] HSIZE;
	reg	r_mem_data_src;	
	
	always@(instruction16)begin
		if(is32==0)begin
			if(instruction16[15:12]==4'b1101)begin
				cond <= instruction16[11:8];
			end
			else begin
				cond <= 4'b1110;
			end
			if(instruction16[15:12]==4'b1011)begin
				push_pop[1] <= (instruction16[11:9]==3'b010)? 1 : 0;
				push_pop[0] <= (instruction16[11:9]==3'b110)? 1 : 0;
			end
			else begin
				push_pop <= 2'd0;
			end
		end
		else begin
			cond <= 4'b1110;
			push_pop <= 2'd0;
		end
	end
	
	always@(instruction16 or instruction32)begin
		if(is32==0)begin //////////16 bit instruction
			option <= 4'd0;
			SYSm   <= 8'd0;
			
			case(instruction16[15:14])
				2'b00:begin
					case(instruction16[13:11])
						3'b000:begin //////LSLi + MOV
							addr_m <= {1'd0, instruction16[5:3]};
							addr_n <= 4'd0;
							addr_d <= {1'd0, instruction16[2:0]};
							addr_t <= 4'd0;
							imm32  <= {27'd0, instruction16[10:6]};
							reglist<= 10'd0;
							udf    <= 0;
							upd    <= 0;
							w_N_en <=1;
							w_Z_en <=1;
							w_C_en <=(instruction16[10:6]==5'd0)? 0 : 1;
							w_V_en <=0;
							w_reg_en <= 1;
							branch <= 0;
							alu_src1_choose <= `S1_RM;
							alu_src2_choose <= `S2_IMM32;
							alu_src_cin_choose <= `SC_APSR;
							alu_op <=(instruction16[10:6]==5'd0)?`SRC1: `LSL;
							w_reg_addr_src <= `S6_addr_d;
							w_reg_data_src <= `S8_ALU_RESULT;
							w_mem_en <= 0;
							mem_addr_src <= 0;
							HSIZE <= 0;
							r_mem_data_src <= 0;					
							
						end
						3'b001:begin /////LSRi
							addr_m <= {1'd0, instruction16[5:3]};
							addr_n <= 4'd0;
							addr_d <= {1'd0, instruction16[2:0]};
							addr_t <= 4'd0;
							imm32  <= {27'd0, instruction16[10:6]};
							reglist<= 10'd0;
							udf    <= 0;
							upd    <= 0;
							w_N_en <=1;
							w_Z_en <=1;
							w_C_en <=1;
							w_V_en <=0;
							w_reg_en <= 1;
							branch <= 0;
							alu_src1_choose <= `S1_RM;
							alu_src2_choose <= `S2_IMM32;
							alu_src_cin_choose <= `SC_APSR;
							alu_op <= `LSR;
							w_reg_addr_src <= `S6_addr_d;
							w_reg_data_src <= `S8_ALU_RESULT;	
							w_mem_en <= 0;								
							mem_addr_src <= 0;
							HSIZE <= 0;
							r_mem_data_src <= 0;					
							
						end
						3'b010:begin /////ASRi
							addr_m <= {1'd0, instruction16[5:3]};
							addr_n <= 4'd0;
							addr_d <= {1'd0, instruction16[2:0]};
							addr_t <= 4'd0;
							imm32  <= {27'd0, instruction16[10:6]};
							reglist<= 10'd0;
							udf    <= 0;
							upd    <= 0;
							w_N_en <=1;
							w_Z_en <=1;
							w_C_en <=1;
							w_V_en <=0;
							w_reg_en <= 1;
							branch <= 0;
							alu_src1_choose <= `S1_RM;
							alu_src2_choose <= `S2_IMM32;
							alu_src_cin_choose <= `SC_APSR;
							alu_op <= `ASR;
							w_reg_addr_src <= `S6_addr_d;
							w_reg_data_src <= `S8_ALU_RESULT;
							w_mem_en <= 0;									
							mem_addr_src <= 0;
							HSIZE <= 0;
							r_mem_data_src <= 0;					
							
						end
						3'b011:begin
							case(instruction16[10:9])
							2'b00:begin /////ADDr
								addr_m <= {1'd0, instruction16[8:6]};
								addr_n <= {1'd0, instruction16[5:3]};
								addr_d <= {1'd0, instruction16[2:0]};
								addr_t <= 4'd0;
								imm32  <= 32'd0;
								reglist<= 10'd0;
								udf    <= 0;
								upd    <= 0;
								w_N_en <=1;
								w_Z_en <=1;
								w_C_en <=1;
								w_V_en <=1;
								w_reg_en <= 1;
								branch <= 0;
								alu_src1_choose <= `S1_RN;
								alu_src2_choose <= `S2_RM;
								alu_src_cin_choose <= `SC_0;
								alu_op <= `ADC;
								w_reg_addr_src <= `S6_addr_d;
								w_reg_data_src <= `S8_ALU_RESULT;	
								w_mem_en <= 0;								
								mem_addr_src <= 0;
								HSIZE <= 0;
								r_mem_data_src <= 0;					
								
							end
							2'b01:begin /////SUBr
								addr_m <= {1'd0, instruction16[8:6]};
								addr_n <= {1'd0, instruction16[5:3]};
								addr_d <= {1'd0, instruction16[2:0]};
								addr_t <= 4'd0;
								imm32  <= 32'd0;
								reglist<= 10'd0;
								udf    <= 0;
								upd    <= 0;
								w_N_en <=1;
								w_Z_en <=1;
								w_C_en <=1;
								w_V_en <=1;
								w_reg_en <= 1;
								branch <= 0;
								alu_src1_choose <= `S1_RN;
								alu_src2_choose <= `S2_NOT_RM;
								alu_src_cin_choose <= `SC_1;
								alu_op <= `ADC;
								w_reg_addr_src <= `S6_addr_d;
								w_reg_data_src <= `S8_ALU_RESULT;	
								w_mem_en <= 0;															
								mem_addr_src <= 0;
								HSIZE <= 0;
								r_mem_data_src <= 0;					
								
							end
							2'b10:begin /////ADDi_3bit
								addr_m <= 4'd0;
								addr_n <= {1'd0, instruction16[5:3]};
								addr_d <= {1'd0, instruction16[2:0]};
								addr_t <= 4'd0;
								imm32  <= {29'd0, instruction16[8:6]};
								reglist<= 10'd0;
								udf    <= 0;
								upd    <= 0;
								w_N_en <=1;
								w_Z_en <=1;
								w_C_en <=1;
								w_V_en <=1;
								w_reg_en <= 1;
								branch <= 0;
								alu_src1_choose <= `S1_RN;
								alu_src2_choose <= `S2_IMM32;
								alu_src_cin_choose <= `SC_0;
								alu_op <= `ADC;
								w_reg_addr_src <= `S6_addr_d;
								w_reg_data_src <= `S8_ALU_RESULT;
								w_mem_en <= 0;															
								mem_addr_src <= 0;
								HSIZE <= 0;
								r_mem_data_src <= 0;					
								
							end
							2'b11:begin /////SUBi_3bit
								addr_m <= 4'd0;
								addr_n <= {1'd0, instruction16[5:3]};
								addr_d <= {1'd0, instruction16[2:0]};
								addr_t <= 4'd0;
								imm32  <= {29'd0, instruction16[8:6]};
								reglist<= 10'd0;
								udf    <= 0;
								upd    <= 0;
								w_N_en <=1;
								w_Z_en <=1;
								w_C_en <=1;
								w_V_en <=1;
								w_reg_en <= 1;
								branch <= 0;
								alu_src1_choose <= `S1_RN;
								alu_src2_choose <= `S2_NOT_IMM32;
								alu_src_cin_choose <= `SC_1;
								alu_op <= `ADC;
								w_reg_addr_src <= `S6_addr_d;
								w_reg_data_src <= `S8_ALU_RESULT;	
								w_mem_en <= 0;															
								mem_addr_src <= 0;
								HSIZE <= 0;
								r_mem_data_src <= 0;					
								
							end
							endcase
						end
						3'b100:begin /////MOVi
							addr_m <= 4'd0;
							addr_n <= 4'd0;
							addr_d <= {1'd0, instruction16[10:8]};
							addr_t <= 4'd0;
							imm32  <= {24'd0, instruction16[7:0]};
							reglist<= 10'd0;
							udf    <= 0;
							upd    <= 0;
							w_N_en <=1;
							w_Z_en <=1;
							w_C_en <=1;
							w_V_en <=0;
							w_reg_en <= 1;
							branch <= 0;
							alu_src1_choose <= `S1_RN;//x
							alu_src2_choose <= `S2_IMM32;
							alu_src_cin_choose <= `SC_APSR;
							alu_op <= `SRC2;
							w_reg_addr_src <= `S6_addr_d;
							w_reg_data_src <= `S8_ALU_RESULT;		
							w_mem_en <= 0;														
							mem_addr_src <= 0;
							HSIZE <= 0;
							r_mem_data_src <= 0;					
							
						end
						3'b101:begin /////CMPi
							addr_m <= 4'd0;
							addr_n <= {1'd0, instruction16[10:8]};
							addr_d <= 4'd0;
							addr_t <= 4'd0;
							imm32  <= {24'd0, instruction16[7:0]};
							reglist<= 10'd0;
							udf    <= 0;
							upd    <= 0;
							w_N_en <=1;
							w_Z_en <=1;
							w_C_en <=1;
							w_V_en <=1;
							w_reg_en <= 0;
							branch <= 0;
							alu_src1_choose <= `S1_RN;
							alu_src2_choose <= `S2_NOT_IMM32;
							alu_src_cin_choose <= `SC_1;
							alu_op <= `ADC;
							w_reg_addr_src <= 0;
							w_reg_data_src <= 0;			
							w_mem_en <= 0;													
							mem_addr_src <= 0;
							HSIZE <= 0;
							r_mem_data_src <= 0;					
							
						end
						3'b110:begin /////ADDi_8bit
							addr_m <= 4'd0;
							addr_n <= {1'd0, instruction16[10:8]};
							addr_d <= {1'd0, instruction16[10:8]};
							addr_t <= 4'd0;
							imm32  <= {24'd0, instruction16[7:0]};
							reglist<= 10'd0;
							udf    <= 0;
							upd    <= 0;
							w_N_en <=1;
							w_Z_en <=1;
							w_C_en <=1;
							w_V_en <=1;
							w_reg_en <= 1;
							branch <= 0;
							alu_src1_choose <= `S1_RN;
							alu_src2_choose <= `S2_IMM32;
							alu_src_cin_choose <= `SC_0;
							alu_op <= `ADC;
							w_reg_addr_src <= `S6_addr_d;
							w_reg_data_src <= `S8_ALU_RESULT;		
							w_mem_en <= 0;														
							mem_addr_src <= 0;
							HSIZE <= 0;
							r_mem_data_src <= 0;					
							
						end
						3'b111:begin /////SUBi_8bit
							addr_m <= 4'd0;
							addr_n <= {1'd0, instruction16[10:8]};
							addr_d <= {1'd0, instruction16[10:8]};
							addr_t <= 4'd0;
							imm32  <= {24'd0, instruction16[7:0]};
							reglist<= 10'd0;
							udf    <= 0;
							upd    <= 0;
							w_N_en <=1;
							w_Z_en <=1;
							w_C_en <=1;
							w_V_en <=1;
							w_reg_en <= 1;
							branch <= 0;
							alu_src1_choose <= `S1_RN;
							alu_src2_choose <= `S2_NOT_IMM32;
							alu_src_cin_choose <= `SC_1;
							alu_op <= `ADC;
							w_reg_addr_src <= `S6_addr_d;
							w_reg_data_src <= `S8_ALU_RESULT;	
							w_mem_en <= 0;															
							mem_addr_src <= 0;
							HSIZE <= 0;
							r_mem_data_src <= 0;					
							
						end
					endcase
				end
				2'b01:begin
					if(instruction16[13]==0)begin
						if(instruction16[12]==0)begin
							if(instruction16[11]==0)begin
								if(instruction16[10]==0)begin /////Data processing
									case(instruction16[9:6])
										4'b0000:begin /////ANDr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= {1'd0, instruction16[2:0]};
											addr_d <= {1'd0, instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=0;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_RM;
											alu_src_cin_choose <= `SC_APSR;
											alu_op <= `AND;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;	
											w_mem_en <= 0;															
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b0001:begin /////EORr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= {1'd0, instruction16[2:0]};
											addr_d <= {1'd0, instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=0;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_RM;
											alu_src_cin_choose <= `SC_APSR;
											alu_op <= `EOR;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;	
											w_mem_en <= 0;														
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b0010:begin /////LSLr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= {1'd0, instruction16[2:0]};
											addr_d <= {1'd0, instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=0;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_RM;
											alu_src_cin_choose <= `SC_APSR;
											alu_op <= `LSL;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;	
											w_mem_en <= 0;														
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b0011:begin /////LSRr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= {1'd0, instruction16[2:0]};
											addr_d <= {1'd0, instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=0;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_RM;
											alu_src_cin_choose <= `SC_APSR;
											alu_op <= `LSR;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;	
											w_mem_en <= 0;														
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b0100:begin /////ASRr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= {1'd0, instruction16[2:0]};
											addr_d <= {1'd0, instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=0;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_RM;
											alu_src_cin_choose <= `SC_APSR;
											alu_op <= `ASR;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;		
											w_mem_en <= 0;													
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b0101:begin /////ADCr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= {1'd0, instruction16[2:0]};
											addr_d <= {1'd0, instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=1;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_RM;
											alu_src_cin_choose <= `SC_APSR;
											alu_op <= `ADC;
										end
										4'b0110:begin /////SBCr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= {1'd0, instruction16[2:0]};
											addr_d <= {1'd0, instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=1;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_NOT_RM;
											alu_src_cin_choose <= `SC_1;
											alu_op <= `ADC;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;		
											w_mem_en <= 0;													
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b0111:begin /////RORr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= {1'd0, instruction16[2:0]};
											addr_d <= {1'd0, instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=0;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_RM;
											alu_src_cin_choose <= `SC_APSR;
											alu_op <= `ROR;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;		
											w_mem_en <= 0;													
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b1000:begin /////TSTr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= {1'd0, instruction16[2:0]};
											addr_d <= 4'd0;
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=0;
											w_reg_en <= 0;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_RM;
											alu_src_cin_choose <= `SC_APSR;
											alu_op <= `AND;
											w_reg_addr_src <= 0;
											w_reg_data_src <= 0;				
											w_mem_en <= 0;											
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b1001:begin /////RSBi
											addr_m <= 4'd0;
											addr_n <= {1'd0, instruction16[5:3]};
											addr_d <= {1'd0, instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=1;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_NOT_RN;
											alu_src2_choose <= `S2_IMM32;
											alu_src_cin_choose <= `SC_1;
											alu_op <= `ADC;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;	
											w_mem_en <= 0;					
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b1010:begin /////CMPr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= {1'd0, instruction16[2:0]};
											addr_d <= 4'd0;
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=1;
											w_reg_en <= 0;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_NOT_RM;
											alu_src_cin_choose <= `SC_1;
											alu_op <= `ADC;
											w_reg_addr_src <= 0;
											w_reg_data_src <= 0;			
											w_mem_en <= 0;												
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b1011:begin /////CMNr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= {1'd0, instruction16[2:0]};
											addr_d <= 4'd0;
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=1;
											w_reg_en <= 0;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_RM;
											alu_src_cin_choose <= `SC_0;
											alu_op <= `ADC;
											w_reg_addr_src <= 0;
											w_reg_data_src <= 0;			
											w_mem_en <= 0;												
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b1100:begin /////ORRr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= {1'd0, instruction16[2:0]};
											addr_d <= {1'd0, instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=0;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_RM;
											alu_src_cin_choose <= `SC_APSR;
											alu_op <= `OR;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;		
											w_mem_en <= 0;													
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b1101:begin /////MUL
											addr_m <= {1'd0, instruction16[2:0]};
											addr_n <= {1'd0, instruction16[5:3]};
											addr_d <= {1'd0, instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=0;
											w_V_en <=0;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_RM;
											alu_src_cin_choose <= `SC_0;
											alu_op <= `MUL;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;			
											w_mem_en <= 0;												
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b1110:begin /////BICr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= {1'd0, instruction16[2:0]};
											addr_d <= {1'd0, instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=0;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_NOT_RM;
											alu_src_cin_choose <= `SC_APSR;
											alu_op <= `AND;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;		
											w_mem_en <= 0;													
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b1111:begin /////MVNr
											addr_m <= {1'd0, instruction16[5:3]};
											addr_n <= 4'd0;
											addr_d <= {1'd0, instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=1;
											w_Z_en <=1;
											w_C_en <=1;
											w_V_en <=0;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_RN;//x
											alu_src2_choose <= `S2_NOT_RM;
											alu_src_cin_choose <= `SC_0;//x
											alu_op <= `SRC2;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;	
											w_mem_en <= 0;											
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
									endcase
								end
								else begin /////Special data instructions and branch and exchange
									case(instruction16[9:8])
										2'b00:begin
											addr_d <= {instruction16[7], instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											w_N_en <=0;
											w_Z_en <=0;
											w_C_en <=0;
											w_V_en <=0;
											w_reg_en <= 1;
											if({instruction16[7], instruction16[2:0]}==4'd15) begin
												branch <= 1;
												w_reg_en <= 0;
											end
											else begin
												branch <= 0;
												w_reg_en <= 1;
											end
											if((instruction16[6:3]==4'd13) || ({instruction16[7], instruction16[2:0]}==4'd13))begin //ADD (SP plus register)
												if(instruction16[6:3] == 4'd13)begin // Encoding T1
													addr_m <= {instruction16[7], instruction16[2:0]};
													addr_n <= instruction16[6:3];
												end
												else begin // Encoding T2
													addr_m <= instruction16[6:3];
													addr_n <= {instruction16[7], instruction16[2:0]};
												end
												upd <= 0;
											end
											else begin //ADDr
												addr_n <= {instruction16[7], instruction16[2:0]};
												addr_m <= instruction16[6:3];
												if(instruction16[6:3]==15 && {instruction16[7], instruction16[2:0]}==15)
													upd <= 1;
												else
													upd <= 0;
											end
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_RM;
											alu_src_cin_choose <= `SC_0;
											alu_op <= `ADC;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;		
											w_mem_en <= 0;													
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										2'b01:begin
											if(instruction16[7:6]==2'd0)begin //unpredictable
												addr_m <= 4'd0;
												addr_n <= 4'd0;
												addr_d <= 4'd0;
												addr_t <= 4'd0;
												imm32  <= 32'd0;
												reglist<= 10'd0;
												udf    <= 0;
												upd    <= 1;
												w_N_en <=0;
												w_Z_en <=0;
												w_C_en <=0;
												w_V_en <=0;
												w_reg_en <= 0;
												branch <= 0;
												alu_src1_choose <= 0;
												alu_src2_choose <= 0;
												alu_src_cin_choose <= 0;
												alu_op <= 0;
												w_reg_addr_src <= 0;
												w_reg_data_src <= 0;		
												w_mem_en <= 0;													
												mem_addr_src <= 0;
												HSIZE <= 0;
												r_mem_data_src <= 0;					
												
											end
											else begin //CMPr
												addr_m <= instruction16[6:3];
												addr_n <= {instruction16[7], instruction16[2:0]};
												addr_d <= 4'd0;
												addr_t <= 4'd0;
												imm32  <= 32'd0;
												reglist<= 10'd0;
												udf    <= 0;
												if({instruction16[7], instruction16[2:0]}<4'd8 && instruction16[6:3]<4'd8)
													upd <= 1;
												else if({instruction16[7], instruction16[2:0]}==4'd15 || instruction16[6:3]==4'd15)
													upd <= 1;
												else
													upd <= 0;
												w_N_en <=1;
												w_Z_en <=1;
												w_C_en <=1;
												w_V_en <=1;
												w_reg_en <= 0;
												branch <= 0;
												alu_src1_choose <= `S1_RN;
												alu_src2_choose <= `S2_NOT_RM;
												alu_src_cin_choose <= `SC_1;
												alu_op <= `ADC;
												w_reg_addr_src <= 0;
												w_reg_data_src <= 0;			
												w_mem_en <= 0;										
												mem_addr_src <= 0;
												HSIZE <= 0;
												r_mem_data_src <= 0;					
												
											end
										end
										2'b10:begin /////MOVr
											addr_m <= instruction16[6:3];
											addr_n <= 4'd0;
											addr_d <= {instruction16[7], instruction16[2:0]};
											addr_t <= 4'd0;
											imm32  <= 32'd0;
											reglist<= 10'd0;
											udf    <= 0;
											upd    <= 0;
											w_N_en <=0;
											w_Z_en <=0;
											w_C_en <=0;
											w_V_en <=0;
											if({instruction16[7], instruction16[2:0]} == 4'd15) begin
												branch <= 1;
												w_reg_en <= 0;
											end
											else begin
												branch <= 0;
												w_reg_en <= 1;
											end
											alu_src1_choose <= `S1_RM;
											alu_src2_choose <= 0;//x
											alu_src_cin_choose <= 0;//x
											alu_op <= `SRC1;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;		
											w_mem_en <= 0;											
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										2'b11:begin
											if(instruction16[7]==0)begin /////BX
												addr_m <= instruction16[6:3];
												addr_n <= 4'd0;
												addr_d <= 4'd0;
												addr_t <= 4'd0;
												imm32  <= 32'd0;
												reglist<= 10'd0;
												udf    <= 0;
												if(instruction16[6:3]==4'd15)
													upd <= 1;
												else
													upd <= 0;
												w_N_en <=0;
												w_Z_en <=0;
												w_C_en <=0;
												w_V_en <=0;
												w_reg_en <= 0;
												branch <= 1;
												alu_src1_choose <= `S1_RM;
												alu_src2_choose <= 0;//x
												alu_src_cin_choose <= 0;//x
												alu_op <= `SRC1;
												w_reg_addr_src <= 0;
												w_reg_data_src <= 0;		
												w_mem_en <= 0;														
												mem_addr_src <= 0;
												HSIZE <= 0;
												r_mem_data_src <= 0;					
												
											end
											else begin /////BLXr
												addr_m <= instruction16[6:3];
												addr_n <= 4'd0;
												addr_d <= 4'd14;// discussion modify to LR
												addr_t <= 4'd0;
												imm32  <= 32'd0;
												reglist<= 10'd0;
												udf    <= 0;
												if(instruction16[6:3]==4'd15)
													upd <= 1;
												else
													upd <= 0;
												w_N_en <=0;
												w_Z_en <=0;
												w_C_en <=0;
												w_V_en <=0;
												w_reg_en <= 1;// discussion modify to write for LR
												branch <= 1;
												alu_src1_choose <= `S1_RM;
												alu_src2_choose <= 0;//x
												alu_src_cin_choose <= 0;//x
												alu_op <= `SRC1;
												w_reg_addr_src <= `S6_addr_d;
												w_reg_data_src <= `S8_FOR_BLX;		
												w_mem_en <= 0;											
												mem_addr_src <= 0;
												HSIZE <= 0;
												r_mem_data_src <= 0;					
												
											end
										end
									endcase
								end
							end
							else begin /////LDR(literal)
								addr_m <= 4'd0;
								addr_n <= 4'd0;
								addr_d <= 4'd0;
								addr_t <= {1'd0, instruction16[10:8]};
								imm32  <= {22'd0, instruction16[7:0], 2'd0};
								reglist<= 10'd0;
								udf    <= 0;
								upd    <= 0;
								w_N_en <=0;
								w_Z_en <=0;
								w_C_en <=0;
								w_V_en <=0;
								w_reg_en <= 1;
								branch <= 0;
								alu_src1_choose <= 0;//x
								alu_src2_choose <= 0;//x
								alu_src_cin_choose <= 0;//x
								alu_op <= 0;//x
								w_reg_addr_src <= `S6_addr_t;
								w_reg_data_src <= `S8_MEM_RESULT;		
								w_mem_en <= 0;											
								mem_addr_src <= `S4_PC_ALIGN_IMM32;
								HSIZE <= `HSIZE_32bit;
								r_mem_data_src <= 0;					
								
							end
						end
						else begin /////instruction16[15:12]==4'd0101
							case(instruction16[11:9])
								3'b000:begin /////STRr
									addr_m <= {1'd0, instruction16[8:6]};
									addr_n <= {1'd0, instruction16[5:3]};
									addr_d <= 4'd0;
									addr_t <= {1'd0, instruction16[2:0]};
									imm32  <= 32'd0;
									reglist<= 10'd0;
									udf    <= 0;
									upd    <= 0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 0;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= 0;
									w_reg_data_src <= 0;		
									w_mem_en <= 1;														
									mem_addr_src <= `S4_RN_RM;
									HSIZE <= `HSIZE_32bit;
									r_mem_data_src <= 0;					
									
								end
								3'b001:begin /////STRHr
									addr_m <= {1'd0, instruction16[8:6]};
									addr_n <= {1'd0, instruction16[5:3]};
									addr_d <= 4'd0;
									addr_t <= {1'd0, instruction16[2:0]};
									imm32  <= 32'd0;
									reglist<= 10'd0;
									udf    <= 0;
									upd    <= 0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 0;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= 0;
									w_reg_data_src <= 0;	
									w_mem_en <= 1;															
									mem_addr_src <= `S4_RN_RM;
									HSIZE <= `HSIZE_16bit;
									r_mem_data_src <= 0;					
									
								end
								3'b010:begin /////STRBr
									addr_m <= {1'd0, instruction16[8:6]};
									addr_n <= {1'd0, instruction16[5:3]};
									addr_d <= 4'd0;
									addr_t <= {1'd0, instruction16[2:0]};
									imm32  <= 32'd0;
									reglist<= 10'd0;
									udf    <= 0;
									upd    <= 0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 0;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= 0;
									w_reg_data_src <= 0;		
									w_mem_en <= 1;										
									mem_addr_src <= `S4_RN_RM;
									HSIZE <= `HSIZE_8bit;
									r_mem_data_src <= 0;					
									
								end
								3'b011:begin /////LDRSBr
									addr_m <= {1'd0, instruction16[8:6]};
									addr_n <= {1'd0, instruction16[5:3]};
									addr_d <= 4'd0;
									addr_t <= {1'd0, instruction16[2:0]};
									imm32  <= 32'd0;
									reglist<= 10'd0;
									udf    <= 0;
									upd    <= 0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 1;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= `S6_addr_t;
									w_reg_data_src <= `S8_MEM_RESULT;	
									w_mem_en <= 0;											
									mem_addr_src <= `S4_RN_RM;
									HSIZE <= `HSIZE_8bit;
									r_mem_data_src <= `S5_SIGNEXTEND;					
									
								end
								3'b100:begin /////LDRr
									addr_m <= {1'd0, instruction16[8:6]};
									addr_n <= {1'd0, instruction16[5:3]};
									addr_d <= 4'd0;
									addr_t <= {1'd0, instruction16[2:0]};
									imm32  <= 32'd0;
									reglist<= 10'd0;
									udf    <= 0;
									upd    <= 0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 1;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= `S6_addr_t;
									w_reg_data_src <= `S8_MEM_RESULT;		
									w_mem_en <= 0;														
									mem_addr_src <= `S4_RN_RM;
									HSIZE <= `HSIZE_32bit;
									r_mem_data_src <= 0;					
									
								end
								3'b101:begin /////LDRHr
									addr_m <= {1'd0, instruction16[8:6]};
									addr_n <= {1'd0, instruction16[5:3]};
									addr_d <= 4'd0;
									addr_t <= {1'd0, instruction16[2:0]};
									imm32  <= 32'd0;
									reglist<= 10'd0;
									udf    <= 0;
									upd    <= 0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 1;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= `S6_addr_t;
									w_reg_data_src <= `S8_MEM_RESULT;		
									w_mem_en <= 0;														
									mem_addr_src <= `S4_RN_RM;
									HSIZE <= `HSIZE_16bit;
									r_mem_data_src <= `S5_ZEROEXTEND;					
									
								end
								3'b110:begin /////LDRBr
									addr_m <= {1'd0, instruction16[8:6]};
									addr_n <= {1'd0, instruction16[5:3]};
									addr_d <= 4'd0;
									addr_t <= {1'd0, instruction16[2:0]};
									imm32  <= 32'd0;
									reglist<= 10'd0;
									udf    <= 0;
									upd    <= 0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 1;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= `S6_addr_t;
									w_reg_data_src <= `S8_MEM_RESULT;		
									w_mem_en <= 0;														
									mem_addr_src <= `S4_RN_RM;
									HSIZE <= `HSIZE_8bit;
									r_mem_data_src <= `S5_ZEROEXTEND;					
									
								end
								3'b111:begin /////LDRSHr
									addr_m <= {1'd0, instruction16[8:6]};
									addr_n <= {1'd0, instruction16[5:3]};
									addr_d <= 4'd0;
									addr_t <= {1'd0, instruction16[2:0]};
									imm32  <= 32'd0;
									reglist<= 10'd0;
									udf    <= 0;
									upd    <= 0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 1;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= `S6_addr_t;
									w_reg_data_src <= `S8_MEM_RESULT;	
									w_mem_en <= 0;															
									mem_addr_src <= `S4_RN_RM;
									HSIZE <= `HSIZE_16bit;
									r_mem_data_src <= `S5_SIGNEXTEND;					
									
								end
							endcase
						end
					end
					else begin /////instruction16[15:13]==3'd011
						case(instruction16[12:11])
							2'b00:begin /////STRi
								addr_m <= 4'd0;
								addr_n <= {1'd0, instruction16[5:3]};
								addr_d <= 4'd0;
								addr_t <= {1'd0, instruction16[2:0]};
								imm32  <= {25'd0, instruction16[10:6], 2'd0};
								reglist<= 10'd0;
								udf    <= 0;
								upd    <= 0;
								w_N_en <=0;
								w_Z_en <=0;
								w_C_en <=0;
								w_V_en <=0;
								w_reg_en <= 0;
								branch <= 0;
								alu_src1_choose <= 0;//x
								alu_src2_choose <= 0;//x
								alu_src_cin_choose <= 0;//x
								alu_op <= 0;//x
								w_reg_addr_src <= 0;
								w_reg_data_src <= 0;					
								w_mem_en <= 1;											
								mem_addr_src <= `S4_RN_IMM32;
								HSIZE <= `HSIZE_32bit;
								r_mem_data_src <= 0;					
								
							end
							2'b01:begin /////LDRi
								addr_m <= 4'd0;
								addr_n <= {1'd0, instruction16[5:3]};
								addr_d <= 4'd0;
								addr_t <= {1'd0, instruction16[2:0]};
								imm32  <= {25'd0, instruction16[10:6], 2'd0};
								reglist<= 10'd0;
								udf    <= 0;
								upd    <= 0;
								w_N_en <=0;
								w_Z_en <=0;
								w_C_en <=0;
								w_V_en <=0;
								w_reg_en <= 1;
								branch <= 0;
								alu_src1_choose <= 0;//x
								alu_src2_choose <= 0;//x
								alu_src_cin_choose <= 0;//x
								alu_op <= 0;//x
								w_reg_addr_src <= `S6_addr_t;
								w_reg_data_src <= `S8_MEM_RESULT;	
								w_mem_en <= 0;															
								mem_addr_src <= `S4_RN_IMM32;
								HSIZE <= `HSIZE_32bit;
								r_mem_data_src <= 0;					
								
							end
							2'b10:begin //////STRBi
								addr_m <= 4'd0;
								addr_n <= {1'd0, instruction16[5:3]};
								addr_d <= 4'd0;
								addr_t <= {1'd0, instruction16[2:0]};
								imm32  <= {27'd0, instruction16[10:6]};
								reglist<= 10'd0;
								udf    <= 0;
								upd    <= 0;
								w_N_en <=0;
								w_Z_en <=0;
								w_C_en <=0;
								w_V_en <=0;
								w_reg_en <= 0;
								branch <= 0;
								alu_src1_choose <= 0;//x
								alu_src2_choose <= 0;//x
								alu_src_cin_choose <= 0;//x
								alu_op <= 0;//x
								w_reg_addr_src <= 0;
								w_reg_data_src <= 0;		
								w_mem_en <= 1;														
								mem_addr_src <= `S4_RN_IMM32;
								HSIZE <= `HSIZE_8bit;
								r_mem_data_src <= 0;					
								
							end
							2'b11:begin /////LDRBi
								addr_m <= 4'd0;
								addr_n <= {1'd0, instruction16[5:3]};
								addr_d <= 4'd0;
								addr_t <= {1'd0, instruction16[2:0]};
								imm32  <= {27'd0, instruction16[10:6]};
								reglist<= 10'd0;
								udf    <= 0;
								upd    <= 0;
								w_N_en <=0;
								w_Z_en <=0;
								w_C_en <=0;
								w_V_en <=0;
								w_reg_en <= 1;
								branch <= 0;
								alu_src1_choose <= 0;//x
								alu_src2_choose <= 0;//x
								alu_src_cin_choose <= 0;//x
								alu_op <= 0;//x
								w_reg_addr_src <= `S6_addr_t;
								w_reg_data_src <= `S8_MEM_RESULT;	
								w_mem_en <= 0;															
								mem_addr_src <= `S4_RN_IMM32;
								HSIZE <= `HSIZE_8bit;
								r_mem_data_src <= `S5_ZEROEXTEND;					
								
							end
						endcase
					end
				end
				2'b10:begin
					case(instruction16[13])
						1'b0:
							case(instruction16[12:11])
								2'b00:begin		//A6.7.63 STRH (immediate)
									addr_m <= 4'd0;
									addr_n <= {1'b0, instruction16[5:3]};
									addr_d <= 4'd0;
									addr_t <= {1'b0, instruction16[2:0]};
									imm32 <= {26'd0, instruction16[10:6], 1'b0};
									reglist <= 10'd0; 
									udf <= 1'b0;
									upd <= 1'b0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 0;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= 0;
									w_reg_data_src <= 0;		
									w_mem_en <= 1;														
									mem_addr_src <= `S4_RN_IMM32;
									HSIZE <= `HSIZE_16bit;
									r_mem_data_src <= 0;					
									
								end
								2'b01:begin		//A6.7.31 LDRH (immediate)
									addr_m <= 4'd0;
									addr_n <= {1'b0, instruction16[5:3]};
									addr_d <= 4'd0;
									addr_t <= {1'b0, instruction16[2:0]};
									imm32 <= {26'd0, instruction16[10:6], 1'b0};
									reglist <= 10'd0; 
									udf <= 1'b0;
									upd <= 1'b0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 1;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= `S6_addr_t;
									w_reg_data_src <= `S8_MEM_RESULT;		
									w_mem_en <= 0;														
									mem_addr_src <= `S4_RN_IMM32;
									HSIZE <= `HSIZE_16bit;
									r_mem_data_src <= `S5_ZEROEXTEND;					
									
								end	
								2'b10:begin		//A6.7.59 STR (immediate)
									addr_m <= 4'd0;
									addr_n <= 4'd13;
									addr_d <= 4'd0;
									addr_t <= {1'b0, instruction16[10:8]};
									imm32 <= {22'd0, instruction16[7:0], 2'b00};
									reglist <= 10'd0; 
									udf <= 1'b0;
									upd <= 1'b0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 0;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= 0;
									w_reg_data_src <= 0;			
									w_mem_en <= 1;													
									mem_addr_src <= `S4_RN_IMM32;
									HSIZE <= `HSIZE_32bit;
									r_mem_data_src <= 0;					
									
								end	
								2'b11:begin		//A6.7.26 LDR (immediate)
									addr_m <= 4'd0;
									addr_n <= 4'd13;
									addr_d <= 4'd0;
									addr_t <= instruction16[10:8];
									imm32 <= {22'd0, instruction16[7:0], 2'b00};
									reglist <= 10'd0; 
									udf <= 1'b0;
									upd <= 1'b0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 1;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= `S6_addr_t;
									w_reg_data_src <= `S8_MEM_RESULT;		
									w_mem_en <= 0;														
									mem_addr_src <= `S4_RN_IMM32;
									HSIZE <= `HSIZE_32bit;
									r_mem_data_src <= 0;					
									
								end	
							endcase
						1'b1:
							case(instruction16[12])
								1'b0:
									case(instruction16[11])
										1'b0:begin	//A6.7.6 ADR
											addr_m <= 4'd0;
											addr_n <= 4'd0;
											addr_d <= {1'b0, instruction16[10:8]};
											addr_t <= 4'd0;
											imm32 <= {22'd0, instruction16[7:0], 2'b00};
											reglist <= 10'd0;
											udf <= 1'b0;
											upd <= 1'b0;
											w_N_en <=0;
											w_Z_en <=0;
											w_C_en <=0;
											w_V_en <=0;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= `S1_PC_ALIGN;
											alu_src2_choose <= `S2_IMM32;
											alu_src_cin_choose <= `SC_0;
											alu_op <= `ADC;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;	
											w_mem_en <= 0;															
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end	
										1'b1:begin	//A6.7.4 ADD (SP plus immediate)
											addr_m <= 4'd0;
											addr_n <= 4'd13;
											addr_d <= {1'b0, instruction16[10:8]};
											addr_t <= 4'd0;
											imm32 <= {23'd0, instruction16[7:0], 2'b00};
											reglist <= 10'd0; 
											udf <= 1'b0;
											upd <= 1'b0;
											w_N_en <=0;
											w_Z_en <=0;
											w_C_en <=0;
											w_V_en <=0;
											w_reg_en <= 1;
											branch <= 0;
											alu_src1_choose <= 0;
											alu_src2_choose <= 0;
											alu_src_cin_choose <= 0;
											alu_op <= 0;
											alu_src1_choose <= `S1_RN;
											alu_src2_choose <= `S2_IMM32;
											alu_src_cin_choose <= `SC_0;
											alu_op <= `ADC;
											w_reg_addr_src <= `S6_addr_d;
											w_reg_data_src <= `S8_ALU_RESULT;	
											w_mem_en <= 0;														
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end	
									endcase
								1'b1:
									case(instruction16[11:9])
										3'b000:
											case(instruction16[8:7])
												2'b00:begin	//A6.7.4 ADD (SP plus immediate)
													addr_m <= 4'd0;
													addr_n <= 4'd13;
													addr_d <= 4'd13;
													addr_t <= 4'd0;
													imm32 <= {23'd0, instruction16[6:0], 2'b00};
													reglist <= 10'd0; 
													udf <= 1'b0;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 1;
													branch <= 0;
													alu_src1_choose <= `S1_RN;
													alu_src2_choose <= `S2_IMM32;
													alu_src_cin_choose <= `SC_0;
													alu_op <= `ADC;
													w_reg_addr_src <= `S6_addr_d;
													w_reg_data_src <= `S8_ALU_RESULT;
													w_mem_en <= 0;	
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end	
												2'b01:begin	//A6.7.67 SUB (SP minus immediate)
													addr_m <= 4'd0;
													addr_n <= 4'd13;
													addr_d <= 4'd13;
													addr_t <= 4'd0;
													imm32 <= {23'd0, instruction16[6:0], 2'b00};
													reglist <= 10'd0; 
													udf <= 1'b0;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 1;
													branch <= 0;
													alu_src1_choose <= `S1_RN;
													alu_src2_choose <= `S2_NOT_IMM32;
													alu_src_cin_choose <= `SC_1;
													alu_op <= `ADC;
													w_reg_addr_src <= `S6_addr_d;
													w_reg_data_src <= `S8_ALU_RESULT;		
													w_mem_en <= 0;								
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end
												default:begin	//undefined
													addr_m <= 4'd0;
													addr_n <= 4'd0;
													addr_d <= 4'd0;
													addr_t <= 4'd0;
													imm32 <= 32'd0;
													reglist <= 10'd0; 
													udf <= 1'b1;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 0;
													branch <= 0;
													alu_src1_choose <= 0;//x
													alu_src2_choose <= 0;//x
													alu_src_cin_choose <= 0;//x
													alu_op <= 0;//x
													w_reg_addr_src <= 0;
													w_reg_data_src <= 0;	
													w_mem_en <= 0;									
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end
											endcase
										3'b001:
											case(instruction16[8:6])
												3'b000:begin	//A6.7.70 SXTH
													addr_m <= {1'b0, instruction16[5:3]};
													addr_n <= 4'd0;
													addr_d <= {1'b0, instruction16[2:0]};
													addr_t <= 4'd0;
													imm32 <= 32'd0;
													reglist <= 10'd0; 
													udf <= 1'b0;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 1;
													branch <= 0;
													alu_src1_choose <= `S1_RM;
													alu_src2_choose <= 0;//x
													alu_src_cin_choose <= 0;//x
													alu_op <= `SXTH;
													w_reg_addr_src <= `S6_addr_d;
													w_reg_data_src <= `S8_ALU_RESULT;		
													w_mem_en <= 0;								
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end
												3'b001:begin	//A6.7.69 SXTB
													addr_m <= {1'b0, instruction16[5:3]};
													addr_n <= 4'd0;
													addr_d <= {1'b0, instruction16[2:0]};
													addr_t <= 4'd0;
													imm32 <= 32'd0;
													reglist <= 10'd0; 
													udf <= 1'b0;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 1;
													branch <= 0;
													alu_src1_choose <= `S1_RM;
													alu_src2_choose <= 0;//x
													alu_src_cin_choose <= 0;//x
													alu_op <= `SXTB;
													w_reg_addr_src <= `S6_addr_d;
													w_reg_data_src <= `S8_ALU_RESULT;	
													w_mem_en <= 0;									
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end
												3'b010:begin	//A6.7.74 UXTH
													addr_m <= {1'b0, instruction16[5:3]};
													addr_n <= 4'd0;
													addr_d <= {1'b0, instruction16[2:0]};
													addr_t <= 4'd0;
													imm32 <= 32'd0;
													reglist <= 10'd0; 
													udf <= 1'b0;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 1;
													branch <= 0;
													alu_src1_choose <= `S1_RM;
													alu_src2_choose <= 0;//x
													alu_src_cin_choose <= 0;//x
													alu_op <= `UXTH;
													w_reg_addr_src <= `S6_addr_d ;
													w_reg_data_src <= `S8_ALU_RESULT;	
													w_mem_en <= 0;									
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end
												3'b011:begin	//A6.7.73 UXTB
													addr_m <= {1'b0, instruction16[5:3]};
													addr_n <= 4'd0;
													addr_d <= {1'b0, instruction16[2:0]};
													addr_t <= 4'd0;
													imm32 <= 32'd0;
													reglist <= 10'd0; 
													udf <= 1'b0;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 1;
													branch <= 0;
													alu_src1_choose <= `S1_RM;
													alu_src2_choose <= 0;//x
													alu_src_cin_choose <= 0;//x
													alu_op <= `UXTB;
													w_reg_addr_src <= `S6_addr_d;
													w_reg_data_src <= `S8_ALU_RESULT;	
													w_mem_en <= 0;									
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end
												default:begin	//undefined
													addr_m <= 4'd0;
													addr_n <= 4'd0;
													addr_d <= 4'd0;
													addr_t <= 4'd0;
													imm32 <= 32'd0;
													reglist <= 10'd0; 
													udf <= 1'b1;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 0;
													branch <= 0;
													alu_src1_choose <= 0;//x
													alu_src2_choose <= 0;//x
													alu_src_cin_choose <= 0;//x
													alu_op <= 0;//x
													w_reg_addr_src <= 0;
													w_reg_data_src <= 0;	
													w_mem_en <= 0;									
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end
											endcase
										3'b010:
											begin	//A6.7.50 PUSH
												addr_m <= 4'd0;
												addr_n <= 4'd13;
												addr_d <= 4'd0;
												addr_t <= 4'd0;
												imm32 <= 32'd0;
												reglist <= {1'b0, instruction16[8:0]}; //discussion pop push st ld multiple
												udf <= 1'b0;
												upd <= (instruction16[8:0]==9'd0)? 1 : 0;//discussion pop push st ld multiple
												w_N_en <=0;
												w_Z_en <=0;
												w_C_en <=0;
												w_V_en <=0;
												w_reg_en <= 1;
												branch <= 0;
												alu_src1_choose <= `S1_RN;
												alu_src2_choose <= `S2_NOT_BIT_COUNT;
												alu_src_cin_choose <= `SC_1;
												alu_op <= `ADC;
												w_reg_addr_src <= `S6_addr_n;
												w_reg_data_src <= `S8_ALU_RESULT;	
												w_mem_en <= 0;									
												mem_addr_src <= `S4_addr_dm_out;
												HSIZE <= `HSIZE_32bit;
												r_mem_data_src <= 0;					
												
											end
										3'b011:
											if(instruction16[8:5]==4'b0011)
												begin	//B4.2.1 CPS
													addr_m <= 4'd0;
													addr_n <= 4'd0;
													addr_d <= 4'd0;
													addr_t <= 4'd0;
													imm32 <= 32'd0;
													reglist <= 10'd0; 
													udf <= 1'b0;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 0;
													branch <= 0;
													alu_src1_choose <= 0;//x
													alu_src2_choose <= 0;//x
													alu_src_cin_choose <= 0;//x
													alu_op <= 0;//x
													w_reg_addr_src <= 0;
													w_reg_data_src <= 0;		
													w_mem_en <= 0;																
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end
											else
												begin	//undefined
													addr_m <= 4'd0;
													addr_n <= 4'd0;
													addr_d <= 4'd0;
													addr_t <= 4'd0;
													imm32 <= 32'd0;
													reglist <= 10'd0; 
													udf <= 1'b1;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 0;
													branch <= 0;
													alu_src1_choose <= 0;//x
													alu_src2_choose <= 0;//x
													alu_src_cin_choose <= 0;//x
													alu_op <= 0;//x
													w_reg_addr_src <= 0;
													w_reg_data_src <= 0;		
													w_mem_en <= 0;																
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end
										3'b101:
											case(instruction16[8:6])
												3'b000:begin	//A6.7.51 REV
													addr_m <= {1'b0, instruction16[5:3]};
													addr_n <= 4'd0;
													addr_d <= {1'b0, instruction16[2:0]};
													addr_t <= 4'd0;
													imm32 <= 32'd0;
													reglist <= 10'd0; 
													udf <= 1'b0;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 1;
													branch <= 0;
													alu_src1_choose <= `S1_RM;
													alu_src2_choose <= 0;//x
													alu_src_cin_choose <= 0;//x
													alu_op <= `REV;
													w_reg_addr_src <= `S6_addr_d;
													w_reg_data_src <= `S8_ALU_RESULT;		
													w_mem_en <= 0;											
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end
												3'b001:begin	//A6.7.52 REV16
													addr_m <= {1'b0, instruction16[5:3]};
													addr_n <= 4'd0;
													addr_d <= {1'b0, instruction16[2:0]};
													addr_t <= 4'd0;
													imm32 <= 32'd0;
													reglist <= 10'd0; 
													udf <= 1'b0;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 1;
													branch <= 0;
													alu_src1_choose <= `S1_RM;
													alu_src2_choose <= 0;//x
													alu_src_cin_choose <= 0;//x
													alu_op <= `REV16;
													w_reg_addr_src <= `S6_addr_d;
													w_reg_data_src <= `S8_ALU_RESULT;		
													w_mem_en <= 0;											
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end
												3'b011:begin	//A6.7.53 REVSH
													addr_m <= {1'b0, instruction16[5:3]};
													addr_n <= 4'd0;
													addr_d <= {1'b0, instruction16[2:0]};
													addr_t <= 4'd0;
													imm32 <= 32'd0;
													reglist <= 10'd0; 
													udf <= 1'b0;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 1;
													branch <= 0;
													alu_src1_choose <= `S1_RM;
													alu_src2_choose <= 0;//x
													alu_src_cin_choose <= 0;//x
													alu_op <= `REVSH;
													w_reg_addr_src <= `S6_addr_d;
													w_reg_data_src <= `S8_ALU_RESULT;		
													w_mem_en <= 0;											
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end
												default:begin	//undefined
													addr_m <= 4'd0;
													addr_n <= 4'd0;
													addr_d <= 4'd0;
													addr_t <= 4'd0;
													imm32 <= 32'd0;
													reglist <= 10'd0; 
													udf <= 1'b1;
													upd <= 1'b0;
													w_N_en <=0;
													w_Z_en <=0;
													w_C_en <=0;
													w_V_en <=0;
													w_reg_en <= 0;
													branch <= 0;
													alu_src1_choose <= 0;//x
													alu_src2_choose <= 0;//x
													alu_src_cin_choose <= 0;//x
													alu_op <= 0;//x
													w_reg_addr_src <= 0;
													w_reg_data_src <= 0;			
													w_mem_en <= 0;										
													mem_addr_src <= 0;
													HSIZE <= 0;
													r_mem_data_src <= 0;					
													
												end
											endcase
										3'b110:
											begin	//A6.7.49 POP
												addr_m <= 4'd0;
												addr_n <= 4'd13;
												addr_d <= 4'd0;
												addr_t <= 4'd0;
												imm32 <= 32'd0;
												reglist <= {instruction16[8], 1'b0, instruction16[7:0]}; //discussion pop push st ld multiple
												udf <= 1'b0;
												upd <= (instruction16[8:0]==9'd0)? 1 : 0;//discussion pop push st ld multiple
												w_N_en <=0;
												w_Z_en <=0;
												w_C_en <=0;
												w_V_en <=0;
												w_reg_en <= 1;//discussion
												branch <= 0;//discussion
												alu_src1_choose <= `S1_RN;
												alu_src2_choose <= `S2_BIT_COUNT;
												alu_src_cin_choose <= `SC_0;
												alu_op <= `ADC;
												w_reg_addr_src <= `S6_addr_n;
												w_reg_data_src <= `S8_ALU_RESULT;			
												w_mem_en <= 0;										
												mem_addr_src <= `S4_addr_dm_out;
												HSIZE <= `HSIZE_32bit;
												r_mem_data_src <= 0;					
												
											end
										3'b111:
											case(instruction16[8])
												1'b0:
													begin	//A6.7.12 BKPT
														addr_m <= 4'd0;
														addr_n <= 4'd0;
														addr_d <= 4'd0;
														addr_t <= 4'd0;
														imm32 <= {24'd0, instruction16[7:0]};
														reglist <= 10'd0; 
														udf <= 1'b0;
														upd <= 1'b0;
														w_N_en <=0;
														w_Z_en <=0;
														w_C_en <=0;
														w_V_en <=0;
														w_reg_en <= 0;
														branch <= 0;
														alu_src1_choose <= 0;//x
														alu_src2_choose <= 0;//x
														alu_src_cin_choose <= 0;//x
														alu_op <= 0;//x
														w_reg_addr_src <= 0;
														w_reg_data_src <= 0;				
														w_mem_en <= 0;															
														mem_addr_src <= 0;
														HSIZE <= 0;
														r_mem_data_src <= 0;					
														
													end
												1'b1:	//Hint instructions
													if(instruction16[3:0]==4'b0000)begin
														case(instruction16[7:4])
															4'b0000:
																begin	//A6.7.47 NOP	//discussion all hint in one coding
																	addr_m <= 4'd0;
																	addr_n <= 4'd0;
																	addr_d <= 4'd0;
																	addr_t <= 4'd0;
																	imm32 <= 32'd0;
																	reglist <= 10'd0; 
																	udf <= 1'b0;
																	upd <= 1'b0;
																	w_N_en <=0;
																	w_Z_en <=0;
																	w_C_en <=0;
																	w_V_en <=0;
																	w_reg_en <= 0;
																	branch <= 0;
																	alu_src1_choose <= 0;//x
																	alu_src2_choose <= 0;//x
																	alu_src_cin_choose <= 0;//x
																	alu_op <= 0;//x
																	w_reg_addr_src <= 0;
																	w_reg_data_src <= 0;				
																	w_mem_en <= 0;											
																	mem_addr_src <= 0;
																	HSIZE <= 0;
																	r_mem_data_src <= 0;					
																	
																end
															4'b0001:
																begin	//A6.7.77 YIELD
																	addr_m <= 4'd0;
																	addr_n <= 4'd0;
																	addr_d <= 4'd0;
																	addr_t <= 4'd0;
																	imm32 <= 32'd0;
																	reglist <= 10'd0; 
																	udf <= 1'b0;
																	upd <= 1'b0;
																	w_N_en <=0;
																	w_Z_en <=0;
																	w_C_en <=0;
																	w_V_en <=0;
																	w_reg_en <= 0;
																	branch <= 0;
																	alu_src1_choose <= 0;//x
																	alu_src2_choose <= 0;//x
																	alu_src_cin_choose <= 0;//x
																	alu_op <= 0;//x
																	w_reg_addr_src <= 0;
																	w_reg_data_src <= 0;				
																	w_mem_en <= 0;											
																	mem_addr_src <= 0;
																	HSIZE <= 0;
																	r_mem_data_src <= 0;					
																	
																end
															4'b0010:
																begin	//A6.7.75 WFE
																	addr_m <= 4'd0;
																	addr_n <= 4'd0;
																	addr_d <= 4'd0;
																	addr_t <= 4'd0;
																	imm32 <= 32'd0;
																	reglist <= 10'd0; 
																	udf <= 1'b0;
																	upd <= 1'b0;
																	w_N_en <=0;
																	w_Z_en <=0;
																	w_C_en <=0;
																	w_V_en <=0;
																	w_reg_en <= 0;
																	branch <= 0;
																	alu_src1_choose <= 0;//x
																	alu_src2_choose <= 0;//x
																	alu_src_cin_choose <= 0;//x
																	alu_op <= 0;//x
																	w_reg_addr_src <= 0;
																	w_reg_data_src <= 0;				
																	w_mem_en <= 0;											
																	mem_addr_src <= 0;
																	HSIZE <= 0;
																	r_mem_data_src <= 0;					
																	
																end
															4'b0011:
																begin	//A6.7.76 WFI
																	addr_m <= 4'd0;
																	addr_n <= 4'd0;
																	addr_d <= 4'd0;
																	addr_t <= 4'd0;
																	imm32 <= 32'd0;
																	reglist <= 10'd0; 
																	udf <= 1'b0;
																	upd <= 1'b0;
																	w_N_en <=0;
																	w_Z_en <=0;
																	w_C_en <=0;
																	w_V_en <=0;
																	w_reg_en <= 0;
																	branch <= 0;
																	alu_src1_choose <= 0;//x
																	alu_src2_choose <= 0;//x
																	alu_src_cin_choose <= 0;//x
																	alu_op <= 0;//x
																	w_reg_addr_src <= 0;
																	w_reg_data_src <= 0;				
																	w_mem_en <= 0;										
																	mem_addr_src <= 0;
																	HSIZE <= 0;
																	r_mem_data_src <= 0;					
																	
																end
															4'b0100:
																begin	//A6.7.57 SEV
																	addr_m <= 4'd0;
																	addr_n <= 4'd0;
																	addr_d <= 4'd0;
																	addr_t <= 4'd0;
																	imm32 <= 32'd0;
																	reglist <= 10'd0; 
																	udf <= 1'b0;
																	upd <= 1'b0;
																	w_N_en <=0;
																	w_Z_en <=0;
																	w_C_en <=0;
																	w_V_en <=0;
																	w_reg_en <= 0;
																	branch <= 0;
																	alu_src1_choose <= 0;//x
																	alu_src2_choose <= 0;//x
																	alu_src_cin_choose <= 0;//x
																	alu_op <= 0;//x
																	w_reg_addr_src <= 0;
																	w_reg_data_src <= 0;
																	w_mem_en <= 0;		
																	mem_addr_src <= 0;
																	HSIZE <= 0;
																	r_mem_data_src <= 0;					
																	
																end
															default:
																begin	//undefined
																	addr_m <= 4'd0;
																	addr_n <= 4'd0;
																	addr_d <= 4'd0;
																	addr_t <= 4'd0;
																	imm32 <= 32'd0;
																	reglist <= 10'd0; 
																	udf <= 1'b1;
																	upd <= 1'b0;
																	w_N_en <=0;
																	w_Z_en <=0;
																	w_C_en <=0;
																	w_V_en <=0;
																	w_reg_en <= 0;
																	branch <= 0;
																	alu_src1_choose <= 0;//x
																	alu_src2_choose <= 0;//x
																	alu_src_cin_choose <= 0;//x
																	alu_op <= 0;//x
																	w_reg_addr_src <= 0;
																	w_reg_data_src <= 0;
																	w_mem_en <= 0;											
																	mem_addr_src <= 0;
																	HSIZE <= 0;
																	r_mem_data_src <= 0;					
																	
																end
														endcase
													end
													else begin	//undefined
														addr_m <= 4'd0;
														addr_n <= 4'd0;
														addr_d <= 4'd0;
														addr_t <= 4'd0;
														imm32 <= 32'd0;
														reglist <= 10'd0; 
														udf <= 1'b1;
														upd <= 1'b0;
														w_N_en <=0;
														w_Z_en <=0;
														w_C_en <=0;
														w_V_en <=0;
														w_reg_en <= 0;
														branch <= 0;
														alu_src1_choose <= 0;//x
														alu_src2_choose <= 0;//x
														alu_src_cin_choose <= 0;//x
														alu_op <= 0;//x
														w_reg_addr_src <= 0;
														w_reg_data_src <= 0;
														w_mem_en <= 0;												
														mem_addr_src <= 0;
														HSIZE <= 0;
														r_mem_data_src <= 0;					
														
													end
											endcase
									endcase
							endcase
					endcase
				end
				2'b11:begin
					case(instruction16[13:12])
						2'b00:
							case(instruction16[11])
								1'b0:begin	//A6.7.58 STM, STMIA, STMEA
									addr_m <= 4'd0;
									addr_n <= {1'b0, instruction16[10:8]};
									addr_d <= 4'd0;
									addr_t <= 4'd0;
									imm32  <= 32'd0;
									reglist<= {2'b00, instruction16[7:0]};
									udf    <= 1'b0;
									upd    <= (instruction16[7:0]==8'd0)? 1'b1 : 1'b0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 1;// discussion
									branch <= 0;
									alu_src1_choose <= `S1_RN;
									alu_src2_choose <= `S2_BIT_COUNT;
									alu_src_cin_choose <= `SC_0;
									alu_op <= `ADC;
									w_reg_addr_src <= `S6_addr_n;
									w_reg_data_src <= `S8_ALU_RESULT;	
									w_mem_en <= 0;											
									mem_addr_src <= `S4_addr_dm_out;
									HSIZE <= `HSIZE_32bit;
									r_mem_data_src <= 0;					
									
								end
								1'b1:begin	//A6.7.25 LDM, LDMIA, LDMFD
									addr_m <= 4'd0;
									addr_n <= {1'b0, instruction16[10:8]};
									addr_d <= 4'd0;
									addr_t <= 4'd0;
									imm32  <= 32'd0;
									reglist<= {2'b00, instruction16[7:0]};
									udf    <= 1'b0;
									upd    <= (instruction16[7:0]==8'd0)? 1'b1 : 1'b0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 1; //discussion
									branch <= 0;
									alu_src1_choose <= `S1_RN;
									alu_src2_choose <= `S2_BIT_COUNT;
									alu_src_cin_choose <= `SC_0;
									alu_op <= `ADC;
									w_reg_addr_src <= `S6_addr_n;
									w_reg_data_src <= `S8_ALU_RESULT;		
									w_mem_en <= 0;															
									mem_addr_src <= `S4_addr_dm_out;
									HSIZE <= `HSIZE_32bit;
									r_mem_data_src <= 0;					
									
								end	
							endcase
						2'b01:
							case(instruction16[11:9])
								3'b111:
									case(instruction16[8])
										1'b0:begin	//A6.7.72 UDF
											addr_m <= 4'd0;
											addr_n <= 4'd0;
											addr_d <= 4'd0; 
											addr_t <= 4'd0; 
											imm32  <= {24'd0, instruction16[7:0]};
											reglist<= 10'd0;
											udf    <= 1'b1;
											upd    <= 1'b0;
											w_N_en <=0;
											w_Z_en <=0;
											w_C_en <=0;
											w_V_en <=0;
											w_reg_en <= 0;
											branch <= 0;
											alu_src1_choose <= 0;//x
											alu_src2_choose <= 0;//x
											alu_src_cin_choose <= 0;//x
											alu_op <= 0;//x
											w_reg_addr_src <= 0;
											w_reg_data_src <= 0;
											w_mem_en <= 0;
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										1'b1:begin	//A6.7.68 SVC
											addr_m <= 4'd0;
											addr_n <= 4'd0;
											addr_d <= 4'd0; 
											addr_t <= 4'd0; 
											imm32  <= {24'd0, instruction16[7:0]};
											reglist<= 10'd0;
											udf    <= 1'b0;
											upd    <= 1'b0;
											w_N_en <=0;
											w_Z_en <=0;
											w_C_en <=0;
											w_V_en <=0;
											w_reg_en <= 0;
											branch <= 0;
											alu_src1_choose <= 0;//x
											alu_src2_choose <= 0;//x
											alu_src_cin_choose <= 0;//x
											alu_op <= 0;//x
											w_reg_addr_src <= 0;
											w_reg_data_src <= 0;
											w_mem_en <= 0;									
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
									endcase
								default:begin	//A6.7.10 B
										addr_m <= 4'd0;
										addr_n <= 4'd0;
										addr_d <= 4'd0; 
										addr_t <= 4'd0;
										imm32  <= {{23{instruction16[7]}}, instruction16[7:0], 1'b0}; 
										reglist<= 10'd0;
										udf    <= 1'b0;
										upd    <= 1'b0;
										w_N_en <=0;
										w_Z_en <=0;
										w_C_en <=0;
										w_V_en <=0;
										w_reg_en <= 0;
										branch <= 1;	//discussion: condition pass?
										alu_src1_choose <= `S1_PC;
										alu_src2_choose <= `S2_IMM32;
										alu_src_cin_choose <= `SC_0;
										alu_op <= `ADC;
										w_reg_addr_src <= 0;
										w_reg_data_src <= 0;
										w_mem_en <= 0;
										mem_addr_src <= 0;
										HSIZE <= 0;
										r_mem_data_src <= 0;					
										
								end
							endcase
						2'b10:begin
							case(instruction16[11])
								1'b0:begin	//A6.7.10 B
									addr_m <= 4'd0;
									addr_n <= 4'd0;
									addr_d <= 4'd0; 
									addr_t <= 4'd0; 
									imm32  <= {{23{instruction16[10]}}, instruction16[10:0], 1'b0}; 
									reglist<= 10'd0;
									udf    <= 1'b0;
									upd    <= 1'b0;	//r0p0 -> no InITBlock()  to cause upd
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 0;
									branch <= 1;
									alu_src1_choose <= `S1_PC;
									alu_src2_choose <= `S2_IMM32;
									alu_src_cin_choose <= `SC_0;
									alu_op <= `ADC;
									w_reg_addr_src <= 0;
									w_reg_data_src <= 0;	
									w_mem_en <= 0;								
									mem_addr_src <= 0;
									HSIZE <= 0;
									r_mem_data_src <= 0;					
									
								end	
								1'b1:begin	//	should be 32bit instruction -> unpredictable
									addr_m <= 4'd0;
									addr_n <= 4'd0;
									addr_d <= 4'd0; 
									addr_t <= 4'd0; 
									imm32  <= 32'd0; 
									reglist<= 10'd0;
									udf    <= 1'b0;
									upd    <= 1'b1;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 0;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= 0;
									w_reg_data_src <= 0;
									w_mem_en <= 0;									
									mem_addr_src <= 0;
									HSIZE <= 0;
									r_mem_data_src <= 0;					
									
								end
							endcase
						end
						2'b11:begin	//	should be 32bit instruction -> unpredictable
							addr_m <= 4'd0;
							addr_n <= 4'd0;
							addr_d <= 4'd0; 
							addr_t <= 4'd0; 			
							imm32  <= 32'd0; 
							reglist<= 10'd0;
							udf    <= 1'b0;
							upd    <= 1'b1;
							w_N_en <=0;
							w_Z_en <=0;
							w_C_en <=0;
							w_V_en <=0;
							w_reg_en <= 0;
							branch <= 0;
							alu_src1_choose <= 0;//x
							alu_src2_choose <= 0;//x
							alu_src_cin_choose <= 0;//x
							alu_op <= 0;//x
							w_reg_addr_src <= 0;
							w_reg_data_src <= 0;
							w_mem_en <= 0;
							mem_addr_src <= 0;
							HSIZE <= 0;
							r_mem_data_src <= 0;					
							
						end
					endcase
				end
			endcase
		end
		else begin ////////////32 bit instruction
			addr_m  <= 4'd0;
			addr_t  <= 4'd0;
			reglist <= 10'd0;
			if(instruction32[28:27]==2'b10 && instruction32[15]==1)begin
				if(instruction32[14]==0)begin
					if(instruction32[12]==0)begin
						case(instruction32[26:21])
							6'b011100:begin ///////////MSR
								addr_n <= instruction32[19:16];
								addr_d <= 4'd0;
								imm32  <= 32'd0;
								option <= 4'd0;
								SYSm   <= instruction32[7:0];
								udf    <= 1'd0;
								w_N_en <=(instruction32[7:2]==6'd0)? 1 : 0;
								w_Z_en <=(instruction32[7:2]==6'd0)? 1 : 0;
								w_C_en <=(instruction32[7:2]==6'd0)? 1 : 0;
								w_V_en <=(instruction32[7:2]==6'd0)? 1 : 0;
								if(MM_cond)
									upd <= 1;
								else if((instruction32[19:16]==4'd13)||(instruction32[19:16]==4'd15))
									upd <= 1;
								else
									upd <= 0;
								w_reg_en <= 0;
								branch <= 0;
								alu_src1_choose <= 0;//x
								alu_src2_choose <= 0;//x
								alu_src_cin_choose <= 0;//x
								alu_op <= 0;//x
								w_reg_addr_src <= 0;
								w_reg_data_src <= 0;
								w_mem_en <= 0;									
								mem_addr_src <= 0;
								HSIZE <= 0;
								r_mem_data_src <= 0;					
								
							end
							6'b011101:begin
								if(instruction32[20]==1)begin
									case(instruction32[7:4])
										4'b0100:begin ///////////DSB
											addr_n <= 4'd0;
											addr_d <= 4'd0;
											imm32  <= 32'd0;
											option <= instruction32[3:0];
											SYSm   <= 8'd0;
											udf    <= 1'd0;
											upd    <= 1'd0;
											w_N_en <=0;
											w_Z_en <=0;
											w_C_en <=0;
											w_V_en <=0;
											w_reg_en <= 0;
											branch <= 0;
											alu_src1_choose <= 0;//x
											alu_src2_choose <= 0;//x
											alu_src_cin_choose <= 0;//x
											alu_op <= 0;//x
											w_reg_addr_src <= 0;
											w_reg_data_src <= 0;
											w_mem_en <= 0;									
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b0101:begin ///////////DMB
											addr_n <= 4'd0;
											addr_d <= 4'd0;
											imm32  <= 32'd0;
											option <= instruction32[3:0];
											SYSm   <= 8'd0;
											udf    <= 1'd0;
											upd    <= 1'd0;
											w_N_en <=0;
											w_Z_en <=0;
											w_C_en <=0;
											w_V_en <=0;
											w_reg_en <= 0;
											branch <= 0;
											alu_src1_choose <= 0;//x
											alu_src2_choose <= 0;//x
											alu_src_cin_choose <= 0;//x
											alu_op <= 0;//x
											w_reg_addr_src <= 0;
											w_reg_data_src <= 0;
											w_mem_en <= 0;									
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										4'b0110:begin ///////////ISB
											addr_n <= 4'd0;
											addr_d <= 4'd0;
											imm32  <= 32'd0;
											option <= instruction32[3:0];
											SYSm   <= 8'd0;
											udf    <= 1'd0;
											upd    <= 1'd0;
											w_N_en <=0;
											w_Z_en <=0;
											w_C_en <=0;
											w_V_en <=0;
											w_reg_en <= 0;
											branch <= 0;
											alu_src1_choose <= 0;//x
											alu_src2_choose <= 0;//x
											alu_src_cin_choose <= 0;//x
											alu_op <= 0;//x
											w_reg_addr_src <= 0;
											w_reg_data_src <= 0;
											w_mem_en <= 0;									
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
										default:begin /////undefined
											addr_n <= 4'd0;
											addr_d <= 4'd0;
											imm32  <= 32'd0;
											option <= 4'd0;
											SYSm   <= 8'd0;
											udf    <= 1'b1;
											upd    <= 1'b0;
											w_N_en <=0;
											w_Z_en <=0;
											w_C_en <=0;
											w_V_en <=0;
											w_reg_en <= 0;
											branch <= 0;
											alu_src1_choose <= 0;//x
											alu_src2_choose <= 0;//x
											alu_src_cin_choose <= 0;//x
											alu_op <= 0;//x
											w_reg_addr_src <= 0;
											w_reg_data_src <= 0;
											w_mem_en <= 0;										
											mem_addr_src <= 0;
											HSIZE <= 0;
											r_mem_data_src <= 0;					
											
										end
									endcase
								end
								else begin /////undefined
									addr_n <= 4'd0;
									addr_d <= 4'd0;
									imm32  <= 32'd0;
									option <= 4'd0;
									SYSm   <= 8'd0;
									udf    <= 1'd1;
									upd    <= 1'd0;
									w_N_en <=0;
									w_Z_en <=0;
									w_C_en <=0;
									w_V_en <=0;
									w_reg_en <= 0;
									branch <= 0;
									alu_src1_choose <= 0;//x
									alu_src2_choose <= 0;//x
									alu_src_cin_choose <= 0;//x
									alu_op <= 0;//x
									w_reg_addr_src <= 0;
									w_reg_data_src <= 0;
									w_mem_en <= 0;											
									mem_addr_src <= 0;
									HSIZE <= 0;
									r_mem_data_src <= 0;					
									
								end
							end
							6'b011111:begin //////////MRS
								addr_n <= 4'd0;
								addr_d <= instruction32[11:8];
								imm32  <= 32'd0;
								option <= 4'd0;
								SYSm   <= instruction32[7:0];
								udf    <= 1'd0;
								w_N_en <=0;
								w_Z_en <=0;
								w_C_en <=0;
								w_V_en <=0;
								if(MM_cond)
									upd = 1;
								else if((instruction32[11:8]==4'd13)||(instruction32[11:8]==4'd15))
									upd = 1;
								else 
									upd = 0;
								w_reg_en <= 1;
								branch <= 0;
								alu_src1_choose <= 0;//x
								alu_src2_choose <= 0;//x
								alu_src_cin_choose <= 0;//x
								alu_op <= 0;//x
								w_reg_addr_src <= 0;
								w_reg_data_src <= 0;
								w_mem_en <= 0;											
								mem_addr_src <= 0;
								HSIZE <= 0;
								r_mem_data_src <= 0;					
								
							end
							6'b111111:begin // UDF
								addr_n <= 4'd0;
								addr_d <= 4'd0;
								imm32  <= {16'd0, instruction32[19:16], instruction32[11:0]};
								option <= 4'd0;
								SYSm   <= 8'd0;
								udf    <= 1'd1;
								upd    <= 1'd0;
								w_N_en <=0;
								w_Z_en <=0;
								w_C_en <=0;
								w_V_en <=0;
								w_reg_en <= 0;
								branch <= 0;
								alu_src1_choose <= 0;//x
								alu_src2_choose <= 0;//x
								alu_src_cin_choose <= 0;//x
								alu_op <= 0;//x
								w_reg_addr_src <= 0;
								w_reg_data_src <= 0;
								w_mem_en <= 0;											
								mem_addr_src <= 0;
								HSIZE <= 0;
								r_mem_data_src <= 0;					
								
							end
							default:begin /////undefined
								addr_n <= 4'd0;
								addr_d <= 4'd0;
								imm32  <= 32'd0;
								option <= 4'd0;
								SYSm   <= 8'd0;
								udf    <= 1'd1;
								upd    <= 1'd0;
								w_N_en <=0;
								w_Z_en <=0;
								w_C_en <=0;
								w_V_en <=0;
								w_reg_en <= 0;
								branch <= 0;
								alu_src1_choose <= 0;//x
								alu_src2_choose <= 0;//x
								alu_src_cin_choose <= 0;//x
								alu_op <= 0;//x
								w_reg_addr_src <= 0;
								w_reg_data_src <= 0;
								w_mem_en <= 0;												
								mem_addr_src <= 0;
								HSIZE <= 0;
								r_mem_data_src <= 0;					
								
							end
						endcase
					end
					else begin /////undefined
						addr_n <= 4'd0;
						addr_d <= 4'd0;
						imm32  <= 32'd0;
						option <= 4'd0;
						SYSm   <= 8'd0;
						udf    <= 1'd1;
						upd    <= 1'd0;
						w_N_en <=0;
						w_Z_en <=0;
						w_C_en <=0;
						w_V_en <=0;
						w_reg_en <= 0;
						branch <= 0;
						alu_src1_choose <= 0;//x
						alu_src2_choose <= 0;//x
						alu_src_cin_choose <= 0;//x
						alu_op <= 0;//x
						w_reg_addr_src <= 0;
						w_reg_data_src <= 0;
						w_mem_en <= 0;
						mem_addr_src <= 0;
						HSIZE <= 0;
						r_mem_data_src <= 0;					
						
					end
				end
				else begin
					if(instruction32[12]==1)begin ////////////BL
						addr_n <= 4'd0;
						addr_d <= 4'd14;// discussion modify to LR
						imm32  <= {{8{instruction32[26]}}, (~(instruction32[13]^instruction32[26])),
								  (~(instruction32[11]^instruction32[26])), instruction32[25:16], instruction32[10:0], 1'b0};
						option <= 4'd0;
						SYSm   <= 8'd0;
						udf    <= 1'd0;
						upd    <= 1'd0;
						w_N_en <=0;
						w_Z_en <=0;
						w_C_en <=0;
						w_V_en <=0;
						w_reg_en <= 1;// discussion modify to write for LR
						branch <= 1;
						alu_src1_choose <= `S1_PC;//x
						alu_src2_choose <= `S2_IMM32;//x
						alu_src_cin_choose <= `SC_0;//x
						alu_op <= `ADC;//x
						w_reg_addr_src <= `S6_addr_d;
						w_reg_data_src <= `S8_FOR_BL;
						w_mem_en <= 0;									
						mem_addr_src <= 0;
						HSIZE <= 0;
						r_mem_data_src <= 0;					
						
					end
					else begin /////undefined
						addr_n <= 4'd0;
						addr_d <= 4'd0;
						imm32  <= 32'd0;
						option <= 4'd0;
						SYSm   <= 8'd0;
						udf    <= 1'd1;
						upd    <= 1'd0;
						w_N_en <=0;
						w_Z_en <=0;
						w_C_en <=0;
						w_V_en <=0;
						w_reg_en <= 0;
						branch <= 0;
						alu_src1_choose <= 0;//x
						alu_src2_choose <= 0;//x
						alu_src_cin_choose <= 0;//x
						alu_op <= 0;//x
						w_reg_addr_src <= 0;
						w_reg_data_src <= 0;
						w_mem_en <= 0;									
						mem_addr_src <= 0;
						HSIZE <= 0;
						r_mem_data_src <= 0;					
						
					end
				end
			end
			else begin /////undefined
				addr_n <= 4'd0;
				addr_d <= 4'd0;
				imm32  <= 32'd0;
				option <= 4'd0;
				SYSm   <= 8'd0;
				udf    <= 1'd1;
				upd    <= 1'd0;
				w_N_en <=0;
				w_Z_en <=0;
				w_C_en <=0;
				w_V_en <=0;
				w_reg_en <= 0;
				branch <= 0;
				alu_src1_choose <= 0;//x
				alu_src2_choose <= 0;//x
				alu_src_cin_choose <= 0;//x
				alu_op <= 0;//x
				w_reg_addr_src <= 0;
				w_reg_data_src <= 0;
				w_mem_en <= 0;						
				mem_addr_src <= 0;
				HSIZE <= 0;
				r_mem_data_src <= 0;					
				
			end
		end
	end
endmodule