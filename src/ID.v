//! 该模块实现了指令译码，支持 RV64GC 指令集 ()
//! 未优化方案：通过预译码减少 选择器电路 翻转
`include "include/QianTang_header.v"
// `include "./C_instr_decode.v"
module ID(
    input                                   clk_sys_i            ,
    input                                   pause_i              ,
    input   [31:0]                          instr_i              ,    
    input   [`REG_WIDTH-1:0]                rst1_i               ,
    input   [`REG_WIDTH-1:0]                rst2_i               ,
    input   [`REG_WIDTH-1:0]                pc_i                 ,
    output  [4:0]                           rst1_addr_o          ,
    output  [4:0]                           rst2_addr_o          ,
    output  reg [`REG_WIDTH-1:0]            rst1_read_o          ,
    output  reg [`REG_WIDTH-1:0]            rst2_read_o          ,
    output  reg [`REG_WIDTH-1:0]            imm_o                ,
    output  reg [`REG_WIDTH-1:0]            pc_o                 ,
    output  reg [4:0]                       rd_o                 ,
    output  reg [7:0]                       ctrl_o               ,
    output                                  csr_read_ena_o       ,
    output  [11:0]                          csr_read_addr_o      ,
    input   [`REG_WIDTH-1:0]                csr_read_data_i      ,
    output  reg                             csr_write_ena_o      ,
    output  reg [11:0]                      csr_write_addr_o     ,
    output  reg [`REG_WIDTH-1:0]            csr_read_data_o      ,
    output  reg [4:0]                       forwarding_rst1_addr_o      ,
    output  reg [4:0]                       forwarding_rst2_addr_o      ,
    input                                   Cache_miss_i
    );
//! ctrl_o 由 是否截断 + (opcode + func7类型总数编码) + func3  组成 
    //! R--操作寄存器: ARITHMETIC_R(0000000、0000001、0100000)  共 4 类
    //! I--操作寄存器：ARITHMETIC_I(0000000、0100000) 、 ACCESS_I          共 3 类
    //! S--操作寄存器：ACCESS_S                                           共 1 类
    //! B--操作寄存器：BRANCH_B                                           共 1 类
    //! U--操作寄存器：LUI 、 AUIPC                                       共 2 类
    //! J--操作寄存器: JAL                                                共 1 类
    //! 综上(opcode + func7类型总数编码) 共 12 类 4bit
    wire [31:0] instr ;
    reg  [31:0] instr_r;
    wire [15:0] instr_c;
    wire [31:0] instr_unfold;
    wire [31:0] instr_pre;
    //? 完整指令
    wire [6:0]            opcode  = instr[6:0];
    wire [4:0]            rd      = instr[11:7];
    wire [2:0]            funct3  = instr[14:12];
    wire [4:0]            rst1    = instr[19:15];
    wire [4:0]            rst2    = instr[24:20];
    /* verilator lint_off UNUSEDSIGNAL */
    wire [6:0]            funct7  = instr[31:25];
    wire [11:0]           funct_e = instr[31:20];
    /* verilator lint_on UNUSEDSIGNAL */
    wire [`REG_WIDTH-1:0] imm_I   = {{(`REG_WIDTH-12){instr[31]}}, instr[31:20]};
    wire [`REG_WIDTH-1:0] imm_S   = {{(`REG_WIDTH-12){instr[31]}}, instr[31:25], instr[11:7]};
    wire [`REG_WIDTH-1:0] imm_B   = {{(`REG_WIDTH-13){instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [`REG_WIDTH-1:0] imm_U   = {{(`REG_WIDTH-32){instr[31]}}, instr[31:12], 12'b0};
    wire [`REG_WIDTH-1:0] imm_J   = {{(`REG_WIDTH-21){instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21],1'b0};
    wire [`REG_WIDTH-1:0] imm_CSR = {{(`REG_WIDTH- 5){1'b0}}, instr[19:15]};
    assign instr_c    = instr_i[15:0];
    assign instr_pre  = (instr_i[1:0]==2'b11) ? instr_i : instr_unfold;
    assign instr      = (pause_i|Cache_miss_i) ? instr_r : instr_pre ;

    assign rst1_addr_o=rst1;
    assign rst2_addr_o=rst2;

    assign csr_read_ena_o  = ( opcode == `EXCEPTION )  && (funct3 != `NON_CSR) ;
    assign csr_read_addr_o = instr[31:20] ;

    always @(posedge clk_sys_i) begin
        instr_r <= (pause_i|Cache_miss_i) ? instr_r : instr_pre;
    end


    //? debug vpi抓取信号 
        wire [31:0]            instr_ID              /*verilator public_flat_rd*/   =  instr       ;
        wire [6:0]             opcode_ID             /*verilator public_flat_rd*/   =  opcode      ;                       
        wire [4:0]             rd_ID                 /*verilator public_flat_rd*/   =  rd          ;
        wire [2:0]             funct3_ID             /*verilator public_flat_rd*/   =  funct3      ;
        wire [4:0]             rst1_ID               /*verilator public_flat_rd*/   =  rst1        ;
        wire [4:0]             rst2_ID               /*verilator public_flat_rd*/   =  rst2        ;
        wire [6:0]             funct7_ID             /*verilator public_flat_rd*/   =  funct7      ;
        wire [11:0]            funct_e_ID            /*verilator public_flat_rd*/   =  funct_e     ;
        wire [`REG_WIDTH-1:0]  imm_ID                /*verilator public_flat_rd*/   =  imm_o       ; 
        wire [`REG_WIDTH-1:0]  rst1_read_ID          /*verilator public_flat_rd*/   =  rst1_i      ;
        wire [`REG_WIDTH-1:0]  rst2_read_ID          /*verilator public_flat_rd*/   =  rst2_i      ;





    always @(posedge clk_sys_i) begin
        csr_write_ena_o  <= csr_read_ena_o  ;
        csr_write_addr_o <= csr_read_addr_o ;
        pc_o        <= (pause_i|Cache_miss_i) ? pc_o : ((instr_c[15:12] == 4'b1001)&&(instr_c[6:0] == 7'b0000010)) ? pc_i-2 : pc_i;
        forwarding_rst1_addr_o <= rst1_addr_o;
        forwarding_rst2_addr_o <= rst2_addr_o;
        case (opcode)
            `ARITHMETIC_R: begin 
                rst1_read_o     <= rst1_i;
                rst2_read_o     <= rst2_i;
                rd_o            <= rd    ;
                ctrl_o[2:0] <= funct3;
                if(funct7[0]==1)      ctrl_o[6:3] <= `CTRL_ARITHMETIC_R_10;
                else if(funct7[5]==1) ctrl_o[6:3] <= `CTRL_ARITHMETIC_R_01;
                else                  ctrl_o[6:3] <= `CTRL_ARITHMETIC_R_00;
                ctrl_o[7] <= 0;
            end
            `R_64_ONLY: begin 
                rst1_read_o     <= rst1_i;
                rst2_read_o     <= rst2_i;
                rd_o            <= rd    ;
                ctrl_o[2:0] <= funct3;
                if(funct7[0]==1)      ctrl_o[6:3] <= `CTRL_ARITHMETIC_R_10;
                else if(funct7[5]==1) ctrl_o[6:3] <= `CTRL_ARITHMETIC_R_01;
                else                  ctrl_o[6:3] <= `CTRL_ARITHMETIC_R_00;
                ctrl_o[7] <= 1;
            end
            `ARITHMETIC_I: begin
                imm_o       <= imm_I ;
                rst1_read_o <= rst1_i;
                rd_o        <= rd    ;
                ctrl_o[2:0] <= funct3;
                if((funct7[5]==1) && (funct3[1:0]==2'b01))ctrl_o[6:3] <= `CTRL_ARITHMETIC_I_1;
                else ctrl_o[6:3] <= `CTRL_ARITHMETIC_I_0;
                ctrl_o[7] <= 0;
            end
            `ACCESS_I: begin
                imm_o       <= imm_I ;
                rst1_read_o <= rst1_i;
                rd_o        <= rd    ;
                ctrl_o[2:0] <= funct3;
                ctrl_o[6:3] <= `CTRL_ACCESS_I;
                ctrl_o[7] <= 0;
            end
            `I_64_ONLY : begin
                imm_o       <= imm_I ;
                rst1_read_o <= rst1_i;
                rd_o        <= rd    ;
                ctrl_o[2:0] <= funct3;
                if((funct7[5]==1)&& (funct3[1:0]==2'b01)) ctrl_o[6:3] <= `CTRL_ARITHMETIC_I_1;
                else ctrl_o[6:3] <= `CTRL_ARITHMETIC_I_0;
                ctrl_o[7] <= 1;
            end
            `ACCESS_S: begin
                imm_o       <= imm_S ;
                rst1_read_o <= rst1_i;
                rst2_read_o <= rst2_i;
                ctrl_o[2:0] <= funct3;
                ctrl_o[6:3] <= `CTRL_ACCESS_S;
                ctrl_o[7] <= 0;
            end
            `BRANCH_B: begin
                imm_o       <= imm_B ;
                rst1_read_o <= rst1_i;
                rst2_read_o <= rst2_i;
                ctrl_o[2:0] <= funct3;
                ctrl_o[6:3] <= `CTRL_BRANCH_B;
                ctrl_o[7] <= 0;
            end
            `EXCEPTION:begin
                rst1_read_o <= rst1_i;
                imm_o       <= imm_CSR ;
                rd_o        <= rd;
                csr_read_data_o  <= (csr_read_ena_o)? csr_read_data_i : csr_read_data_o;
                ctrl_o[2:0] <= funct3;
                if(funct3 != `NON_CSR) ctrl_o[6:3] <= `CTRL_EXCEPTION;
                else if (funct_e == 0) ctrl_o[6:3] <= `CTRL_ECALL;
                else if (funct_e == 12'h105) ctrl_o[6:3] <= `CTRL_WFI;
                else $warning("undefined instruction !  opencode : EXCEPTION  ");
                ctrl_o[7] <= 0;
            end
            `LUI:begin
                imm_o       <= imm_U;
                rd_o        <= rd   ;
                ctrl_o[6:3] <= `CTRL_LUI;
                ctrl_o[7] <= 0;
            end
            `AUIPC:begin
                imm_o       <= imm_U;
                rd_o        <= rd   ;
                ctrl_o[6:3] <= `CTRL_AUIPC;
                ctrl_o[7] <= 0;
            end
            `JAL:begin
                imm_o       <= imm_J;
                rd_o        <= rd ;
                ctrl_o[6:3] <= `CTRL_JAL;
                ctrl_o[7] <= 0;
            end
            `JALR:begin
                imm_o       <= imm_I;
                rd_o        <= rd   ;
                rst1_read_o <= rst1_i;
                ctrl_o[6:3] <= `CTRL_JALR;
                ctrl_o[7] <= 0;
            end 
            `FENCE:begin
                imm_o       <= 0;
                rst1_read_o <= 0;
                rd_o        <= 0;
                ctrl_o[2:0] <= 0;
                ctrl_o[6:3] <= `CTRL_ARITHMETIC_I_0;
                ctrl_o[7] <= 0;
            end
            default: $warning("undefined instruction ! opencode : %7b",opcode);
        endcase
    end

    
    C_instr_decode u_C_instr_decode(
        .instr_i        	( instr_c       ),
        .instr_unfold_o 	( instr_unfold  )
    );
    
endmodule //ID
