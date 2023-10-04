`ifndef RISC_V_INSTR_DEF
    `define RISC_V_INSTR_DEF
    `define RV64GC_ISA          //todo RV64GC指令集，如使用RV32GC指令集请将本行注释
    `define RV32GC_ISA

    `ifdef RV64GC_ISA           //todo 根据指令集修改寄存器宽度
        `define REG_WIDTH 64
    `elsif RV32GC_ISA
        `define REG_WIDTH 32
    `endif

    `define RAM_SIZE 32         //todo 支持32位内存寻址，可以按需更改

    `define R_TYPE 7'b0110011
    `define I_TYPE 7'b0000011
    `define S_TYPE 7'b0100011
    `define U_TYPE 7'b0110111
    `define B_TYPE 7'b1100111
    `define J_TYPE 7'b1101111


    //! R_TYPE 指令集
    `define ADD/SUB    3'b000   //todo 寄存器 加法 或 减法指令  （ 0 / 1 )
    `define SLL        3'b001   //todo 寄存器 逻辑左移
    `define SLT        3'b010   //todo 寄存器 有符号比较
    `define SLTU       3'b011   //todo 寄存器 无符号比较
    `define XOR        3'b100   //todo 寄存器 逻辑异或
    `define SRL/SRA    3'b101   //todo 寄存器 逻辑右移 或 算数右移  （ 0 / 1 )
    `define OR         3'b110   //todo 寄存器 逻辑或
    `define AND        3'b111   //todo 寄存器 逻辑与

    //! I_TYPE 指令集
    `define ADDI       3'b000   //todo 立即数 加法（有符号）
    `define SLTI       3'b010   //todo 立即数 有符号比较
    `define SLTIU      3'b011   //todo 立即数 无符号比较
    `define XORI       3'b100   //todo 立即数 逻辑异或
    `define ORI        3'b110   //todo 立即数 逻辑或
    `define ANI        3'b111   //todo 立即数 逻辑与
    `define SLLI       3'b001   //todo 立即数 逻辑左移
    `define SRLI/SRAI  3'b101   //todo 立即数 逻辑右移 或 算数右移  （ 0 / 1 )

    `define LB         3'b000   //todo 读取 内存地址rst1+offset的值到 rd 中，字节型
    `define LH         3'b001   //todo 读取 内存地址rst1+offset的值到 rd 中，字型
    `define LW         3'b010   //todo 读取 内存地址rst1+offset的值到 rd 中，双字型    
    `define LBU        3'b010   //todo 读取 内存地址rst1+offset的值 无符号扩展 到 rd 中，双字型   
    `define LHU        3'b010   //todo 读取 内存地址rst1+offset的值 无符号扩展 到 rd 中，双字型   

    //! S_TYPE 指令集
    `define SB         3'b000   //todo 存储 rst2 的值到内存地址rst1+offset的主存中，字节型
    `define SH         3'b001   //todo 存储 rst2 的值到内存地址rst1+offset的主存中，字型
    `define SW         3'b010   //todo 存储 rst2 的值到内存地址rst1+offset的主存中，双字型

    //! L
`endif