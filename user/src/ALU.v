`include "RISC_V_instr_def.v"

module ALU(
    input             clk_sys_i      ,
    input [`REG_WIDTH-1:0]      rst1_read_i      ,
    input [`REG_WIDTH-1:0]      rst2_read_i      ,
    input [`REG_WIDTH-1:0]      imm_i            ,
    input [4:0]       rd_i              ,
    input [3:0]       funct_i        ,
    output [`REG_WIDTH-1:0]     alu_r
);

wire  cla_4;

always @(clk_sys_i) begin
end

always @(*) begin
    case (funct_i[2:0])
        ADD          :begin
            if(funct_i[3])begin
                rst1_read_i = rst1_
            end

        end SLL      :begin

        end SLT      :begin

        end SLTU     :begin

        end XOR      :begin

        end SRL/SRA  :begin

        end OR       :begin

        end AND      :begin

        end ADDI     :begin

        end SLTI     :begin

        end SLTIU    :begin    

        end XORI     :begin     

        end ORI      :begin

        end ANI      :begin

        end SLLI     :begin

        end SRLI/SRAI:begin

        end     
        default:begin
        end
    endcase
end


endmodule //ALU