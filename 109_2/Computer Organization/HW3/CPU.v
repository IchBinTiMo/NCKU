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
// reg [6:0] opcode;
// reg [4:0] rd;
// reg [2:0] funct3;
// reg [4:0] rs1;
// reg [4:0] rs2;
// reg [6:0] funct7;
reg [31:0] tmp;
// reg [31:0] rs1_data;
// reg [31:0] rs2_data;
reg [63:0] result;
reg [31:0] pc;
reg in;

integer i;

wire [6:0] opcode = instr_out[6:0];
wire [4:0] rd = instr_out[11:7];
wire [4:0] rs1 = instr_out[19:15];
wire [4:0] rs2 = instr_out[24:20];
wire [2:0] funct3 = instr_out[14:12];
wire [6:0] funct7 = instr_out[31:25];
wire [31:0] imm_I = {{20{instr_out[31]}}, instr_out[31:20]};
wire [31:0] imm_S = {{20{instr_out[31]}}, instr_out[31:25], instr_out[11:7]};
wire [31:0] imm_B = {{20{instr_out[31]}}, instr_out[7], instr_out[30:25], instr_out[11:8], 1'b0};
wire [31:0] imm_U = {instr_out[31:12], 12'b0};
wire [31:0] imm_J = {{12{instr_out[31]}}, instr_out[19:12], instr_out[20], instr_out[30:21], 1'b0};


initial
begin
    instr_read = 1;
    instr_addr = 32'b0;
    pc = 32'b0;
    data_read = 0;
    in = 0;
end
always @(posedge clk) 
begin    
    if(~rst && rd != 5'b0)
    begin
        case (opcode)
            7'b0110011: //R-type
            begin
                case (funct3)
                    3'b000: //ADD, SUB, MUL
                    begin
                        case(funct7)
                            7'b0000000: //ADD
                            begin
                                registers[$unsigned(rd)] = registers[$unsigned(rs1)] + registers[$unsigned(rs2)]; 
                                $display("end add");             
                                instr_read = 1;
                                pc = pc + 32'h00000004;        
                            end
                            7'b0100000: //SUB
                            begin
                                registers[$unsigned(rd)] = registers[$unsigned(rs1)] - registers[$unsigned(rs2)];
                                $display("end sub");             
                                instr_read = 1;
                                pc = pc + 32'h00000004;
                            end
                            7'b0000001: //MUL
                            begin
                                result = $signed(registers[$unsigned(rs1)]) * $signed(registers[$unsigned(rs2)]);
                                registers[$unsigned(rd)] = result[31:0];
                                $display("end mul");             
                                instr_read = 1;
                                pc = pc + 32'h00000004;
                            end
                            default: ;
                        endcase
                    end 
                    3'b001: //SLL, MULH
                    begin
                        case(funct7)
                            7'b0000000: //SLL
                            begin
                                registers[$unsigned(rd)] = $unsigned(registers[$unsigned(rs1)]) << registers[$unsigned(rs2)][4:0];
                                $display("end sll");             
                                instr_read = 1;
                                pc = pc + 32'h00000004;
                            end
                            7'b0000001: //MULH
                            begin
                                result = $signed(registers[$unsigned(rs1)]) * $signed(registers[$unsigned(rs2)]);
                                registers[$unsigned(rd)] = result[63:32];
                                $display("end mulh");             
                                instr_read = 1;
                                pc = pc + 32'h00000004;
                            end
                            default: ;
                        endcase
                    end
                    3'b010: //SLT
                    begin
                    	registers[$unsigned(rd)] = ($signed(registers[$unsigned(rs1)])<$signed(registers[$unsigned(rs2)]))?32'b1 : 32'b0;
                    	$display("end slt");             
                        instr_read = 1;
                        pc = pc + 32'h00000004;
                    end
                    3'b011: //SLTU
                    begin
                        registers[$unsigned(rd)] = ($unsigned(registers[$unsigned(rs1)])<$unsigned(registers[$unsigned(rs2)]))?32'b1 : 32'b0;
                        $display("end sltu");             
                        instr_read = 1;
                        pc = pc + 32'h00000004;
                    end
                    3'b100: //XOR
                    begin
                        registers[$unsigned(rd)] = registers[$unsigned(rs1)] ^ registers[$unsigned(rs2)];
                        $display("end xor");             
                        instr_read = 1;
                        pc = pc + 32'h00000004;
                    end
                    3'b101: //SRL, SRA
                    begin
                        case(funct7)
                            7'b0000000: //SRL
                            begin
                                registers[$unsigned(rd)] = $unsigned(registers[$unsigned(rs1)]) >> registers[$unsigned(rs2)][4:0];
                                $display("end srl");              
                                instr_read = 1;
                                pc = pc + 32'h00000004;
                            end
                            7'b0100000: //SRA
                            begin
                                registers[$unsigned(rd)] = $signed(registers[$unsigned(rs1)]) >>> registers[$unsigned(rs2)][4:0];
                                $display("end sra");              
                                instr_read = 1;
                                pc = pc + 32'h00000004;
                            end
                            default: ;
                        endcase
                    end
                    3'b110: //OR
                    begin
                        registers[$unsigned(rd)] = registers[$unsigned(rs1)] | registers[$unsigned(rs2)];
                        $display("end or");              
                        instr_read = 1;
                        pc = pc + 32'h00000004;
                    end
                    3'b111: //AND
                    begin
                        registers[$unsigned(rd)] = registers[$unsigned(rs1)] & registers[$unsigned(rs2)];
                        $display("end and");              
                        instr_read = 1;
                        pc = pc + 32'h00000004;
                    end
                    default: $display("default r"); 
                endcase
            end 
            7'b0000011: //I-type
            begin
                case (funct3)
                    3'b000: //LB
                    begin
                        if(data_read==0)
                        begin
                            data_addr = registers[$unsigned(rs1)] + imm_I;
                            data_read = 1;
                            instr_read = 0;
                            $display("start lb");
                        end
                        if(data_read==1)
                        begin
                            registers[$unsigned(rd)] = {{24{data_out[31]}}, data_out[7:0]};
                            data_read = 0;
                            instr_read = 1;
                            pc = pc + 32'h00000004;
                            $display("end lb");
                        end                        
                    end
                    3'b001: //LH
                    begin
                        if(data_read==0)
                        begin
                            data_addr = registers[$unsigned(rs1)] + imm_I;
                            data_read = 1;
                            instr_read = 0;
                            $display("start lh");
                        end
                        if(data_read==1)
                        begin
                            registers[$unsigned(rd)] = {{16{data_out[31]}}, data_out[15:0]};
                            data_read = 0;
                            instr_read = 1;
                            $display("end lh");
                        end  
                    end
                    3'b010: //LW
                    begin
                        if(data_read==0)
                        begin
                            data_addr = registers[$unsigned(rs1)] + imm_I;
                            data_read = 1;
                            instr_read = 0;
                            $display("start lw");
                        end
                        if(data_read==1)
                        begin
                            registers[$unsigned(rd)] = data_out;
                            data_read = 0;
                            instr_read = 1;
                            $display("end lw");
                        end  
                    end
                    3'b100: //LBU
                    begin
                        if(data_read==0)
                        begin
                            data_addr = registers[$unsigned(rs1)] + imm_I;
                            data_read = 1;
                            instr_read = 0;
                            $display("start lbu");
                        end
                        if(data_read==1)
                        begin
                            registers[$unsigned(rd)] = {24'b0, data_out[7:0]};
                            data_read = 0;
                            instr_read = 1;
                            $display("end lbu");
                        end  
                    end
                    3'b101: //LHU
                    begin
                        if(data_read==0)
                        begin
                            data_addr = registers[$unsigned(rs1)] + imm_I;
                            data_read = 1;
                            instr_read = 0;
                            $display("start lhu");
                        end
                        if(data_read==1)
                        begin
                            registers[$unsigned(rd)] = {16'b0, data_out[15:0]};
                            data_read = 0;
                            instr_read = 1;
                            $display("end lhu");
                        end
                    end 
                    default: $display("default i"); 
                endcase
            end
            7'b0010011: //I-type
            begin
                case (funct3)
                    3'b000: //ADDI
                    begin
                        in = 1;
                        registers[$unsigned(rd)] = registers[$unsigned(rs1)] + imm_I;
                        $display("end addi");
                        instr_read = 1;
                        pc = pc + 32'h00000004;
                    end 
                    3'b001: //SLLI
                    begin
                        registers[$unsigned(rd)] = $unsigned(registers[$unsigned(rs1)]) << imm_I[4:0];
                        $display("end slli");
                        instr_read = 1;
                        pc = pc + 32'h00000004;
                    end
                    3'b010: //SLTI
                    begin
                        registers[$unsigned(rd)] = ($signed(registers[$unsigned(rs1)]) < $signed(imm_I)) ? 32'b1 : 32'b0;
                        $display("end slti");
                        instr_read = 1;
                        pc = pc + 32'h00000004;
                    end
                    3'b011: //SLTIU
                    begin
                        registers[$unsigned(rd)] = ($unsigned(registers[$unsigned(rs1)]) < $unsigned(imm_I)) ? 32'b1 : 32'b0;
                        $display("end sltiu");
                        instr_read = 1;
                        pc = pc + 32'h00000004;
                    end
                    3'b100: //XORI
                    begin
                        registers[$unsigned(rd)] = registers[$unsigned(rs1)] ^ imm_I;
                        $display("end xori");
                        instr_read = 1;
                        pc = pc + 32'h00000004;
                    end
                    3'b101: //SRLI, SRAI
                    begin
                        case (imm_I[12:5])
                            7'b0000000: //SRLI 
                            begin
                                registers[$unsigned(rd)] = $unsigned(registers[$unsigned(rs1)]) >> imm_I[4:0];
                                $display("end srli");
                        instr_read = 1;
                        pc = pc + 32'h00000004;
                            end
                            7'b0100000: //SRAI
                            begin
                                registers[$unsigned(rd)] = $signed(registers[$unsigned(rs1)]) >>> imm_I[4:0];
                                $display("end srli");
                                instr_read = 1;
                                pc = pc + 32'h00000004;
                            end
                            default: ; 
                        endcase
                         
                    end
                    3'b110: //ORI
                    begin
                        registers[$unsigned(rd)] = registers[$unsigned(rs1)] | imm_I;
                        $display("end ori");
                        instr_read = 1;
                        pc = pc + 32'h00000004;
                    end
                    3'b111: //ANDI
                    begin
                        registers[$unsigned(rd)] = registers[$unsigned(rs1)] & imm_I;
                        $display("end andi");
                        instr_read = 1;
                        pc = pc + 32'h00000004;
                    end 
                    default: $display("default i"); 
                endcase
            end
            7'b1100111: //JALR
            begin
                tmp = pc;
                pc = registers[$unsigned(rs1)] + imm_I;
                pc = {pc[31:1], 1'b0};                
                registers[$unsigned(rd)] = tmp + 32'h00000004;
                data_in = registers[$unsigned(rd)];
                data_write = 4'b1111;
                instr_read = 1;
                $display("end jalr");
            end
            7'b0100011: //S-type:
            begin
                case (funct3)
                    3'b000: //SB
                    begin
                        
                    end 
                    3'b001: //SH
                    begin
                        
                    end
                    3'b010: //SW
                    begin
                        data_addr = registers[$unsigned(rs1)] + imm_S;
                        data_in = registers[$unsigned(rs2)];
                        data_write = 4'b1111;
                        $display("end sw");
                    end
                    default: $display("default s");
                endcase
                instr_read = 1;
                pc = pc + 32'h00000004;
            end
            7'b1100011: //B-type
            begin
                case (funct3)
                    3'b000: //BEQ
                    begin
                        pc = (registers[$unsigned(rs1)]==registers[$unsigned(rs2)])? pc + imm_B : pc + 32'h00000004;
                        $display("end beq");
                    end
                    3'b001: //BNE
                    begin
                        pc = (registers[$unsigned(rs1)]!=registers[$unsigned(rs2)])? pc + imm_B : pc + 32'h00000004;
                        $display("end bne");
                    end
                    3'b100: //BLT
                    begin
                        pc = ($signed(registers[$unsigned(rs1)])<$signed(registers[$unsigned(rs2)]))? pc + imm_B : pc + 32'h00000004;
                        $display("end blt");
                    end
                    3'b101: //BGE
                    begin
                        pc = ($signed(registers[$unsigned(rs1)])>=$signed(registers[$unsigned(rs2)]))? pc + imm_B : pc + 32'h00000004;
                        $display("end bge");
                    end
                    3'b110: //BLTU
                    begin
                        pc = ($unsigned(registers[$unsigned(rs1)])<$unsigned(registers[$unsigned(rs2)]))? pc + imm_B : pc + 32'h00000004;
                        $display("end bltu");
                    end
                    3'b111: //BGEU
                    begin
                        pc = ($unsigned(registers[$unsigned(rs1)])>=$unsigned(registers[$unsigned(rs2)]))? pc + imm_B : pc + 32'h00000004;
                        $display("end bgeu");
                    end
                    default: $display("default b");
                endcase
                instr_read = 1;
            end
            7'b0010111: //AUIPC
            begin
                registers[$unsigned(rd)] = pc+ imm_U;
                data_in = registers[$unsigned(rd)];
                data_write = 4'b1111;
                instr_read = 1;
                $display("end auipc");
            end
            7'b0110111: //LUI
            begin
                registers[$unsigned(rd)] = imm_U;
                data_in = registers[$unsigned(rd)];
                data_write = 4'b1111;
                instr_read = 1;
                $display("end lui");
            end
            7'b1101111: //JAL
            begin
                registers[$unsigned(rd)] = pc + 32'h00000004;
                pc = pc + imm_J;
                instr_read = 1;
                $display("end jal");
            end
            default: $display("invalid opcode"); 
        endcase
        instr_addr = pc;
    end
end

endmodule
