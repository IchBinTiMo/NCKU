// Please include verilog file if you write module in other file

module CPU(
    input             clk,
    input             rst,
    input      [31:0] data_out,
    input      [31:0] instr_out,
    output reg        instr_read,
    output reg        data_read,
    output reg [31:0] instr_addr,
    output reg [31:0] data_addr,
    output reg [3:0]  data_write,
    output reg [31:0] data_in
);

/* Add your design */

reg [31:0] registers [0:31];
reg [6:0] opcode;
reg [4:0] rd;
reg [2:0] funct3;
reg [4:0] rs1;
reg [4:0] rs2;
reg [6:0] funct7;
reg [31:0] tmp;
reg [31:0] rs1_data;
reg [31:0] rs2_data;
reg [63:0] result;
reg integer rd_idx;
reg integer rs1_idx;
reg integer rs2_idx;
reg integer i;

wire [31:0] imm_I = {{20{instr_out[31]}}, instr_out[31:20]};
wire [31:0] imm_S = {{20{instr_out[31]}}, instr_out[31:25], instr_out[11:7]};
wire [31:0] imm_B = {{20{instr_out[31]}}, instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
wire [31:0] imm_U = {{12{instr_out[31]}}, instr_out[31:12]};
wire [31:0] imm_J = {{12{instr_out[31]}}, instr_out[19:12], instr_out[20], instr_out[30:21], 1'b0};
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0;i<32 ;i = i+1 ) begin
            registers[i] = 32'b0;
        end
        opcode = 6'b0;
        rd = 5'b0;
        funct3 = 3'b0;
        rs1 = 5'b0;
        rs2 = 5'b0;
        funct7 = 7'b0;
        tmp = 32'b0;
        rs1_data = 32'b0;
        rs2_data = 32'b0;
        result = 64'b0;  
        rd_idx = 0;
        rs1_idx = 0;
        rs2_idx = 0;          
    end

    opcode = instr_out[6:0];
    rd = instr_out[11:7];

    if(!rst && rd != 5'b0)
    begin
        case (opcode)
            7'b0110011: //R-type
            begin
                rd = instr_out[11:7];
                funct3 = instr_out[14:12];
                rs1 = instr_out[19:15];
                rs2 = instr_out[24:20];
                funct7 = instr_out[31:25];
                rd_idx = rd;
                rs1_idx = rs1;
                rs2_idx = rs2;
                case (funct3)
                    3'b000:
                    begin
                        case(funct7)
                            7'b0000000: //ADD
                            begin
                                registers[rd_idx] = registers[rs1_idx] + registers[rs2_idx]; 
                                data_in = registers[rd_idx];
                                $display("end add");                     
                            end
                            7'b0100000: //SUB
                            begin
                                registers[rd_idx] = registers[rs1_idx] - registers[rs2_idx];
                                data_in = registers[rd_idx];
                                $display("end sub");
                            end
                            7'b0000001: //MUL
                            begin
                                result = $signed(registers[rs1_idx]) * $signed(registers[rs2_idx]);
                                registers[rd_idx] = result[31:0];
                                $display("end mul");
                            end
                            default:
                        endcase
                    end 
                    3'b001:
                    begin
                        case(funct7)
                            7'b0000000: //SLL
                            begin
                                registers[rd_idx] = $unsigned(registers[rs1_idx]) << rs2_idx;
                                $display("end sll");
                            end
                            7'b0000001 //MULH
                            begin
                                result = $signed(registers[rs1_idx]) * $signed(registers[rs2_idx]);
                                registers[rd_idx] = result[63:32];
                                $display("end mulh");
                            end
                            default:
                        endcase
                    end
                    3'b010:
                    begin
                        case(funct7)
                            7'b0000000: //SLT
                            begin
                                registers[rd_idx] = ($signed(registers[rs1_idx])<$signed(registers[rs2_idx]))?32'b1 : 32'b0;
                                $display("end slt");
                            end
                            default:
                        endcase
                    end
                    3'b011:
                    begin
                        case(funct7)
                            7'b0000000: //SLTU
                            begin
                                registers[rd_idx] = ($unsigned(registers[rs1_idx])<$unsigned(registers[rs2_idx]))?32'b1 : 32'b0;
                                $display("end sltu");
                            end
                            default:
                        endcase
                    end
                    3'b100:
                    begin
                        case(funct7)
                            7'b0000000: //XOR
                            begin
                                registers[rd_idx] = registers[rs1_idx] ^ registers[rs2_idx];
                                $display("end xor");
                            end
                            default:
                        endcase
                    end
                    3'b101:
                    begin
                        case(funct7)
                            7'b0000000 //SRL
                            begin
                                registers[rd_idx] = $unsigned(registers[rs1_idx]) >> rs2_idx;
                                $display("end srl"); 
                            end
                            7'b0100000: //SRA
                            begin
                                registers[rd_idx] = $signed(registers[rs1_idx]) >>> rs2_idx;
                                $display("end sra");
                            end
                            default:
                        endcase
                    end
                    3'b110:
                    begin
                        case(funct7)
                            7'b0000000: //OR
                            begin
                                registers[rd_idx] = registers[rs1_idx] | registers[rs2_idx];
                                $display("end or");
                            end
                            default:
                        endcase
                    end
                    3'b111:
                    begin
                        case (funct7)
                            7'b0000000: //AND
                            begin
                                registers[rd_idx] = registers[rs1_idx] & registers[rs2_idx];
                                $display("end and");
                            end 
                            default: 
                        endcase
                    end
                    default: 
                endcase
            end 
            7'b0000011: //I-type
            begin
                rd = instr_out[11:7];
                funct3 = instr_out[14:12];
                rs1 = instr_out[19:15];
                rd_idx = rd;
                rs1_idx = rs1;
                case (funct3)
                    3'b000: //LB
                    begin
                        
                    end
                    3'b001: //LH
                    begin
                        
                    end
                    3'b010: //LW
                    begin
                        
                    end
                    3'b100: //LBU
                    begin
                        
                    end
                    3'b101: //LHU
                    begin
                        
                    end 
                    default: 
                endcase
            end
            7'b0010011: //I-type
            begin
                rd = instr_out[11:7];
                funct3 = instr_out[14:12];
                rs1 = instr_out[19:15];
                rd_idx = rd;
                rs1_idx = rs1;
                case (funct3)
                    3'b000: //ADDI
                    begin
                        registers[rd_idx] = registers[rs1_idx] + imm_I;
                        $display("end addi");
                    end 
                    3'b001: //SLLI
                    begin
                        registers[rd_idx] = $unsigned(registers[rs1_idx]) << imm_B[4:0];
                        $display("end slli");
                    end
                    3'b010: //SLTI
                    begin
                        registers[rd_idx] = ($signed(registers[rs1_idx]) < $signed(imm_B)) ? 32'b1 : 32'b0;
                        $display("end slti");
                    end
                    3'b011: //SLTIU
                    begin
                        registers[rd_idx] = ($unsigned(registers[rs1_idx]) < $unsigned(imm_B)) ? 32'b1 : 32'b0;
                        $display("end sltiu");
                    end
                    3'b100: //XORI
                    begin
                        registers[rd_idx] = registers[rs1_idx] ^ imm_B;
                        $display("end xori");
                    end
                    3'b101:
                    begin
                        case (imm_B[12:5])
                            7'b0000000: //SRLI 
                            begin
                                registers[rd_idx] = $unsigned(registers[rs1_idx]) >> imm_B[4:0];
                                $display("end srli");
                            end
                            7'b0100000: //SRAI
                            begin
                                registers[rd_idx] = $signed(registers[rs1_idx]) >>> imm_B[4:0];
                                $display("end srli");
                            end
                            default: 
                        endcase
                         
                    end
                    3'b110: //ORI
                    begin
                        registers[rd_idx] = registers[rs1_idx] | imm_B;
                        $display("end ori");
                    end
                    3'b111: //ANDI
                    begin
                        registers[rd_idx] = registers[rs1_idx] & imm_B;
                        $display("end andi");
                    end 
                    default: 
                endcase
            end
            7'b1100111: //JALR
            begin
                rd = instr_out[11:7];
                rs1 = instr_out[19:15];
                rd_idx = rd;
                rs1_idx = rs1;
            end
            default: 
        endcase
    end
        

end

endmodule
