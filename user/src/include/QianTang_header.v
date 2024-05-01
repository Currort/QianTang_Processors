`ifndef QIANTANG_HEADER
    `define QIANTANG_HEADER
    //! 指令集相关
        `define RV64GC_ISA          //todo RV64GC指令集，如使用RV32GC指令集请将本行注释
        // `define RV32GC_ISA
        `ifdef RV64GC_ISA           //todo 根据指令集修改寄存器宽度
            `define REG_WIDTH 64
        `elsif RV32GC_ISA
            `define REG_WIDTH 32
        `endif
    //! 内存相关
        `define RAM_INSTRUCTION_SIZE 16         //todo 支持20位指令内存寻址，可以按需更改
        `define RAM_DATA_SIZE        16         //todo 支持32位数据内存寻址，可以按需更改
        `define RAM_ADDR_START       'h00002016 //todo 内存起始地址
        `define MEM_INIT_OF_TEST     1
        `define PRINT_ADDR           'H0000a018 //todo print 外设内存起始地址
        `define PRINT_DEPTH          'H40

    //! R_TYPE
        `define ARITHMETIC_R    7'b0110011
        `define ATOMICAL_R      7'b0101111
    //! I_TYPE
        `define ARITHMETIC_I    7'b0010011 
        `define ACCESS_I        7'b0000011
        `define EXCEPTION       7'b1110011
        `define FENCE           7'b0001111
    //! S_TYPE
        `define ACCESS_S        7'b0100011
    //! B_TYPE
        `define BRANCH_B        7'b1100011
    //! J_TYPE
        `define JAL             7'b1101111
        `define JALR            7'b1100111
    //! U-TYPE
        `define LUI             7'b0110111
        `define AUIPC           7'b0010111
    //! 64位扩展
        `define R_64_ONLY       7'b0111011
        `define I_64_ONLY       7'b0011011
    //! 压缩指令
        `define COMPRESSED_00   2'b00
        `define COMPRESSED_01   2'b01
        `define COMPRESSED_10   2'b10
                

    `define CTRL_ARITHMETIC_R_00 4'b0000
    `define CTRL_ARITHMETIC_R_01 4'b0001
    `define CTRL_ARITHMETIC_R_10 4'b0010
    `define CTRL_R_64_ONLY       4'b0011 
    `define CTRL_I_64_ONLY       4'b1100 
    `define CTRL_ARITHMETIC_I_0  4'b0100
    `define CTRL_ARITHMETIC_I_1  4'b0101
    `define CTRL_ACCESS_I        4'b0110  
    `define CTRL_ACCESS_S        4'b0111  
    `define CTRL_BRANCH_B        4'b1000
    `define CTRL_JAL             4'b1001
    `define CTRL_LUI             4'b1010
    `define CTRL_AUIPC           4'b1011
    `define CTRL_JALR            4'b1100
    `define CTRL_EXCEPTION       4'b1101
    `define CTRL_ECALL           4'b1110
    `define CTRL_WFI             4'b1111
    // `define CTRL_NOP             4'b1110

    //! R_TYPE 指令集
        //! ARITHMETIC_R 加减、逻辑  func7[0]：0 
            `define ADD_SUB        3'b000   //todo 寄存器 加法 或 减法指令  func7[5]（ 0 / 1 )
            `define SLL            3'b001   //todo 寄存器 逻辑左移
            `define SLT            3'b010   //todo 寄存器 有符号比较
            `define SLTU           3'b011   //todo 寄存器 无符号比较
            `define XOR            3'b100   //todo 寄存器 逻辑异或
            `define SRL_SRA        3'b101   //todo 寄存器 逻辑右移 或 算数右移  func7[5] （ 0 / 1 )
            `define OR             3'b110   //todo 寄存器 逻辑或
            `define AND            3'b111   //todo 寄存器 逻辑与
        //! ARITHMETIC_R 乘除拓展  func7[0]：1 
            `define MUL            3'b000   //todo 寄存器 乘法
            `define MULH           3'b001   //todo 寄存器 高位乘法
            `define MULHSU         3'b010   //todo 寄存器 有符号-无符号高位乘法
            `define MULHU          3'b011   //todo 寄存器 无符号高位乘法
            `define DIV            3'b100   //todo 寄存器 除法
            `define DIVU           3'b101   //todo 寄存器 无符号除法
            `define REM            3'b110   //todo 寄存器 求余数
            `define REMU           3'b111   //todo 寄存器 无符号求余数
        //! R_64_ONLY   64位专有R指令 32位截断
            `define ADDW_SUBW   3'b000   //todo 寄存器 加法 或 减法指令  func7[5]（ 0 / 1 )
            `define SLLW        3'b001   //todo 寄存器 逻辑左移
            `define SRLW_SRAW   3'b101   //todo 寄存器 逻辑右移 或 算数右移  func7[5] （ 0 / 1 )
            `define MULW        3'b000   //todo 寄存器 乘法        
            `define DIVW        3'b100   //todo 寄存器 除法        
            `define DIVUW       3'b101   //todo 寄存器 无符号除法  
            `define REMW        3'b110   //todo 寄存器 求余数      
            `define REMUW       3'b111   //todo 寄存器 无符号求余数
        //! ATOMICAL_R 原子指令
            `define ATOMICAL_32    3'b010               //todo  字操作 
            `define ATOMICAL_64    3'b011               //todo  双字操作
            `define LR             5'b00010             //todo  保留加载               
            `define SC             5'b00011             //todo  条件存储
            `define AMOSWAP        5'b00001             //todo  交换
            `define AMOADD         5'b00000             //todo  加
            `define AMOXOR         5'b00100             //todo  异或
            `define AMOAND         5'b01100             //todo  与
            `define AMOOR          5'b01000             //todo  或
            `define AMOMIN         5'b10000             //todo  取最小
            `define AMOMAX         5'b10100             //todo  取最大
            `define AMOMINU        5'b11000             //todo  取最小 无符号
            `define AMOMAXU        5'b11100             //todo  取最大 无符号
    //! I_TYPE 指令集
        //! ARITHMETIC_I 加减、逻辑 
            `define ADDI           3'b000   //todo 立即数 加法（有符号）
            `define SLTI           3'b010   //todo 立即数 有符号比较
            `define SLTIU          3'b011   //todo 立即数 无符号比较
            `define XORI           3'b100   //todo 立即数 逻辑异或
            `define ORI            3'b110   //todo 立即数 逻辑或
            `define ANI            3'b111   //todo 立即数 逻辑与
            `define SLLI           3'b001   //todo 立即数 逻辑左移
            `define SRLI_SRAI      3'b101   //todo 立即数 逻辑右移 或 算数右移  func7[5]（ 0 / 1 )
        //! ACCESS_I 访问存储器    
            `define LB             3'b000   //todo 读取 内存地址rst1+offset的值到 rd 中，字节型
            `define LH             3'b001   //todo 读取 内存地址rst1+offset的值到 rd 中，字型
            `define LW             3'b010   //todo 读取 内存地址rst1+offset的值到 rd 中，双字型
            `define LD             3'b011   //todo 读取 内存地址rst1+offset的值到 rd 中，四字型    
            `define LBU            3'b100   //todo 读取 内存地址rst1+offset的值 无符号扩展 到 rd 中，字节型   
            `define LHU            3'b101   //todo 读取 内存地址rst1+offset的值 无符号扩展 到 rd 中，字型
            `define LWU            3'b110   //todo 读取 内存地址rst1+offset的值 无符号扩展 到 rd 中，双字型   
        //! I_64_ONLY    64位专有I指令 32位截断
            `define ADDIW       3'b000   //todo 立即数 加法（有符号）                          
            `define SLLIW       3'b001   //todo 立即数 逻辑左移                               
            `define SRLIW_SRAIW 3'b101   //todo 立即数 逻辑右移 或 算数右移  func7[5]（ 0 / 1 )
        //! EXCEPTION 异常指令
            //! CSR
                `define CSRRW          3'b001 //todo 读后写   
                `define CSRRS          3'b010 //todo 读后置位(按位或) 
                `define CSRRC          3'b011 //todo 读后清除(按位与) 
                `define CSRRWI         3'b101 //todo 
                `define CSRRSI         3'b110 //todo 
                `define CSRRCI         3'b111 //todo 
            //! 非 CSR
                `define NON_CSR   3'b000 //todo 非读写CSR寄存器指令
                    `define ECALL    12'b000000000000               //todo 引发 环境调用异常请求执行环境
                    `define EBREAK   12'b000000000001               //todo 引发 断点异常请求调试器
                    `define MRET     12'b001100000010               //todo 中断返回
    //! S_TYPE 指令集
        //! ACCESS_S 访问存储器
            `define SB             3'b000   //todo 存储 rst2 的值到内存地址rst1+offset的主存中，字节型
            `define SH             3'b001   //todo 存储 rst2 的值到内存地址rst1+offset的主存中，字型
            `define SW             3'b010   //todo 存储 rst2 的值到内存地址rst1+offset的主存中，双字型
            `define SD             3'b011   //todo 存储 rst2 的值到内存地址rst1+offset的主存中，四字型
    //! B_TYPE 指令集    
        //! BRANCH_B 分支    
            `define BEQ            3'b000   //todo 相等时跳转   
            `define BNE            3'b001   //todo 不相等时跳转
            `define BLT            3'b100   //todo 小于时跳转
            `define BGE            3'b101   //todo 大于等于时跳转
            `define BLTU           3'b110   //todo 无符号小于时跳转
            `define BGEU           3'b111   //todo 无符号大于等于时跳转
    //! 压缩指令
        //! COMPRESSED_00
            `define C_ADDI4SPN 3'b000
            `define C_FLD      3'b001
            `define C_LW       3'b010
            `define C_LD       3'b011
            `define C_FSD      3'b101
            `define C_SW       3'b110
            `define C_SD       3'b111
        //! COMPRESSED_01
            `define C_ADDI_NOP          3'b000                     
            `define C_ADDIW             3'b001                     
            `define C_LI                3'b010                     
            `define C_ADDI16SP_LUI      3'b011                     
            //! ALU简单运算 
            `define C01_100             3'b100
                //! C01_100 内部指令
                `define C_SRLI          2'b00                    
                `define C_SRAI          2'b01                     
                `define C_ANDI          2'b10
                `define C01_100_11      2'b11 
                //! C01_100_11 内部指令
                    `define C_SUB           3'b000                    
                    `define C_XOR           3'b001                    
                    `define C_OR            3'b010                              
                    `define C_AND           3'b011                    
                    `define C_SUBW          3'b100                    
                    `define C_ADDW          3'b101                    
            `define C_J                 3'b101         
            `define C_BEQZ              3'b110                     
            `define C_BNEZ              3'b111   
        //! COMPRESSED_10
            `define C_SLLI              3'b000
            `define C_FLDSP             3'b001
            `define C_LWSP              3'b010
            `define C_LDSP              3'b011
            `define C_10_100            3'b100
                //! C_10_100 内部指令
                `define C_JR            3'b001
                `define C_MV            3'b000
                `define C_EBREAK        3'b111
                `define C_JALR          3'b101
                `define C_ADD           3'b100
            `define C_FSDSP            3'b101
            `define C_SWSP             3'b110
            `define C_SDSP             3'b111

    //! 已实现拓展
        `define  A 1
        `define  B 0
        `define  C 1
        `define  D 1
        `define  E 0
        `define  F 1
        `define  G 0
        `define  H 0
        `define  I 1
        `define  J 0
        `define  K 0
        `define  L 0
        `define  M 1
        `define  N 0
        `define  O 0
        `define  P 0
        `define  Q 1
        `define  R 0
        `define  S 0
        `define  T 0
        `define  U 0
        `define  V 0
        `define  W 0
        `define  X 0
        `define  Y 0
        `define  Z 0
        `define  EXTENSIONS 26'b`Z`Y`X`W`V`U`T`S`R`Q`P`O`N`M`L`K`J`I`H`G`F`E`D`C`B`A
    //! CSR 相关定义
        `define  CSR_ADDR_MISA              12'h301
        `define  CSR_ADDR_MVENDORID         12'hF11
        `define  CSR_ADDR_MARCHID           12'hF12     
        `define  CSR_ADDR_MIMPID            12'hF13       
        `define  CSR_ADDR_MHARTID           12'hF14      
        `define  CSR_ADDR_MSTATUS           12'h300  
        `define  CSR_ADDR_MTVEC             12'h305  
        `define  CSR_ADDR_MIP               12'h344  
        `define  CSR_ADDR_MIE               12'h304   
        `define  CSR_ADDR_MCAUSE            12'h342  
        `define  CSR_ADDR_MEPC              12'h341  
        `define  CSR_ADDR_MVTAL             12'h343  
        `define  CSR_ADDR_MCOUNTEREN        12'h306  
        `define  CSR_ADDR_MCOUNTINHIBIT     12'h320  
        `define  CSR_ADDR_MCYCLE            12'hB00  
        `define  CSR_ADDR_MINSTRET          12'hB02

        //! 内部寄存器定义
            //! mstatus 
                `define MSTATUS_MIE   mstatus[3]
                `define MSTATUS_MPIE  mstatus[7] 
            //! mip 
                `define MIP_MEIP  mip[11] 
                `define MIP_MTIP  mip[ 7] 
                `define MIP_MSIP  mip[ 3] 
            //! mie 
                `define MIE_MEIE  mie[11] 
                `define MIE_MTIE  mie[ 7] 
                `define MIE_MSIE  mie[ 3]   
            //! mcause
                `define MCAUSE_INTERRUPT   mcause[`REG_WIDTH-1]
                `define MCAUSE_CODE        mcause[`REG_WIDTH-2:0]
                //! 陷阱编码
                    //!中断
                    `define SUPERVISOR_S_INTR                        1
                    `define    MACHINE_S_INTR                        3
                    `define SUPERVISOR_T_INTR                        5
                    `define    MACHINE_T_INTR                        7
                    `define SUPERVISOR_E_INTR                        9
                    `define    MACHINE_E_INTR                       11
                    `define SUPERVISOR_S_EXCE                       13
                    //! 异常
                    `define INSTRUCTION_ADDRESS_MISALIGNED           0                       
                    `define INSTRUCTION_ACCESS_FAULT                 1                   
                    `define ILLEGAL_INSTRUCTION                      2           
                    `define BREAKPOINT                               3   
                    `define LOAD_ADDRESS_MISALIGNED                  4               
                    `define LOAD_ACCESS_FAULT                        5           
                    `define STORE_AMO_ADDRESS_MISALIGNED             6                       
                    `define STORE_AMO_ACCESS_FAULT                   7               
                    `define ECALL_U                                  8
                    `define ECALL_S                                  9
                    `define ECALL_M                                 11
                    `define INSTRUCTION_PAGE_FAULT                  12               
                    `define LOAD_PAGE_FAULT                         13       
                    `define STORE_AMO_PAGE_FAULT                    15               

    //! MTIME 时钟频率
    `define MTIME_FREQUENCY 'd50_000_000
    //! MMIO地址
    `define MMIO_MTIME     `RAM_DATA_SIZE'h00000100
    `define MMIO_MTIMECMP  `RAM_DATA_SIZE'h00000108
    `define MMIO_MSIP      `RAM_DATA_SIZE'h000001A0


    //! 模块测试
        // `define DIVIDER_TEST 
        // `define MULTIPLIER_TEST
`endif
