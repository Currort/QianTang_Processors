//! 该模块实现了指令译码，支持 RV32ISBUJ 指令集 ()
//! 未优化方案：通过预译码减少 选择器电路 翻转

`include "RISC_V_instr_def.v"
`include "64_32_switch.v"
module ID(
    input               clk_sys_i            ,
    input   [31:0]      instr_i              ,    
    input   [31:0]      rst1_i               ,
    input   [31:0]      rst2_i               ,
    output  [4:0]           rst1_addr_o      ,
    output  [4:0]           rst2_addr_o      ,
    output  reg [31:0]      rst1_read_o      ,
    output  reg [31:0]      rst2_read_o      ,
    output  reg [31:0]      imm_o               ,
    output  reg [4:0]      rd_o              ,
    output  reg [3:0]      funct_o
    );

    wire [6:0]  opcode = instr_i[6:0];
    wire [4:0]  rd     = instr_i[11:7];
    wire [2:0]  funct3 = instr_i[14:12];
    wire [4:0]  rst1   = instr_i[19:15];
    wire [4:0]  rst2   = instr_i[24:20];
    wire [6:0]  funct7 = instr_i[31:25];
    wire [11:0] imm_I  = instr_i[31:20];
    wire [11:0] imm_S  = {instr_i[31:25],instr_i[11:7]};
    wire [11:0] imm_B  = {instr_i[31],instr_i[7],instr_i[30:25],instr_i[11:8]};
    wire [19:0] imm_U  = instr_i[31:12];
    wire [19:0] imm_J  = {instr_i[31],instr_i[19:12],instr_i[20],instr_i[30:21]};

    assign rst1_addr_o=rst1;
    assign rst2_addr_o=rst2;


    always @(posedge clk_sys_i) begin
        case (opcode)
            `R_TYPE: begin 
                rst1_read_o <= rst1_i;
                rst2_read_o <= rst2_i;
                rd_o        <= rd    ;
                funct_o     <= {funct7[5],funct3};
            end
            `I_TYPE: begin
                imm_o       <= imm_I ;
                rst1_read_o <= rst1_i;
                rd_o        <= rd    ;
                funct_o     <= {funct7[5],funct3};
            end
            `S_TYPE: begin
                imm_o       <= imm_S ;
                rst1_read_o <= rst1_i;
                rst2_addr_o <= rst2_i;
            end
            `B_TYPE: begin
                imm_o       <= imm_B ;
                rst1_read_o <= rst1_i;
                rst2_read_o <= rst2_i;
            end
            `U_TYPE:begin
                imm_o       <= imm_U;
                rd_o        <= rd   ;
            end
            `J_TYPE:begin
                imm_o       <= imm_J;
                rd_o        <= rd   ;
            end
            default:begin
            end
        endcase
    end

endmodule //ID
