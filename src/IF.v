`include "./include/QianTang_header.v"

module IF#(
    parameter SETS_BIT       = 2  , 
    parameter TAG_BIT        = 9  ,
    parameter INDEX_BIT      = 2  ,
    parameter OFFSET_BIT     = 5  ,
    parameter CACHE_DATA_BIT = 32 ,
    parameter SRAM_DATA_BIT  = 256
)(
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
    output     [`REG_WIDTH-1:0]  pc_o          ,
    input                        Cache_miss_i,
    output                       IF_Cache_miss_o,
    input                        ecall_i,

    output                         SRAM_ena_o ,
    output                         SRAM_wea_o ,
    output [SRAM_ADDR_BIT-1:0]                 SRAM_addr_o,
    output [SRAM_DATA_BIT-1:0]               SRAM_data_o,
    input  [SRAM_DATA_BIT-1:0]               SRAM_data_i

);
    localparam SRAM_ADDR_BIT  = `RAM_INSTRUCTION_SIZE - $clog2(SRAM_DATA_BIT/8);

    assign IF_Cache_miss_o = IF_CACHE_miss_r | IF_CACHE_miss;

    reg [`RAM_INSTRUCTION_SIZE-1:0] next_pc  ; 
    reg [`RAM_INSTRUCTION_SIZE-1:0] current_pc ;
    /* verilator lint_off UNUSEDSIGNAL */
    /* verilator lint_on UNUSEDSIGNAL */
    wire [1:0] opcode_compress;

    assign pc_o = {{(`REG_WIDTH-`RAM_INSTRUCTION_SIZE){1'b0}}, current_pc};
    assign opcode_compress = instr_o[1:0];  
 
    wire [`REG_WIDTH-1:0] pc /*verilator public_flat_rd*/ = pc_o ;  
    wire [31:0] instr /*verilator public_flat_rd*/ = instr_o;
    wire jump /*verilator public_flat_rd*/ = jump_i;
    wire pause /*verilator public_flat_rd*/ = pause_i;
    wire miss  /*verilator public_flat_rd*/ = Cache_miss_i;
    wire IF_miss /*verilator public_flat_rd*/ = IF_Cache_miss_o;
    //! next_pc ctrl  / PC
    always @(posedge clk_sys_i) begin
        current_pc <=(IF_Cache_miss_o) ? current_pc: next_pc;
    end
    always @(*) begin
        if(rst_i)                              next_pc = `RAM_ADDR_START                   ;
        else if(jump_i)                        next_pc = jump_addr_i      [`RAM_INSTRUCTION_SIZE-1:0]      ;
        else if(trap_enter_i)                  next_pc = trap_enter_addr_i[`RAM_INSTRUCTION_SIZE-1:0]      ;
        else if(trap_exit_i)                   next_pc = trap_exit_addr_i [`RAM_INSTRUCTION_SIZE-1:0]      ;
        else if(pause_i|Cache_miss_i|ecall_i)  next_pc = current_pc                        ;
        // else if(addr_latched|IF_CACHE_miss_r)  next_pc = current_pc                        ;
        else if(opcode_compress==2'b11)        next_pc = current_pc + 4                    ;                 
        else                                   next_pc = current_pc + 2                    ; 
    end

    /* verilator lint_off UNUSEDSIGNAL */
    wire IF_CACHE_miss;
    reg  IF_CACHE_miss_r;
    /* verilator lint_on UNUSEDSIGNAL */
    always @(posedge clk_sys_i ) begin
        IF_CACHE_miss_r <= IF_CACHE_miss;
    end

    //! instruct memory 
    always@(posedge clk_sys_i) begin                        //? 小端模式取指
        instr_o   <=(IF_Cache_miss_o)? instr_o : CACHE_data_o;
    end

    // wire [31:0] instr_pre;
    // //? 32'H00000013 : nop(addi x0 x0 0)
    // assign instr_pre = (IF_CACHE_miss) ? 32'H00000013 : CACHE_data_o [31:0]; 

    wire CACHE_ena_i = 1'b1;
    wire CACHE_wea_i = 1'b0;
    wire [1:0]CACHE_data_width_i =2'b0;
    wire  [`RAM_INSTRUCTION_SIZE-1:0] CACHE_addr_i = next_pc;
    wire [32-1:0] CACHE_data_i = 32'b0;
    wire [32-1:0] CACHE_data_o;

    Cache_sets #(
        .SETS_BIT       	( SETS_BIT     ),
        .TAG_BIT        	( TAG_BIT    ),
        .INDEX_BIT      	( INDEX_BIT     ),
        .OFFSET_BIT     	( OFFSET_BIT    ),
        .CACHE_DATA_BIT 	( CACHE_DATA_BIT    ),
        .SRAM_DATA_BIT  	( SRAM_DATA_BIT  )
    ) IF_Cache_sets(
        .clk                 	( clk_sys_i           ),
        .CACHE_ena_i        	( CACHE_ena_i         ),
        .CACHE_wea_i        	( CACHE_wea_i         ),
        .CACHE_data_width_i 	( CACHE_data_width_i  ),
        .CACHE_addr_i       	( CACHE_addr_i        ),
        .CACHE_data_i       	( CACHE_data_i        ),
        .CACHE_data_o       	( CACHE_data_o        ),
        .CACHE_miss_o       	( IF_CACHE_miss       ),
        .SRAM_ena_o         	( SRAM_ena_o          ),
        .SRAM_wea_o         	( SRAM_wea_o          ),
        .SRAM_addr_o        	( SRAM_addr_o         ),
        .SRAM_data_i        	( SRAM_data_i         ),
        .SRAM_data_o        	( SRAM_data_o         )
    );




endmodule //IF
