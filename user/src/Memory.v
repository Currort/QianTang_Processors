//! 该模块实现了小端模式存取,
`include "./include/QianTang_header.v"
`include "./real_time.v"

module Memory(           
        input                          clk_sys_i           ,
        input      [7:0]               ctrl_i              ,                              
        input      [4:0]               rd_i                ,
        /* verilator lint_off UNUSEDSIGNAL */
        input      [`REG_WIDTH-1:0]    result_i            ,
        /* verilator lint_on UNUSEDSIGNAL */
        input      [`REG_WIDTH-1:0]    data_i              ,
        output reg [7:0]               ctrl_o              ,
        output reg [4:0]               rd_o                ,
        output reg [`REG_WIDTH-1:0]    result_o            ,
        output                         time_intr_o         ,
        output                         software_intr_o     ,
        input                          ALU_ena_forwarding_i,
        output reg                     MEM_ena_forwarding_o,
        output reg                     LD_ena_forwarding_o,
        output reg [`REG_WIDTH-1:0]    LD_data_forwarding_o 
    );
    //? 内存存储器 8位 2^32深度
    reg  [7:0] mem_r [(2**`RAM_DATA_SIZE)-1:0];           
    initial begin
        // if (`MEM_INIT_OF_TEST == 1 )
            $readmemh(`INSTR_PATH, mem_r, 20'h08400);
    end

    reg  [`REG_WIDTH-1:0] mem_w ;
    

    `define ADDR 20'hffb08
    /* verilator lint_off UNUSEDSIGNAL */
    wire [7:0] test0;
    wire [7:0] test1;
    wire [7:0] test2;
    wire [7:0] test3;
    wire [7:0] test4;
    wire [7:0] test5;
    wire [7:0] test6;
    wire [7:0] test7;
    /* verilator lint_on UNUSEDSIGNAL */
    assign test0 = mem_r[`ADDR+0];
    assign test1 = mem_r[`ADDR+1];
    assign test2 = mem_r[`ADDR+2];
    assign test3 = mem_r[`ADDR+3];
    assign test4 = mem_r[`ADDR+4];
    assign test5 = mem_r[`ADDR+5];
    assign test6 = mem_r[`ADDR+6];
    assign test7 = mem_r[`ADDR+7];


    //! CLINT 
    wire       clk_real_time_o     ;
    wire       clk_mtime_sync_up_o ;
    /* verilator lint_off UNUSEDSIGNAL */
    wire [`REG_WIDTH-1:0] addr  ;
    wire [7:0] msip                /*verilator public_flat_rd*/;
    /* verilator lint_on UNUSEDSIGNAL */
    wire [7:0] mtime               /*verilator public_flat_rd*/;
    wire [7:0] mtimecmp            /*verilator public_flat_rd*/;
    assign msip            = mem_r[`MMIO_MSIP]   ;
    assign mtime           = mem_r[`MMIO_MTIME];
    assign mtimecmp        = mem_r[`MMIO_MTIMECMP];
    assign time_intr_o     = (mtime >= mtimecmp) ;
    assign software_intr_o = msip[0] ;


    assign addr = result_i;

    always @(*) begin
        if(ctrl_i[6:3] == `CTRL_ACCESS_I)begin   //! 读取
            LD_ena_forwarding_o =1;
            case(ctrl_i[2:0])
                `LB:begin
                    LD_data_forwarding_o [7:0]    = mem_w [7:0]  ;
                    LD_data_forwarding_o [`REG_WIDTH-1:8] = {(`REG_WIDTH-8){mem_w[7]}};
                end `LH:begin 
                    LD_data_forwarding_o [7:0]    = mem_w [7:0]  ;
                    LD_data_forwarding_o [15:8]   = mem_w [15:8] ;
                    LD_data_forwarding_o [`REG_WIDTH-1:16] = {(`REG_WIDTH-16){mem_w[15]}};
                end `LW:begin
                    LD_data_forwarding_o [7:0]    = mem_w [7:0]  ;
                    LD_data_forwarding_o [15:8]   = mem_w [15:8] ;
                    LD_data_forwarding_o [23:16]  = mem_w [23:16];
                    LD_data_forwarding_o [31:24]  = mem_w [31:24];
                    LD_data_forwarding_o [`REG_WIDTH-1:32] = {(`REG_WIDTH-32){mem_w[31]}};
                end `LBU:begin
                    LD_data_forwarding_o [7:0]    = mem_w [7:0]  ;
                    LD_data_forwarding_o [`REG_WIDTH-1:8] = {(`REG_WIDTH-8){1'b0}};
                end `LHU:begin
                    LD_data_forwarding_o [7:0]    = mem_w [7:0]  ;
                    LD_data_forwarding_o [15:8]   = mem_w [15:8] ;
                    LD_data_forwarding_o [`REG_WIDTH-1:16] = {(`REG_WIDTH-16){1'b0}};
            `ifdef RV64GC_ISA
                end `LD:begin
                    LD_data_forwarding_o [7:0]    = mem_w [7:0]  ;
                    LD_data_forwarding_o [15:8]   = mem_w [15:8] ;
                    LD_data_forwarding_o [23:16]  = mem_w [23:16];
                    LD_data_forwarding_o [31:24]  = mem_w [31:24];
                    LD_data_forwarding_o [39:32]  = mem_w [39:32];
                    LD_data_forwarding_o [47:40]  = mem_w [47:40];
                    LD_data_forwarding_o [55:48]  = mem_w [55:48];
                    LD_data_forwarding_o [63:56]  = mem_w [63:56]; 
                end `LWU :begin
                    LD_data_forwarding_o [7:0]    = mem_w [7:0]  ;
                    LD_data_forwarding_o [15:8]   = mem_w [15:8] ;
                    LD_data_forwarding_o [23:16]  = mem_w [23:16];
                    LD_data_forwarding_o [31:24]  = mem_w [31:24];
                    LD_data_forwarding_o [`REG_WIDTH-1:32] = {(`REG_WIDTH-32){1'b0}};  
            `endif
                end 
                default :begin
                    LD_data_forwarding_o = 0;
                end
            endcase
        end else begin
            LD_ena_forwarding_o = 0;
            LD_data_forwarding_o = 0;
        end
    end

    //? 小端模式访存
    always @(*) begin
        if(addr == 64'h3ffffffb20)begin
            mem_w = 'h1;
        end else begin
            mem_w [7:0]    = mem_r [addr[`RAM_DATA_SIZE-1:0]]  ;
            mem_w [15:8]   = mem_r [addr[`RAM_DATA_SIZE-1:0]+1];
            mem_w [23:16]  = mem_r [addr[`RAM_DATA_SIZE-1:0]+2];
            mem_w [31:24]  = mem_r [addr[`RAM_DATA_SIZE-1:0]+3];
            `ifdef RV64GC_ISA
                mem_w [39:32]  = mem_r [addr[`RAM_DATA_SIZE-1:0]+4];
                mem_w [47:40]  = mem_r [addr[`RAM_DATA_SIZE-1:0]+5];
                mem_w [55:48]  = mem_r [addr[`RAM_DATA_SIZE-1:0]+6];
                mem_w [63:56]  = mem_r [addr[`RAM_DATA_SIZE-1:0]+7];
            `endif
        end
    end

    always @(posedge clk_sys_i) begin
        if(ctrl_i[6:3] == `CTRL_ACCESS_I) MEM_ena_forwarding_o <= 1'b1;
        else                              MEM_ena_forwarding_o <= ALU_ena_forwarding_i;
    end

    always@(posedge clk_sys_i) begin     
        rd_o   <= rd_i;
        ctrl_o <= ctrl_i;
        if(ctrl_i[6:3] == `CTRL_ACCESS_I)begin   //! 读取
            case(ctrl_i[2:0])
                `LB:begin
                    result_o [7:0]    <= mem_w [7:0]  ;
                    result_o [`REG_WIDTH-1:8] <= {(`REG_WIDTH-8){mem_w[7]}};
                end `LH:begin 
                    result_o [7:0]    <= mem_w [7:0]  ;
                    result_o [15:8]   <= mem_w [15:8] ;
                    result_o [`REG_WIDTH-1:16] <= {(`REG_WIDTH-16){mem_w[15]}};
                end `LW:begin
                    result_o [7:0]    <= mem_w [7:0]  ;
                    result_o [15:8]   <= mem_w [15:8] ;
                    result_o [23:16]  <= mem_w [23:16];
                    result_o [31:24]  <= mem_w [31:24];
                    result_o [`REG_WIDTH-1:32] <= {(`REG_WIDTH-32){mem_w[31]}};
                end `LBU:begin
                    result_o [7:0]    <= mem_w [7:0]  ;
                    result_o [`REG_WIDTH-1:8] <= {(`REG_WIDTH-8){1'b0}};
                end `LHU:begin
                    result_o [7:0]    <= mem_w [7:0]  ;
                    result_o [15:8]   <= mem_w [15:8] ;
                    result_o [`REG_WIDTH-1:16] <= {(`REG_WIDTH-16){1'b0}};
            `ifdef RV64GC_ISA
                end `LD:begin
                    result_o [7:0]    <= mem_w [7:0]  ;
                    result_o [15:8]   <= mem_w [15:8] ;
                    result_o [23:16]  <= mem_w [23:16];
                    result_o [31:24]  <= mem_w [31:24];
                    result_o [39:32]  <= mem_w [39:32];
                    result_o [47:40]  <= mem_w [47:40];
                    result_o [55:48]  <= mem_w [55:48];
                    result_o [63:56]  <= mem_w [63:56]; 
                end `LWU :begin
                    result_o [7:0]    <= mem_w [7:0]  ;
                    result_o [15:8]   <= mem_w [15:8] ;
                    result_o [23:16]  <= mem_w [23:16];
                    result_o [31:24]  <= mem_w [31:24];
                    result_o [`REG_WIDTH-1:32] <= {(`REG_WIDTH-32){1'b0}};  
            `endif
                end 
                default :begin
                    
                end
            endcase
        end else if(ctrl_i[6:3] == `CTRL_ACCESS_S) begin //! 存储
            case(ctrl_i[2:0])
                `SB:begin
                    mem_r[addr[`RAM_DATA_SIZE-1:0]]    <= data_i [7:0]  ;
                    case (addr[`RAM_DATA_SIZE-1:0])
                        `MMIO_MTIME:;
                        default:    mem_r[`MMIO_MTIME] <=(clk_mtime_sync_up_o)? mem_r[`MMIO_MTIME] + 1 : mem_r[`MMIO_MTIME] ;
                    endcase
                end
                `SH:begin
                    mem_r[addr[`RAM_DATA_SIZE-1:0]]    <= data_i [7:0]  ;
                    mem_r[addr[`RAM_DATA_SIZE-1:0]+1]  <= data_i [15:8] ;
                    case (addr[`RAM_DATA_SIZE-1:0])
                        `MMIO_MTIME    ,
                        `MMIO_MTIME - 1:;
                        default:    mem_r[`MMIO_MTIME] <=(clk_mtime_sync_up_o)? mem_r[`MMIO_MTIME] + 1 : mem_r[`MMIO_MTIME] ;
                    endcase
                end `SW:begin
                    mem_r[addr[`RAM_DATA_SIZE-1:0]]    <= data_i [7:0]  ;
                    mem_r[addr[`RAM_DATA_SIZE-1:0]+1]  <= data_i [15:8] ;
                    mem_r[addr[`RAM_DATA_SIZE-1:0]+2]  <= data_i [23:16];
                    mem_r[addr[`RAM_DATA_SIZE-1:0]+3]  <= data_i [31:24];
                    case (addr[`RAM_DATA_SIZE-1:0])
                        `MMIO_MTIME    ,
                        `MMIO_MTIME - 1,
                        `MMIO_MTIME - 2,
                        `MMIO_MTIME - 3:;
                        default:    mem_r[`MMIO_MTIME] <=(clk_mtime_sync_up_o)? mem_r[`MMIO_MTIME] + 1 : mem_r[`MMIO_MTIME] ;
                    endcase
            `ifdef RV64GC_ISA
                end `SD:begin
                    mem_r[addr[`RAM_DATA_SIZE-1:0]  ]  <= data_i [7:0]  ;
                    mem_r[addr[`RAM_DATA_SIZE-1:0]+1]  <= data_i [15:8] ;
                    mem_r[addr[`RAM_DATA_SIZE-1:0]+2]  <= data_i [23:16];
                    mem_r[addr[`RAM_DATA_SIZE-1:0]+3]  <= data_i [31:24];
                    mem_r[addr[`RAM_DATA_SIZE-1:0]+4]  <= data_i [39:32];
                    mem_r[addr[`RAM_DATA_SIZE-1:0]+5]  <= data_i [47:40];
                    mem_r[addr[`RAM_DATA_SIZE-1:0]+6]  <= data_i [55:48];
                    mem_r[addr[`RAM_DATA_SIZE-1:0]+7]  <= data_i [63:56];   
                    case (addr[`RAM_DATA_SIZE-1:0])
                        `MMIO_MTIME    ,
                        `MMIO_MTIME - 1,
                        `MMIO_MTIME - 2,
                        `MMIO_MTIME - 3,
                        `MMIO_MTIME - 4,
                        `MMIO_MTIME - 5,
                        `MMIO_MTIME - 6,
                        `MMIO_MTIME - 7:;
                        default:    mem_r[`MMIO_MTIME] <=(clk_mtime_sync_up_o)? mem_r[`MMIO_MTIME] + 1 : mem_r[`MMIO_MTIME] ;
                    endcase
            `endif
                end
                default :begin
                    
                end
            endcase
        end else begin
            result_o <= result_i;
        end
    end

    //! 真实时钟

    real_time u_real_time(
        .clk_sys_i       	( clk_sys_i        ),
        .clk_real_time_o 	( clk_real_time_o  )
    );
    //! 上升沿同步
/* verilator lint_off PINMISSING */
    slow_2_fast_sync u_slow_2_fast_sync(
        .clk_i       	( clk_sys_i        ),
        .async_i     	( clk_real_time_o  ),
        .sync_up_o   	( clk_mtime_sync_up_o)
    );
/* verilator lint_on PINMISSING */
endmodule //IM
