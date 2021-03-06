module traffic_light(pass, clk, rst, R, G, Y);

	input pass, clk, rst;
	output reg R, G, Y;

	
	
	parameter state_0 = 3'b000;
	parameter state_1 = 3'b001;
	parameter state_2 = 3'b010;
	parameter state_3 = 3'b011;
	parameter state_4 = 3'b100;
	parameter state_5 = 3'b101;
	parameter state_6 = 3'b110;

	parameter cycle1024 = 10'd1024;
	parameter cycle512 = 10'd512;
	parameter cycle128 = 10'd128;

	reg [2:0] current_state;
	reg [9:0] cycle_count;

	always @(posedge clk or posedge rst) begin
		if (rst == 1) begin
			current_state <= state_0;
			cycle_count <= 0;
		end
		if (pass == 1 && current_state != state_0) begin
			current_state <= state_0;
			cycle_count <= 0;
		end
		if (rst == 0 && pass == 0) begin
			case (current_state)
				state_0: 
				if (cycle_count < cycle1024) begin
					current_state <= state_0;
					cycle_count <= cycle_count + 1;
				end 
				else begin
					current_state <= state_1;
					cycle_count <= 0;
				end
				state_1: 
				if (cycle_count < cycle128) begin
					current_state <= state_1;
					cycle_count <= cycle_count + 1;
				end 
				else begin
					current_state <= state_2;
					cycle_count <= 0;
				end
				state_2: 
				if (cycle_count < cycle128) begin
					current_state <= state_2;
					cycle_count <= cycle_count + 1;
				end 
				else begin
					current_state <= state_3;
					cycle_count <= 0;
				end
				state_3: 
				if (cycle_count < cycle128) begin
					current_state <= state_3;
					cycle_count <= cycle_count + 1;
				end 
				else begin
					current_state <= state_4;
					cycle_count <= 0;
				end
				state_4: 
				if (cycle_count < cycle128) begin
					current_state <= state_4;
					cycle_count <= cycle_count + 1;
				end 
				else begin
					current_state <= state_5;
					cycle_count <= 0;
				end
				state_5: 
				if (cycle_count < cycle512) begin
					current_state <= state_5;
					cycle_count <= cycle_count + 1;
				end 
				else begin
					current_state <= state_6;
					cycle_count <= 0;
				end
				state_6: 
				if (cycle_count < cycle1024) begin
					current_state <= state_6;
					cycle_count <= cycle_count + 1;
				end 
				else begin
					current_state <= state_6;
					cycle_count <= 0;
				end
				default: current_state <= state_0;
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
