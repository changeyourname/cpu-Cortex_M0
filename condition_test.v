`define EQ 4'b0000
`define NE 4'b0001
`define CS 4'b0010
`define CC 4'b0011
`define MI 4'b0100
`define PL 4'b0101
`define VS 4'b0110
`define VC 4'b0111
`define HI 4'b1000
`define LS 4'b1001
`define GE 4'b1010
`define LT 4'b1011
`define GT 4'b1100
`define LE 4'b1101
`define AL 4'b1110


module condition_test(
		cond,
		N,
		Z,
		C,
		V,
		pass	);

	input [3:0] cond;
	input N;
	input Z;
	input C;
	input V;
	
	output pass;
	
	reg pass;
	
	always@(cond or N or Z or C or V)begin
		case(cond)
			`EQ: pass <= Z;
			`NE: pass <= ~Z;
			`CS: pass <= C;
			`CC: pass <= ~C;
			`MI: pass <= N;
			`PL: pass <= ~N;
			`VS: pass <= V;
			`VC: pass <= ~V;
			`HI: pass <= C & (~Z);
			`LS: pass <= (~C) | Z;
			`GE: pass <= (N==V);
			`LT: pass <= (N!=V);
			`GT: pass <= (Z==0)&(N==V);
			`LE: pass <= (Z==1)|(N!=V);
			`AL: pass <= 1;
		endcase
	end
endmodule