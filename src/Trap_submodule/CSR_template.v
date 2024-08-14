`include "../include/QianTang_header.v"
module CSR_regfile (
    input                             clk_sys_i,
    input       [11:0]                csr_addr_i,
    input                             csr_write_ena_i,
    input       [`REG_WIDTH-1:0]      csr_data_i,
    output reg  [`REG_WIDTH-1:0]      csr_data_o,
    //! CSR寄存器硬件输出
    //! CSR寄存器硬件输出结束
    output                            trap_o
);
    //! CSR寄存器定义
    //! CSR寄存器定义结束
        reg [`REG_WIDTH-1:0] mtime                = 0                         ;//? 时间计数器   
        reg [`REG_WIDTH-1:0] mtimecmp             = 0                         ;//? 时间计数中断   
    always @(posedge clk_sys_i) begin
        if(write_ena_i)begin
            if(csr_addr_i[11:10]==2'b11) $warning("This CSR is read-only!\n"); 
            else begin
                case(csr_addr_i)
                    //! CSR写定义 
                    //! CSR写定义结束                        
                    default: $warning("This CSR is undefined!\n"); 
                endcase
            end
        end
    end

    always @(*) begin
        case(csr_addr_i)
            //! CSR读定义
            //! CSR读定义结束
            default: $warning("This CSR is undefined!\n");
        endcase
    end

    //! CSR异常处理
    //! CSR异常处理结束




endmodule //CSR_regfile
