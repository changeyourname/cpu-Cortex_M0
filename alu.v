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
module alu(src1, src2, src_cin, alu_op,result, N,Z,C,V);

input [31:0]src1;
input [31:0]src2;
input src_cin;
input [4:0]alu_op;

output [31:0]result;
output N;
output Z;
output C;
output V;

reg [31:0]result;
reg C;
reg [31:0]whatever;

always@(src1 or src2 or src_cin or alu_op)begin
	case(alu_op)
		`ADC:	begin
					{C, result}<= {1'b0,src1} + {1'b0,src2} + src_cin;
				end
		`AND:	begin
					result <= src1&src2;
					C <= src_cin;//x
				end
		`OR:	begin
					result <= src1|src2;
					C <= src_cin;//x
				end
		`EOR:	begin
					result <= src1^src2;
					C <= src_cin;//x
				end
		`LSL:	begin
					{C, result, whatever} <= {1'b0,src1, {32'b0}} << src2[4:0];
				end
		`LSR:	begin
					{whatever, result, C} <= {{32'b0},src1, 1'b0} >> src2[4:0] ;
				end
		`ASR:	begin
					{whatever, result, C} <= {{32{src1[31]}},src1, 1'b0} >> src2[4:0] ;
				end
		`ROR:	begin
					{whatever,result} <= {src1,src1} >> src2[4:0];
					C <= src_cin;
				end
		`MUL:	begin
					{C, result} <= src1*src2;
				end
		`SRC1:	begin
					result <= src1;
					C<= src_cin;
				end
		`SRC2:	begin
					result <= src2;
					C<= src_cin;
				end
		`REV:	begin
					result <= {src1[7:0],src1[15:8],src1[23:16],src1[31:24]};
					C<= 1'b0;
				end
		`REV16:	begin
					result <= {src1[23:16],src1[31:24], src1[7:0],src1[15:8]};
					C<= 1'b0;
				end
		`REVSH:	begin
					result <= {{16{src1[7]}},src1[7:0], src1[15:8]};
					C<= 1'b0;
				end
		`SXTB:	begin
					result <= {{24{src1[7]}},src1[7:0]};
					C<= 1'b0;
				end
		`SXTH:	begin
					result <= {{16{src1[15]}},src1[15:0]};
					C<= 1'b0;
				end
		`UXTB:	begin
					result <= {24'd0,src1[7:0]};
					C<= 1'b0;
				end
		`UXTH:	begin
					result <= {16'd0,src1[15:0]};
					C<= 1'b0;
				end
		default: begin
					result <= 32'hffffffff;//x
					C<= 1'b0;//x
				end
			
	endcase
end

assign N= result[31];
assign Z= ~|(result);
assign V= (src1[31]^result[31])&(src2[31]^result[31]);

endmodule
