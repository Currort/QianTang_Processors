`include "./include/QianTang_header.v"
`include "./ALU_submodule/Divider.v"
`include "./ALU_submodule/Multiplier.v"

module ALU(
    input                            clk_sys_i          ,

    input      [`REG_WIDTH-1:0]      rst1_read_i        ,

    input      [`REG_WIDTH-1:0]      rst2_read_i        ,
    input      [`REG_WIDTH-1:0]      imm_i              ,
    input      [`REG_WIDTH-1:0]      pc_i               ,
    input      [4:0]                 rd_i               ,
    input      [7:0]                 ctrl_i             ,
    output                           pause_o            ,
    output reg                       jump_o             ,
    output reg [`REG_WIDTH-1:0]      jump_addr_o        ,
    output reg [`REG_WIDTH-1:0]      result_o           ,
    output reg [`REG_WIDTH-1:0]      save_data_o        ,
    output reg [4:0]                 rd_o               ,
    output reg [7:0]                 ctrl_o             ,

    input                            csr_write_ena_i    ,
    input      [11:0]                csr_write_addr_i   ,
    input      [`REG_WIDTH-1:0]      csr_read_data_i    ,
    output reg                       csr_write_ena_o    ,
    output reg [11:0]                csr_write_addr_o   ,
    output reg [`REG_WIDTH-1:0]      csr_write_data_o   ,
    output reg                       ALU_ena_forwarding_o  ,


    input  [4:0]                     forwarding_rst1_addr_i        ,
    input  [4:0]                     forwarding_rst2_addr_i        ,
    //! ALU前递
        input                            ALU_ena_forwarding_i  ,
        input [4:0]                      ALU_addr_forwarding_i ,
        input [`REG_WIDTH-1:0]           ALU_data_forwarding_i ,
    //! Memory前递
        input                            MEM_ena_forwarding_i  ,
        input [4:0]                      MEM_addr_forwarding_i ,
        input [`REG_WIDTH-1:0]           MEM_data_forwarding_i ,

    //! Memory_Load前递
        input                            LD_ena_forwarding_i  ,
        input [4:0]                      LD_addr_forwarding_i ,
        input [`REG_WIDTH-1:0]           LD_data_forwarding_i ,

    //! Write_back前递
        input                            WB_ena_forwarding_i  ,
        input [4:0]                      WB_addr_forwarding_i ,
        input [`REG_WIDTH-1:0]           WB_data_forwarding_i 
);

    wire for_ena /*verilator public_flat_rd*/= ALU_ena_forwarding_o;
    wire [`REG_WIDTH-1:0] result  /*verilator public_flat_rd*/ =result_o;
    wire [4:0] rd      /*verilator public_flat_rd*/ =rd_o;
//! 控制信号输入
    wire [3:0] ctrl_opcode;
    wire [2:0] ctrl_funct;
    wire       ctrl_trunc ;
    assign ctrl_opcode = ctrl_i[6:3];
    assign ctrl_funct  = ctrl_i[2:0];
    assign ctrl_trunc  = ctrl_i[7];
//! 预处理
    //! 前递
        reg [`REG_WIDTH-1:0] rst1_forwarding;
        reg [`REG_WIDTH-1:0] rst2_forwarding;
    //! 截断
    reg [`REG_WIDTH-1:0] rst1_pre;
    reg [`REG_WIDTH-1:0] rst2_pre;
    reg [`REG_WIDTH-1:0] imm_pre;

