module ALU (
  input [31:0] rs1_data,
  input [31:0] rs2_data,
  input [3:0] ctrl,
  output reg [31:0] alu_out
);

wire reg [31:0] result;
wire reg [31:0] tmp;

always @(*) begin
  case (ctrl)
    4'b0000: result = rs1_data + rs2_data; //add
    4'b0001: result = rs1_data - rs2_data; //sub
    4'b0010: result = rs1_data & rs2_data; //and
    4'b0011: result = rs1_data | rs2_data; //or
    4'b0100: result = rs1_data ^ rs2_data; //xor
    4'b0101: //sltu
    begin
      result = (rs1_data < rs2_data) ? 32'h1 : 32'h0;
    end
    4'b0110: //slt
    begin
      tmp = rs1_data - rs2_data
      if (rs1_data[31] != rs2_data[31]) begin
        result = (rs1_data[31]) ? 32'h1 : 32'h0;
      end
      else
        result = (tmp[31]) ? 32'h1 : 32'h0;
    end
    4'b0111: //sll
    begin
      
    end
    default: 
  endcase
end
  
endmodule