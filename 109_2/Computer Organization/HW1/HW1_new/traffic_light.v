module traffic_light (
    input  clk,
    input  rst,
    input  pass,
    output reg R,
    output reg G,
    output reg Y
);

//write your code here


	parameter state_0 = 3'd0;
	parameter state_1 = 3'd1;
	parameter state_2 = 3'd2;
	parameter state_3 = 3'd3;
	parameter state_4 = 3'd4;
	parameter state_5 = 3'd5;
	parameter state_6 = 3'd6;

	parameter cycle1024 = 10'd1024;
	parameter cycle512 = 10'd512;
	parameter cycle128 = 10'd128;

	reg [2:0] current_state;
	reg [9:0] cycle_count;

	always @(posedge clk or posedge rst) begin
		if (~rst) begin
			current_state <= state_0;
			cycle_count <= 10'd0;
		end
		if (~pass && current_state != state_0) begin
			current_state <= state_0;
			cycle_count <= 10'd0;
		end
		if (~rst && ~pass) begin
			case (current_state)
				state_0: 
				if (cycle_count == cycle1024) begin
					current_state = state_1;
					cycle_count = 10'd0;
				end 
				else begin
					//current_state <= state_1;
					cycle_count = cycle_count + 10'd1;
				end
				state_1: 
				if (cycle_count == cycle128) begin
					current_state = state_2;
					cycle_count = 10'd0;
				end 
				else begin
					//current_state <= state_2;
					cycle_count = cycle_count + 10'd1;
				end
				state_2: 
				if (cycle_count == cycle128) begin
					current_state = state_3;
					cycle_count <= 10'd0;
				end 
				else begin
					//current_state <= state_3;
					cycle_count <= cycle_count + 10'd1;
				end
				state_3: 
				if (cycle_count == cycle128) begin
					current_state <= state_4;
					cycle_count <= 10'd0;
				end 
				else begin
					//current_state <= state_4;
					cycle_count <= cycle_count + 10'd1;
				end
				state_4: 
				if (cycle_count == cycle128) begin
					current_state <= state_4;
					cycle_count <= 10'd0;
				end 
				else begin
					//current_state <= state_5;
					cycle_count <= cycle_count + 10'd1;
				end
				state_5: 
				if (cycle_count == cycle512) begin
					current_state <= state_5;
					cycle_count <= 10'd0;
				end 
				else begin
					//current_state <= state_6;
					cycle_count <= cycle_count + 10'd1;
				end
				state_6: 
				if (cycle_count == cycle1024) begin
					current_state <= state_6;
					cycle_count <= 10'd0;
				end 
				else begin
					//current_state <= state_6;
					cycle_count <= cycle_count + 10'd1;
				end
				//default: current_state <= state_0;
			endcase
		end
	end
	always @(*) begin
		case (current_state)
			state_0: begin
				G <= 1'b1;
				R <= 1'b0;
				Y <= 1'b0;
			end 
			state_1: begin
				G <= 1'b0;
				R <= 1'b0;
				Y <= 1'b0;
			end
			state_2: begin
				G <= 1'b1;
				R <= 1'b0;
				Y <= 1'b0;
			end
			state_3: begin
				G <= 1'b0;
				R <= 1'b0;
				Y <= 1'b0;
			end
			state_4: begin
				G <= 1'b1;
				R <= 1'b0;
				Y <= 1'b0;
			end
			state_5: begin
				G <= 1'b0;
				R <= 1'b0;
				Y <= 1'b1;
			end
			state_6: begin
				G <= 1'b0;
				R <= 1'b1;
				Y <= 1'b0;
			end
		endcase
	end

endmodule
