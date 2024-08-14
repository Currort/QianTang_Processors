//! 写回寄存器
`include "./include/QianTang_header.v"
module Write_back(
    input  wire                        clk_sys_i,
    input  wire  [`REG_WIDTH-1:0]      result_i,
    input  wire  [4:0]                 rd_i,
    /* verilator lint_off UNUSEDSIGNAL */
    input  wire  [7:0]                 ctrl_i,
    /* verilator lint_on UNUSEDSIGNAL */
    output reg   [`REG_WIDTH-1:0]      result_o           ,
    output reg   [4:0]                 rd_o               ,
    output reg                         rd_wen_o           ,
    input                              MEM_ena_forwarding_i,
    output reg                         WB_ena_forwarding_o ,
    output reg [4:0]                   WB_addr_forwarding_o,
    output reg [`REG_WIDTH-1:0]        WB_data_forwarding_o
    // input                              Cache_miss_i                        
);
    /* verilator lint_off LATCH */
    always @(posedge clk_sys_i) begin
        // if(!Cache_miss_i)begin
            WB_ena_forwarding_o  <= MEM_ena_forwarding_i;
            WB_addr_forwarding_o <= rd_i;
            WB_data_forwarding_o <= result_i;
        // end
    end
    /* verilator lint_on LATCH */


    wire   ecall /*verilator public_flat_rd*/ ;
    assign ecall = (ctrl_i[6:3] == `CTRL_ECALL) ? 1 : 0;
    /* verilator lint_off LATCH */
    always @(*) begin 
        // if(!Cache_miss_i)begin
            result_o = result_i;
            rd_o     = rd_i;
            case (ctrl_i[6:3])
                `CTRL_ARITHMETIC_R_00,
                `CTRL_ARITHMETIC_R_01,
                `CTRL_ARITHMETIC_R_10,
                `CTRL_ARITHMETIC_I_0 ,
                `CTRL_ARITHMETIC_I_1 ,
                `CTRL_ACCESS_I       ,
                // `CTRL_ACCESS_S       
                // `CTRL_BRANCH_B       
                `CTRL_JAL            ,   
                `CTRL_LUI            ,
                `CTRL_AUIPC          ,
                `CTRL_EXCEPTION      ,
                `CTRL_JALR : rd_wen_o =1 ;
                default    : rd_wen_o =0 ;
            endcase
        // end 
    end
    /* verilator lint_on LATCH */
endmodule