//! 模块信号
    //! 比较信号
        reg  compare_temp ;
    //! CLA加法器
        reg  [`REG_WIDTH-1:0]   CLA_a     ;
        reg  [`REG_WIDTH-1:0]   CLA_b     ;
        reg                     CLA_ci    ;
        wire [`REG_WIDTH-1:0]   CLA_s     ;
        /* verilator lint_off UNUSEDSIGNAL */
        wire                    CLA_co    ; 
        /* verilator lint_on UNUSEDSIGNAL */
    //! CLA PC加法器
        reg  [`REG_WIDTH-1:0]   CLA_pc;
        reg  [`REG_WIDTH-1:0]   CLA_offset;
        wire [`REG_WIDTH-1:0]   pc_w     ;
    //! 跳转指令 
        reg [1:0] flush_cnt ;
    //! 多周期指令
        wire                    start   ;
        wire             	    finish_o;
        //! wallace乘法器
            reg                     start_M   = 0;
            reg                     unsign_ctrl_A_r;
            reg                     unsign_ctrl_B_r;
            reg [`REG_WIDTH-1:0]    mul_A;
            reg [`REG_WIDTH-1:0]    mul_B;
            wire [`REG_WIDTH*2-1:0] mul_S;
            wire                    finish_mul_o=1;
        //! SRT4除法器
            reg                     start_D   = 0;
            reg                     sign_ctrl_r;
            reg  [`REG_WIDTH-1:0]   divd_r = 0;
            reg  [`REG_WIDTH-1:0]   div_r  = 1;
            wire [`REG_WIDTH-1:0] 	q_o;
            wire [`REG_WIDTH-1:0] 	rem_o;
            wire             	    finish_div_o;
        assign start    = (start_M || start_D);
        assign finish_o = (finish_mul_o && finish_div_o);
        assign pause_o  = start;

//! 逻辑位移
    reg  [`REG_WIDTH-1:0] shift_in;
    reg  [5:0]            shift_length;
    reg                   shift_direction;
    wire [`REG_WIDTH-1:0] shift_out;
    assign shift_out = (shift_direction)? shift_in >> shift_length : shift_in << shift_length;
    //! 算术位移
    reg  signed [`REG_WIDTH-1:0] signed_shift_in;
    wire [`REG_WIDTH-1:0] signed_shift_out;
    assign signed_shift_out = signed_shift_in >>> shift_length;

//! 实现逻辑
    //! 组合逻辑
    //! 数据预处理

    always @(*) begin
        if     (forwarding_rst1_addr_i == 0) rst1_forwarding = 0 ;
        else if((forwarding_rst1_addr_i == ALU_addr_forwarding_i) && ALU_ena_forwarding_i) rst1_forwarding = ALU_data_forwarding_i ;
        else if((forwarding_rst1_addr_i == LD_addr_forwarding_i) && LD_ena_forwarding_i) rst1_forwarding = LD_data_forwarding_i ;
        else if((forwarding_rst1_addr_i == MEM_addr_forwarding_i) && MEM_ena_forwarding_i) rst1_forwarding = MEM_data_forwarding_i ;
        else if((forwarding_rst1_addr_i == WB_addr_forwarding_i) && WB_ena_forwarding_i) rst1_forwarding = WB_data_forwarding_i ;
        else rst1_forwarding = rst1_read_i;

        if     (forwarding_rst2_addr_i == 0) rst2_forwarding = 0 ;
        else if((forwarding_rst2_addr_i == ALU_addr_forwarding_i) && ALU_ena_forwarding_i) rst2_forwarding = ALU_data_forwarding_i ;
        else if((forwarding_rst2_addr_i == LD_addr_forwarding_i) && LD_ena_forwarding_i) rst2_forwarding = LD_data_forwarding_i ;
        else if((forwarding_rst2_addr_i == MEM_addr_forwarding_i) && MEM_ena_forwarding_i) rst2_forwarding = MEM_data_forwarding_i ;
        else if((forwarding_rst2_addr_i == WB_addr_forwarding_i) && WB_ena_forwarding_i) rst2_forwarding = WB_data_forwarding_i ;
        else rst2_forwarding = rst2_read_i;
    end

    always @(*) begin
        if(ctrl_trunc) begin
            rst1_pre = {{32{rst1_forwarding[`REG_WIDTH/2-1]}}, rst1_forwarding[`REG_WIDTH/2-1:0]};
            rst2_pre = {{32{rst2_forwarding[`REG_WIDTH/2-1]}}, rst2_forwarding[`REG_WIDTH/2-1:0]};
            imm_pre  = {{32{imm_i[`REG_WIDTH/2-1]}},       imm_i      [`REG_WIDTH/2-1:0]};
        end else begin
            rst1_pre  = rst1_forwarding;
            rst2_pre  = rst2_forwarding;
            imm_pre   = imm_i      ;
        end

    end


    //! 数据通路
    always @(*) begin
        case (ctrl_opcode)
            `CTRL_ARITHMETIC_R_00:begin //!逻辑位移、加、逻辑运算
                case (ctrl_funct)
                    `ADD_SUB       :begin //! 加法 调用加法器
                        CLA_a    = rst1_pre;
                        CLA_b    = rst2_pre;
                        CLA_ci   = 0          ;
                    end `SLL       :begin //! 逻辑左移 调用位移逻辑
                        shift_direction = 0; 
                        shift_in        = rst1_pre     ;
                        shift_length    = rst2_pre[5:0];
                    end `SLT       :begin //! 小于置1 调用加法器做减法 判断最高位
                        CLA_a    = rst1_pre;
                        CLA_b    = ~rst2_pre;
                        CLA_ci   = 1          ;
                    end `SLTU      :begin //! 无符号小于置1 先判断二者最高位大小，再去掉最高位进行符号拓展调用加法器做减法 判断最高位
                        case ({rst1_pre[`REG_WIDTH-1], rst2_pre[`REG_WIDTH-1]})
                            2'b00: begin
                                CLA_a    = {1'b0,rst1_pre[`REG_WIDTH-2:0]};
                                CLA_b    = {1'b1,~rst2_pre[`REG_WIDTH-2:0]};
                                CLA_ci   = 1          ;
                            end
                            2'b11:begin
                                CLA_a    = {1'b0,rst1_pre[`REG_WIDTH-2:0]};
                                CLA_b    = {1'b1,~rst2_pre[`REG_WIDTH-2:0]};
                                CLA_ci   = 1          ;
                            end 
                            default :begin
                            end
                        endcase
                    end `XOR       :begin //! 逻辑异或
                    end `SRL_SRA   :begin //! 逻辑右移 调用位移逻辑
                        shift_direction = 1; 
                        shift_in        = rst1_pre     ;
                        shift_length    = rst2_pre[5:0];
                    end `OR        :begin //! 逻辑或
                    end `AND       :begin //! 逻辑与
                    end
                endcase
            end
            `CTRL_ARITHMETIC_R_01:begin //! 算术位移、减
                case (ctrl_funct)
                    `ADD_SUB       :begin //! 减法法 调用加法器做减法
                        CLA_a    = rst1_pre;
                        CLA_b    = ~rst2_pre;
                        CLA_ci   = 1          ;
                    end `SRL_SRA   :begin //! 算数右移 调用算数位移逻辑
                        signed_shift_in = rst1_pre      ;
                        shift_length    = rst2_pre[5:0] ;
                    end
                    default :begin
                    end
                endcase
            end
            `CTRL_ARITHMETIC_R_10:begin //! 乘、除、取余 
            end
            `CTRL_ARITHMETIC_I_0:begin //! 立即数逻辑位移、加、逻辑运算
                case (ctrl_funct)
                    `ADDI          :begin //! 立即数加法 调用加法器
                        CLA_a    = rst1_pre;
                        CLA_b    = {imm_pre}    ;
                        CLA_ci   = 0          ;
                    end `SLTI      :begin //! 立即数小于置1 调用加法器做减法 判断最高位
                        CLA_a    = rst1_pre;
                        CLA_b    = imm_pre;
                        CLA_ci   = 0          ;
                    end `SLTIU     :begin //! 立即数无符号小于置1 先判断二者最高位大小，再去掉最高位进行符号拓展调用加法器做减法 判断最高位
                        case ({rst1_pre[`REG_WIDTH-1], imm_pre[`REG_WIDTH-1]})
                            2'b00: begin
                                CLA_a    = {1'b0,rst1_pre[`REG_WIDTH-2:0]};
                                CLA_b    = {1'b1,~imm_pre[`REG_WIDTH-2:0]};
                                CLA_ci   = 1          ;
                            end
                            2'b11:begin
                                CLA_a    = {1'b0,rst1_pre[`REG_WIDTH-2:0]};
                                CLA_b    = {1'b1,~imm_pre[`REG_WIDTH-2:0]};
                                CLA_ci   = 1          ;
                            end default :begin
                            end
                        endcase
                    end `XORI      :begin //! 逻辑异或    
                    end `ORI       :begin //! 逻辑或
                    end `ANI       :begin //! 逻辑与
                    end `SLLI      :begin //! 立即数左移 调用位移逻辑
                        shift_direction = 0; 
                        shift_in        = rst1_pre      ;
                        shift_length    = imm_pre[5:0]       ;   
                    end `SRLI_SRAI :begin //! 立即数右移 调用位移逻辑
                        shift_direction = 1; 
                        shift_in        = rst1_pre     ;
                        shift_length    = imm_pre[5:0];
                    end     
                endcase
            end
            `CTRL_ARITHMETIC_I_1:begin //! 立即数算术位移 调用算数位移逻辑
                signed_shift_in = rst1_pre      ;
                shift_length    = imm_pre[5:0] ;
            end
            `CTRL_ACCESS_I      :begin //! 访问存储器 读取
                CLA_a    = rst1_pre;
                CLA_b    = {imm_pre}    ;
                CLA_ci   = 0          ;
            end 
            `CTRL_ACCESS_S      :begin //! 访问存储器 存储
                CLA_a    = rst1_pre;
                CLA_b    = {imm_pre}    ;
                CLA_ci   = 0          ;
            end 
            `CTRL_BRANCH_B           :begin //! 分支跳转
                CLA_pc       =  pc_i;
                CLA_offset   =  imm_pre;
                case (ctrl_i[2:1])
                    2'b11 :begin    //! 有符号无符号 分别处理
                        case ({rst1_pre[`REG_WIDTH-1], rst2_pre[`REG_WIDTH-1]})
                            2'b00: begin
                                CLA_a    = {1'b0,rst1_pre[`REG_WIDTH-2:0]};
                                CLA_b    = {1'b1,~rst2_pre[`REG_WIDTH-2:0]};
                                CLA_ci   = 1          ;
                                compare_temp = CLA_s[`REG_WIDTH-1]     ;
                            end
                            2'b01: compare_temp = 1;
                            2'b10: compare_temp = 0;
                            2'b11:begin
                                CLA_a    = {1'b0,rst1_pre[`REG_WIDTH-2:0]};
                                CLA_b    = {1'b1,~rst2_pre[`REG_WIDTH-2:0]};
                                CLA_ci   = 1          ;
                                compare_temp = CLA_s[`REG_WIDTH-1]     ;
                            end
                        endcase
                    end 
                    default :begin
                        CLA_a    = rst1_pre;
                        CLA_b    = ~rst2_pre;
                        CLA_ci   = 1          ;
                        compare_temp = CLA_s[`REG_WIDTH-1]     ;
                    end
                endcase
                case(ctrl_funct)
                    `BEQ :begin
                    end 
                    `BNE :begin 
                    end 
                    `BLT :begin 
                    end 
                    `BGE :begin 
                    end 
                    `BLTU:begin 
                    end 
                    `BGEU:begin 
                    end 
                    default :begin
                    end
                endcase
            end
            `CTRL_EXCEPTION               :begin //! 异常处理
                case (ctrl_funct)
                    `NON_CSR :begin
                        
                    end
                    `CSRRW  : begin 
                    end
                    `CSRRS  : begin
                    end
                    `CSRRC  : begin
                    end
                    `CSRRWI : begin
                    end
                    `CSRRSI : begin
                    end
                    `CSRRCI : begin
                    end
                    default :begin
                    end
                endcase
            end 
            `CTRL_JAL                :begin //! 跳转并连接
                CLA_pc       =  pc_i;
                CLA_offset   =  imm_pre;
            end 
            `CTRL_JALR               :begin //! 跳转并寄存器连接
                CLA_pc       =  rst1_pre;
                CLA_offset   =  imm_pre;
            end 
            `CTRL_LUI                :begin //! 高位立即数加载
            end
            `CTRL_AUIPC              :begin //! PC加立即数
                CLA_pc       =  pc_i;
                CLA_offset   =  imm_pre;
            end
            default:begin
            end
        endcase
    end
    //! 时序逻辑
    always @(posedge clk_sys_i) begin
        if(start==1)begin
            if (finish_o) begin
                start_M  <= 0 ;
                start_D  <= 0 ;
                case(ctrl_opcode)
                    `CTRL_ARITHMETIC_R_10:begin
                        case(ctrl_funct)
                            `MUL     :result_o   <=(ctrl_trunc)?{{32{mul_S[`REG_WIDTH/2-1]}},mul_S[`REG_WIDTH/2-1:0]}: mul_S[`REG_WIDTH-1:0];
                            `MULH    :result_o   <= mul_S[`REG_WIDTH*2-1:`REG_WIDTH];
                            `MULHSU  :result_o   <= mul_S[`REG_WIDTH*2-1:`REG_WIDTH];
                            `MULHU   :result_o   <= mul_S[`REG_WIDTH*2-1:`REG_WIDTH];
                            `DIV     :result_o   <=(ctrl_trunc)?{{32{q_o[`REG_WIDTH/2-1]}},q_o[`REG_WIDTH/2-1:0]}: q_o;
                            `DIVU    :result_o   <=(ctrl_trunc)?{{32{q_o[`REG_WIDTH/2-1]}},q_o[`REG_WIDTH/2-1:0]}: q_o;
                            `REM     :result_o   <=(ctrl_trunc)?{{32{rem_o[`REG_WIDTH/2-1]}},rem_o[`REG_WIDTH/2-1:0]}: rem_o;
                            `REMU    :result_o   <=(ctrl_trunc)?{{32{rem_o[`REG_WIDTH/2-1]}},rem_o[`REG_WIDTH/2-1:0]}: rem_o;
                            default  :begin
                            end
                        endcase
                    end 
                    default :begin
                    end
                endcase
            end
        end else if( jump_o || (flush_cnt != 'b0)) begin  //! 冲刷2级流水线
            if(jump_o)begin
                jump_o <= 0;
                flush_cnt <= 2'd2;
            end else flush_cnt <= flush_cnt-1;
        end else begin
            rd_o     <= rd_i        ;
            ctrl_o   <= ctrl_i      ;
            csr_write_ena_o <= csr_write_ena_i;
            case (ctrl_opcode)
                `CTRL_ARITHMETIC_R_00:begin //!逻辑位移、加、逻辑运算
                    jump_o <= 0;
                    ALU_ena_forwarding_o <= 1'b1;
                    case (ctrl_funct)
                        `ADD_SUB       :begin //! 加法 调用加法器
                            result_o <=(ctrl_trunc)? {{32{CLA_s[`REG_WIDTH/2-1]}},CLA_s[`REG_WIDTH/2-1:0]}:CLA_s ;
                        end `SLL       :begin //! 逻辑左移 调用位移逻辑
                            result_o <=(ctrl_trunc)? {{32{shift_out[`REG_WIDTH/2-1]}},shift_out[`REG_WIDTH/2-1:0]}:shift_out ;
                        end `SLT       :begin //! 小于置1 调用加法器做减法 判断最高位
                            result_o <= {63'b0,CLA_s[`REG_WIDTH-1]}     ;
                        end `SLTU      :begin //! 无符号小于置1 先判断二者最高位大小，再去掉最高位进行符号拓展调用加法器做减法 判断最高位
                            case ({rst1_pre[`REG_WIDTH-1], rst2_pre[`REG_WIDTH-1]})
                                2'b00: begin
                                    result_o <= {63'b0,CLA_s[`REG_WIDTH-1]}     ;
                                end
                                2'b01: result_o <= 1;
                                2'b10: result_o <= 0;
                                2'b11:begin
                                    result_o <= {63'b0,CLA_s[`REG_WIDTH-1]}     ;
                                end
                            endcase
                        end `XOR       :begin //! 逻辑异或
                            result_o <= rst1_pre ^ rst2_pre;
                        end `SRL_SRA   :begin //! 逻辑右移 调用位移逻辑
                            result_o <=(ctrl_trunc)? {{32{shift_out[`REG_WIDTH/2-1]}},shift_out[`REG_WIDTH/2-1:0]}:shift_out ;
                        end `OR        :begin //! 逻辑或
                            result_o <= rst1_pre | rst2_pre;
                        end `AND       :begin //! 逻辑与
                            result_o <= rst1_pre & rst2_pre;
                        end
                    endcase
                end
                `CTRL_ARITHMETIC_R_01:begin //! 算术位移、减 
                    jump_o <= 0;
                    ALU_ena_forwarding_o <= 1'b1;
                    case (ctrl_funct)
                        `ADD_SUB       :begin //! 减法法 调用加法器做减法
                            result_o <=(ctrl_trunc)? {{32{CLA_s[`REG_WIDTH/2-1]}},CLA_s[`REG_WIDTH/2-1:0]}:CLA_s ;
                        end `SRL_SRA   :begin //! 算数右移 调用算数位移逻辑
                            result_o <=(ctrl_trunc)? {{32{signed_shift_out[`REG_WIDTH/2-1]}},signed_shift_out[`REG_WIDTH/2-1:0]}:signed_shift_out ;
                        end
                        default :begin
                        end
                    endcase
                end
                `CTRL_ARITHMETIC_R_10:begin //! 乘、除、取余 
                    jump_o <= 0;
                    ALU_ena_forwarding_o <= 1'b0;
                    case (ctrl_funct)
                        `MUL        :begin //! 乘法
                            start_M  <= 1 ;
                            unsign_ctrl_A_r <= 0;
                            unsign_ctrl_B_r <= 0;
                            mul_A           <= rst1_pre;
                            mul_B           <= rst2_pre;
                        end `MULH   :begin //! 高位乘法
                            start_M  <= 1 ;
                            unsign_ctrl_A_r <= 0;
                            unsign_ctrl_B_r <= 0;
                            mul_A           <= rst1_pre;
                            mul_B           <= rst2_pre;
                        end `MULHSU :begin //! 有符号-无符号高位乘法
                            start_M  <= 1 ;
                            unsign_ctrl_A_r <= 0;
                            unsign_ctrl_B_r <= 1;
                            mul_A           <= rst1_pre;
                            mul_B           <= rst2_pre;
                        end `MULHU  :begin //! 无符号高位乘法
                            start_M  <= 1 ;
                            unsign_ctrl_A_r <= 1;
                            unsign_ctrl_B_r <= 1;
                            mul_A           <= rst1_pre;
                            mul_B           <= rst2_pre;
                        end `DIV    :begin //! 除法
                            start_D  <= 1 ;
                            sign_ctrl_r     <= 1;
                            div_r           <= rst1_pre;
                            divd_r          <= rst2_pre;
                        end `DIVU   :begin //! 无符号除法
                            start_D  <= 1 ;
                            sign_ctrl_r     <= 0;
                            div_r           <= (ctrl_trunc)?{{32{1'b0}},rst1_pre[`REG_WIDTH/2-1:0]} :rst1_pre;
                            divd_r          <= (ctrl_trunc)?{{32{1'b0}},rst2_pre[`REG_WIDTH/2-1:0]} :rst2_pre;
                        end `REM    :begin //! 求余数
                            start_D  <= 1 ;
                            sign_ctrl_r     <= 1;
                            div_r           <= rst1_pre;
                            divd_r          <= rst2_pre;
                        end `REMU   :begin //! 无符号求余数
                            start_D  <= 1 ;
                            sign_ctrl_r     <= 0;
                            div_r           <= (ctrl_trunc)?{{32{1'b0}},rst1_pre[`REG_WIDTH/2-1:0]} :rst1_pre;
                            divd_r          <= (ctrl_trunc)?{{32{1'b0}},rst2_pre[`REG_WIDTH/2-1:0]} :rst2_pre;
                        end
                        default :begin
                        end
                    endcase
                end
                `CTRL_ARITHMETIC_I_0:begin //! 立即数逻辑位移、加、逻辑运算
                    jump_o <= 0;
                    ALU_ena_forwarding_o <= 1'b1;
                    case (ctrl_funct)
                        `ADDI          :begin //! 立即数加法 调用加法器
                            result_o <=(ctrl_trunc)? {{32{CLA_s[`REG_WIDTH/2-1]}},CLA_s[`REG_WIDTH/2-1:0]}:CLA_s ;
                        end `SLTI      :begin //! 立即数小于置1 调用加法器做减法 判断最高位
                            result_o <= {63'b0,CLA_s[`REG_WIDTH-1]}     ;
                        end `SLTIU     :begin //! 立即数无符号小于置1 先判断二者最高位大小，再去掉最高位进行符号拓展调用加法器做减法 判断最高位
                            case ({rst1_pre[`REG_WIDTH-1], imm_pre[`REG_WIDTH-1]})
                                2'b00: begin
                                    result_o <= {63'b0,CLA_s[`REG_WIDTH-1]}     ;
                                end
                                2'b01: result_o <= 1;
                                2'b10: result_o <= 0;
                                2'b11:begin
                                    result_o <= {63'b0,CLA_s[`REG_WIDTH-1]}     ;
                                end
                            endcase
                        end `XORI      :begin //! 逻辑异或    
                            result_o <= rst1_pre ^ imm_pre;
                        end `ORI       :begin //! 逻辑或
                            result_o <= rst1_pre | imm_pre;
                        end `ANI       :begin //! 逻辑与
                            result_o <= rst1_pre & imm_pre;
                        end `SLLI      :begin //! 立即数左移 调用位移逻辑
                            result_o <=(ctrl_trunc)? {{32{shift_out[`REG_WIDTH/2-1]}},shift_out[`REG_WIDTH/2-1:0]}:shift_out ;
                        end `SRLI_SRAI :begin //! 立即数右移 调用位移逻辑
                            result_o <=(ctrl_trunc)? {{32{shift_out[`REG_WIDTH/2-1]}},shift_out[`REG_WIDTH/2-1:0]}:shift_out ;
                        end
                        default :begin
                        end     
                    endcase
                end
                `CTRL_ARITHMETIC_I_1:begin //! 立即数算术位移 调用算数位移逻辑
                    jump_o <= 0;
                    ALU_ena_forwarding_o <= 1'b1;
                    result_o <=(ctrl_trunc)? {{32{signed_shift_out[`REG_WIDTH/2-1]}},signed_shift_out[`REG_WIDTH/2-1:0]}:signed_shift_out ;
                end
                `CTRL_ACCESS_I      :begin //! 访问存储器 读取
                    jump_o <= 0;
                    ALU_ena_forwarding_o <= 1'b0;
                    result_o <= CLA_s     ; 
                end 
                `CTRL_ACCESS_S      :begin //! 访问存储器 存储
                    jump_o <= 0;
                    ALU_ena_forwarding_o <= 1'b0;
                    result_o <= CLA_s     ;
                    save_data_o   <= rst2_pre  ;
                end 
                `CTRL_BRANCH_B           :begin //! 分支跳转
                    ALU_ena_forwarding_o <= 1'b0;
                    case(ctrl_funct)
                        `BEQ :begin
                            jump_o <= (CLA_s == 64'b0) ;
                            jump_addr_o  <= pc_w;
                        end 
                        `BNE :begin 
                            jump_o <= (CLA_s != 64'b0) ;
                            jump_addr_o  <= pc_w;
                        end 
                        `BLT :begin 
                            jump_o <= compare_temp ;
                            jump_addr_o  <= pc_w;
                        end 
                        `BGE :begin 
                            jump_o <= ~compare_temp ;
                            jump_addr_o  <= pc_w;
                        end 
                        `BLTU:begin 
                            jump_o <= compare_temp ;
                            jump_addr_o  <= pc_w;
                        end 
                        `BGEU:begin 
                            jump_o <= ~compare_temp ;
                            jump_addr_o  <= pc_w;
                        end default :begin
                            end
                    endcase
                end
                `CTRL_EXCEPTION               :begin //! 异常处理
                    jump_o      <= 0 ;
                    ALU_ena_forwarding_o <= 1'b1;
                    case (ctrl_funct)
                        `NON_CSR :begin
                            
                        end
                        `CSRRW  : begin 
                            csr_write_addr_o <= csr_write_addr_i;
                            csr_write_data_o <= rst1_pre ;
                            result_o   <= csr_read_data_i ;
                        end
                        `CSRRS  : begin
                            csr_write_addr_o <= csr_write_addr_i;
                            csr_write_data_o <= (rst1_pre | csr_read_data_i);
                            result_o   <= csr_read_data_i ;
                        end
                        `CSRRC  : begin
                            csr_write_addr_o <= csr_write_addr_i;
                            csr_write_data_o <= (rst1_pre & csr_read_data_i);
                            result_o   <= csr_read_data_i ;
                        end
                        `CSRRWI : begin
                            csr_write_addr_o <= csr_write_addr_i;
                            csr_write_data_o <= imm_pre ;
                            result_o   <= csr_read_data_i ;
                        end
                        `CSRRSI : begin
                            csr_write_addr_o <= csr_write_addr_i;
                            csr_write_data_o <= (imm_pre | csr_read_data_i);
                            result_o   <= csr_read_data_i ;
                        end
                        `CSRRCI : begin
                            csr_write_addr_o <= csr_write_addr_i;
                            csr_write_data_o <= (imm_pre & csr_read_data_i);
                            result_o   <= csr_read_data_i ;
                        end 
                        default :begin
                        end
                    endcase
                end 
                `CTRL_JAL                :begin //! 跳转并连接
                    jump_o      <= 1 ;
                    ALU_ena_forwarding_o <= 1'b0;
                    jump_addr_o <=  pc_w  ;
                    result_o    <=  pc_i+4     ;
                end 
                `CTRL_JALR               :begin //! 跳转并寄存器连接
                    jump_o      <= 1 ;
                    ALU_ena_forwarding_o <= 1'b1;
                    jump_addr_o <=  pc_w  ;
                    result_o    <=  pc_i+4;
                end 
                `CTRL_LUI                :begin //! 高位立即数加载
                    jump_o      <= 0 ;
                    ALU_ena_forwarding_o <= 1'b1;
                    result_o    <=  imm_pre;
                end
                `CTRL_AUIPC              :begin //! PC加立即数
                    jump_o      <= 0 ;
                    ALU_ena_forwarding_o <= 1'b1;
                    result_o    <=  pc_w;
                end
                default:begin
                end
            endcase
        end
    end



//! 模块例化
    /* verilator lint_off PINMISSING */
    CLA #(
	    .WIDTH  (64)
	)CLA_for_add(
        .A  	( CLA_a   ),
        .B  	( CLA_b   ),
        .Ci 	( CLA_ci  ),
        .S  	( CLA_s   ),
        .Co 	( CLA_co  )
    );

    CLA #(
	    .WIDTH  (64)
	)CLA_for_pc(
        .A  	( CLA_pc    ),
        .B  	( CLA_offset ),
        .Ci 	( 0  ),
        .S  	( pc_w   )
    );
    /* verilator lint_off PINMISSING */
    Multiplier u_Multiplier(
        .A             	( mul_A           ),
        .B             	( mul_B           ),
        .unsign_ctrl_A_i( unsign_ctrl_A_r ),
        .unsign_ctrl_B_i( unsign_ctrl_B_r ),
        .S             	( mul_S           )
    );
    

    Divider Divider_alu(
        .clk_i    	( clk_sys_i ),
        .start_i  	( start_D   ),
        .sign_ctrl_i( sign_ctrl_r),
        .div_i    	( div_r     ),
        .divd_i   	( divd_r    ),
        .q_o      	( q_o       ),
        .rem_o    	( rem_o     ),
        .finish_o 	( finish_div_o  )
    );




endmodule //ALU
