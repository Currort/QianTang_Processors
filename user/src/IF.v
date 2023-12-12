`include "./include/QianTang_header.v"
`include "Instr_path.v"
module IF(
    input                        rst_i         ,
    input                        clk_sys_i     ,
                 
    input                        pause_i       ,
    /* verilator lint_off UNUSEDSIGNAL */   
    input                        jump_i        ,
    input      [`REG_WIDTH-1:0]  jump_addr_i   ,

    input                        trap_enter_i         ,
    input      [`REG_WIDTH-1:0]  trap_enter_addr_i    ,
    
    input                        trap_exit_i          ,
    input      [`REG_WIDTH-1:0]  trap_exit_addr_i     ,
    /* verilator lint_on UNUSEDSIGNAL */
    output reg [31:0]            instr_o       ,
    output     [`REG_WIDTH-1:0]  pc_o          
);
    reg [`RAM_INSTRUCTION_SIZE-1:0] next_pc  ; 
    reg [`RAM_INSTRUCTION_SIZE-1:0] current_pc ;
    /* verilator lint_off UNUSEDSIGNAL */
    wire [7:0] pre_instr ;
    /* verilator lint_on UNUSEDSIGNAL */
    wire [1:0] opcode_compress;





    assign pc_o = {{(`REG_WIDTH-`RAM_INSTRUCTION_SIZE){1'b0}}, current_pc};
    assign pre_instr = instr_memory_r [next_pc];
    assign opcode_compress = pre_instr[1:0];  
 
    wire [`REG_WIDTH-1:0] pc /*verilator public_flat_rd*/ = pc_o ;  
    wire [31:0] instr /*verilator public_flat_rd*/ = instr_o;
    wire jump /*verilator public_flat_rd*/ = jump_i;
    wire pause /*verilator public_flat_rd*/ = pause_i;

    //! next_pc ctrl  / PC
    always @(posedge clk_sys_i) begin
        current_pc <= next_pc;
        if(rst_i)                           next_pc <= `RAM_ADDR_START              ;
        else if(pause_i)                    next_pc <= next_pc                        ;
        else if(jump_i)                     next_pc <= jump_addr_i      [`RAM_INSTRUCTION_SIZE-1:0]      ;
        else if(trap_enter_i)               next_pc <= trap_enter_addr_i[`RAM_INSTRUCTION_SIZE-1:0]      ;
        else if(trap_exit_i)                next_pc <= trap_exit_addr_i [`RAM_INSTRUCTION_SIZE-1:0]      ;
        else if(opcode_compress==2'b11)     next_pc <= next_pc + 4                    ;                 
        else                                next_pc <= next_pc + 2                    ; 
    end


    reg  [7:0] instr_memory_r [(2**`RAM_INSTRUCTION_SIZE)-1:0];            //? 指令存储器 8位 2^32深度
    initial begin
        // if (`MEM_INIT_OF_TEST == 1 )
            $readmemh(`INSTR_PATH, instr_memory_r, 0, 65535);
    end

    
    //! instruct memory 
    always@(posedge clk_sys_i) begin                        //? 小端模式取指
        if(rst_i) 
            instr_o[31:0]    <= 32'h00007013; //! addi a0,0 a0
        else if(pause_i) begin
            instr_o[7:0]    <= instr_memory_r [next_pc-4];
            instr_o[15:8]   <= instr_memory_r [next_pc-3];
            instr_o[23:16]  <= instr_memory_r [next_pc-2];
            instr_o[31:24]  <= instr_memory_r [next_pc-1];
        end else begin
            instr_o[7:0]    <= instr_memory_r [next_pc  ];
            instr_o[15:8]   <= instr_memory_r [next_pc+1];
            instr_o[23:16]  <= instr_memory_r [next_pc+2];
            instr_o[31:24]  <= instr_memory_r [next_pc+3];
        end

    end

endmodule //IF
