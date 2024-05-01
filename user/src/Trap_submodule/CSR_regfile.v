`include "../include/QianTang_header.v"
module CSR_regfile (
    input                             clk_sys_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input                             pause_i,
    /* verilator lint_on UNUSEDSIGNAL */
    input                             read_ena_i,
    input       [11:0]                read_addr_i,
    output reg  [`REG_WIDTH-1:0]      read_data_o,

    input                             write_ena_i,
    input       [11:0]                write_addr_i,
    input       [`REG_WIDTH-1:0]      write_data_i,

    input       [`REG_WIDTH-1:0]      pc_i,
    input                             software_intr_i,
    input                             time_intr_i,
    input                             external_intr_i,
    input                             ret_i,

    //! CSR寄存器硬件输出
    output      [`REG_WIDTH-1:0]      mtvec_o   ,
    output      [`REG_WIDTH-1:0]      mepc_o    ,
    output                            trap_enter_o ,
    output                            trap_exit_o
);
    //! CSR寄存器定义
        reg [`REG_WIDTH-1:0] misa             /*verilator public_flat_rd*/   = {2'd2,36'd0,`EXTENSIONS}  ;//? ISA支持                             
        reg [`REG_WIDTH-1:0] mstatus          /*verilator public_flat_rd*/   = {32'd10,32'h0}            ;//? 当前状态寄存器             
        reg [`REG_WIDTH-1:0] mtvec            /*verilator public_flat_rd*/   = 0                         ;//? 陷阱跳转基地址                     
        reg [`REG_WIDTH-1:0] mie              /*verilator public_flat_rd*/   = 0                         ;//? 中断使能                
        reg [`REG_WIDTH-1:0] mcause           /*verilator public_flat_rd*/   = 0                         ;//? 陷阱原因指示              
        reg [`REG_WIDTH-1:0] mepc             /*verilator public_flat_rd*/   = 0                         ;//? 陷阱 PC 值             
        reg [`REG_WIDTH-1:0] mvtal            /*verilator public_flat_rd*/   = 0                         ;//? 陷阱异常特定信息            
        reg [`REG_WIDTH-1:0] mcounteren       /*verilator public_flat_rd*/   = 0                         ;//? 计数器访问权限             
        reg [`REG_WIDTH-1:0] mcountinhibit    /*verilator public_flat_rd*/   = 0                         ;//? 计数器停止计数             
        reg [`REG_WIDTH-1:0] mcycle           /*verilator public_flat_rd*/   = 0                         ;//? 时钟计数器               
        reg [`REG_WIDTH-1:0] minstret         /*verilator public_flat_rd*/   = 0                         ;//? 指令计数器               
        //! 只读
        reg [`REG_WIDTH-1:0] mip              /*verilator public_flat_rd*/   = 0                         ;//? 中断队列 
        reg [`REG_WIDTH-1:0] mvendorid        /*verilator public_flat_rd*/   = 0                         ;//? 供应商ID               
        reg [`REG_WIDTH-1:0] marchid          /*verilator public_flat_rd*/   = 0                         ;//? 项目ID                
        reg [`REG_WIDTH-1:0] mimpid           /*verilator public_flat_rd*/   = 0                         ;//? 版本ID                
        reg [`REG_WIDTH-1:0] mhartid          /*verilator public_flat_rd*/   = 0                         ;//? 线程ID  
    //! CSR 脏标记
        reg                 dirty_misa          /*verilator public_flat_rd*/       = 0  ;
        reg                 dirty_mstatus       /*verilator public_flat_rd*/       = 0  ;   
        reg                 dirty_mtvec         /*verilator public_flat_rd*/       = 0  ;   
        reg                 dirty_mie           /*verilator public_flat_rd*/       = 0  ;
        reg                 dirty_mcause        /*verilator public_flat_rd*/       = 0  ;  
        reg                 dirty_mepc          /*verilator public_flat_rd*/       = 0  ;
        reg                 dirty_mvtal         /*verilator public_flat_rd*/       = 0  ;    
        reg                 dirty_mcounteren    /*verilator public_flat_rd*/       = 0  ;   
        reg                 dirty_mcountinhibit /*verilator public_flat_rd*/       = 0  ;   
        reg                 dirty_mcycle        /*verilator public_flat_rd*/       = 0  ; 
        reg                 dirty_minstret      /*verilator public_flat_rd*/       = 0  ; 

    wire e_intr = `MSTATUS_MIE & `MIE_MEIE & `MIP_MEIP ;
    wire t_intr = `MSTATUS_MIE & `MIE_MTIE & `MIP_MTIP ;
    wire s_intr = `MSTATUS_MIE & `MIE_MSIE & `MIP_MSIP ;

    always @(posedge clk_sys_i) begin
        //! MIP 中断挂起 (无法写入)
            `MIP_MEIP <=  external_intr_i ;
            `MIP_MTIP <=  time_intr_i     ;
            `MIP_MSIP <=  software_intr_i ;
        //! 进入中断
            if(e_intr | s_intr | t_intr)begin
                //! MCAUSE   陷阱原因
                    `MCAUSE_INTERRUPT <= 1'b1 ;
                    if      (e_intr) `MCAUSE_CODE <= `MACHINE_E_INTR ;
                    else if (s_intr) `MCAUSE_CODE <= `MACHINE_S_INTR;
                    else if (t_intr) `MCAUSE_CODE <= `MACHINE_T_INTR;
                //! MSTATUS 屏蔽中断 
                    `MSTATUS_MPIE <= 1'b1  ;
                    `MSTATUS_MIE  <= 1'b0  ;
                //! MEPC    陷阱地址
                    mepc <= pc_i;
            end
        //! 退出陷阱恢复中断
            else if((ret_i))begin
                `MSTATUS_MPIE <= 1'b1           ;
                `MSTATUS_MIE  <= `MSTATUS_MPIE  ;
            end
        //! CSR 原子写 清除脏标记
            else if(write_ena_i)begin
                if(write_addr_i[11:10]==2'b11) $warning("This CSR is read-only!\n");
                else begin
                    case(write_addr_i)
                        `CSR_ADDR_MISA          : begin dirty_misa          <= 1'b0 ; misa                 <= write_data_i ;        end
                        `CSR_ADDR_MSTATUS       : begin dirty_mstatus       <= 1'b0 ; mstatus              <= write_data_i ;        end
                        `CSR_ADDR_MTVEC         : begin dirty_mtvec         <= 1'b0 ; mtvec                <= write_data_i ;        end
                        `CSR_ADDR_MIE           : begin dirty_mie           <= 1'b0 ; mie                  <= write_data_i ;        end
                        `CSR_ADDR_MCAUSE        : begin dirty_mcause        <= 1'b0 ; mcause               <= write_data_i ;        end
                        `CSR_ADDR_MEPC          : begin dirty_mepc          <= 1'b0 ; mepc                 <= write_data_i ;        end
                        `CSR_ADDR_MVTAL         : begin dirty_mvtal         <= 1'b0 ; mvtal                <= write_data_i ;        end
                        `CSR_ADDR_MCOUNTEREN    : begin dirty_mcounteren    <= 1'b0 ; mcounteren           <= write_data_i ;        end
                        `CSR_ADDR_MCOUNTINHIBIT : begin dirty_mcountinhibit <= 1'b0 ; mcountinhibit        <= write_data_i ;        end
                        `CSR_ADDR_MCYCLE        : begin dirty_mcycle        <= 1'b0 ; mcycle               <= write_data_i ;        end
                        `CSR_ADDR_MINSTRET      : begin dirty_minstret      <= 1'b0 ; minstret             <= write_data_i ;        end 
                        `CSR_ADDR_MIP           : begin $warning("CSR mip is read-only!\n");    end             
                        default: $warning("This CSR is undefined!\n"); 
                    endcase
                end
            end
    
    end
    //! CSR原子读取 
    always @(*) begin
        if(read_ena_i)begin
            case(read_addr_i)
                `CSR_ADDR_MISA           : read_data_o = misa            ;
                `CSR_ADDR_MVENDORID      : read_data_o = mvendorid       ;
                `CSR_ADDR_MARCHID        : read_data_o = marchid         ;
                `CSR_ADDR_MIMPID         : read_data_o = mimpid          ;
                `CSR_ADDR_MHARTID        : read_data_o = mhartid         ;
                `CSR_ADDR_MSTATUS        : read_data_o = mstatus         ;
                `CSR_ADDR_MTVEC          : read_data_o = mtvec           ;
                `CSR_ADDR_MIP            : read_data_o = mip             ;
                `CSR_ADDR_MIE            : read_data_o = mie             ;
                `CSR_ADDR_MCAUSE         : read_data_o = mcause          ;
                `CSR_ADDR_MEPC           : read_data_o = mepc            ;
                `CSR_ADDR_MVTAL          : read_data_o = mvtal           ;
                `CSR_ADDR_MCOUNTEREN     : read_data_o = mcounteren      ;
                `CSR_ADDR_MCOUNTINHIBIT  : read_data_o = mcountinhibit   ;
                `CSR_ADDR_MCYCLE         : read_data_o = mcycle          ;
                `CSR_ADDR_MINSTRET       : read_data_o = minstret        ;
                default:begin
                    read_data_o = 'b0;
                    $warning("This CSR is undefined!\n"); 
                end 
            endcase
        end else begin
            read_data_o ='b0;
        end
    end
    // //! 脏数据报错
    // always @(posedge clk_sys_i) begin
    //     if(read_ena_i)begin
    //         case(read_addr_i)
    //             `CSR_ADDR_MISA          : begin   if((dirty_misa         ) && (pause_i==0) )$warning("This CSR is dirty!\n"); else dirty_misa          <= 1'b1 ; end
    //             `CSR_ADDR_MSTATUS       : begin   if((dirty_mstatus      ) && (pause_i==0) )$warning("This CSR is dirty!\n"); else dirty_mstatus       <= 1'b1 ; end
    //             `CSR_ADDR_MTVEC         : begin   if((dirty_mtvec        ) && (pause_i==0) )$warning("This CSR is dirty!\n"); else dirty_mtvec         <= 1'b1 ; end
    //             `CSR_ADDR_MIE           : begin   if((dirty_mie          ) && (pause_i==0) )$warning("This CSR is dirty!\n"); else dirty_mie           <= 1'b1 ; end
    //             `CSR_ADDR_MCAUSE        : begin   if((dirty_mcause       ) && (pause_i==0) )$warning("This CSR is dirty!\n"); else dirty_mcause        <= 1'b1 ; end
    //             `CSR_ADDR_MEPC          : begin   if((dirty_mepc         ) && (pause_i==0) )$warning("This CSR is dirty!\n"); else dirty_mepc          <= 1'b1 ; end
    //             `CSR_ADDR_MVTAL         : begin   if((dirty_mvtal        ) && (pause_i==0) )$warning("This CSR is dirty!\n"); else dirty_mvtal         <= 1'b1 ; end
    //             `CSR_ADDR_MCOUNTEREN    : begin   if((dirty_mcounteren   ) && (pause_i==0) )$warning("This CSR is dirty!\n"); else dirty_mcounteren    <= 1'b1 ; end
    //             `CSR_ADDR_MCOUNTINHIBIT : begin   if((dirty_mcountinhibit) && (pause_i==0) )$warning("This CSR is dirty!\n"); else dirty_mcountinhibit <= 1'b1 ; end
    //             `CSR_ADDR_MCYCLE        : begin   if((dirty_mcycle       ) && (pause_i==0) )$warning("This CSR is dirty!\n"); else dirty_mcycle        <= 1'b1 ; end
    //             `CSR_ADDR_MINSTRET      : begin   if((dirty_minstret     ) && (pause_i==0) )$warning("This CSR is dirty!\n"); else dirty_minstret      <= 1'b1 ; end
    //             `CSR_ADDR_MIP, `CSR_ADDR_MVENDORID, `CSR_ADDR_MARCHID, `CSR_ADDR_MIMPID, `CSR_ADDR_MHARTID :begin
    //             end   
    //             default: $warning("This CSR is undefined!\n"); 
    //         endcase
    //     end
    // end


    assign  mtvec_o   = mtvec;
    assign  mepc_o    = mepc;
    assign  trap_enter_o    =  (e_intr | s_intr | t_intr);
    assign  trap_exit_o     =  ret_i;
endmodule //CSR_regfile
