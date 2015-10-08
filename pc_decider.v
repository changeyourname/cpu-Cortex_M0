module pc_decider(	multiple_stable,
					multiple_stable_from_if_id,
					multiple_pulse_from_if_id,
					list_from_list_count,
					pc_in,
					pc_branch,
					branch,
					nextpc_out
				);
		input multiple_stable;
		input multiple_stable_from_if_id;
		input multiple_pulse_from_if_id;
		input [9:0] list_from_list_count;
		input [31:0] pc_in;
		input [31:0] pc_branch;
		input branch;
		
		output [31:0] nextpc_out;
		
		reg [31:0] nextpc_out;
		
		always@(pc_in or
				pc_branch or
				branch or
				multiple_stable or
				multiple_pulse_from_if_id or
				multiple_stable_from_if_id or
				list_from_list_count
				)begin
			if(branch)
				nextpc_out <= pc_branch;
			else if(multiple_stable) begin
				if(multiple_stable_from_if_id)begin
					if(multiple_pulse_from_if_id)begin
						nextpc_out <= pc_in;
					end
					else begin
						if(list_from_list_count==10'd0)begin
							nextpc_out <= pc_in + 2;
						end
						else begin
							nextpc_out <= pc_in;
						end
					end
				end
				else begin
					nextpc_out <= pc_in;
				end
			end
			else begin
				nextpc_out <= pc_in + 2;
			end
		end
endmodule