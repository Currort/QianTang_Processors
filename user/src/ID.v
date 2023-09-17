//! 该模块实现了指令译码，支持 RV32I 指令集
//! 未优化方案：通过预译码减少 选择器电路 翻转

`include "RISC_V_instr_def.v"

module ID(
    input               clk_sys_i      ,
    input   [31:0]      instr_i,
    input   [31:0]      rst1_i,
    input   [31:0]      rst2_i,
    output  [4:0]           rst1_addr_o      ,
    output  [4:0]           rst2_addr_o      ,
    output  reg [31:0]      rst1_read_o,
    output  reg [31:0]      rst2_read_o,
    output  reg [4:0]      rd_o
    );

    wire opcode = instr_i[6:0];
    wire rd     = instr_i[11:7];
    wire funct3 = instr_i[14:12];
    wire rst1   = instr_i[19:15];
    wire rst2   = instr_i[24:20];
    wire funct7 = instr_i[31:25];

    reg [31:0] rst1_read_o;
    reg [31:0] rst2_read_o;
    reg [4:0] rd_r;

    always @(posedge clk_sys_i) begin
        case (opcode)
            R_TYPE: begin 
                rst1_r <=rst1_i;
                rst2_r <=rst2_i;
            end
            // I_TYPE: 
            // S_TYPE:
            // B_TYPE:
            // U_TYPE:
            // J_TYPE:
            // default:
        endcase
    end

endmodule //ID
