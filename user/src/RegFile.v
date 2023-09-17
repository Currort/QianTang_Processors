//! 该模块实现了整数通用寄存器只有译码阶段才会读取寄存器，写回阶段才会写入寄存器，所以整数通用寄存器有两个读端口和一个写端口
//! 未完成优化：门控时钟

module RegFile(
        input                  clk_sys_i        ,
        input  [4:0]           rst1_addr_i      ,
        input  [4:0]           rst2_addr_i      ,
        input  [4:0]           rd_addr_i        ,
        input  [31:0]          rd_wr_i          ,
        output [31:0]          rst1_o           ,
        output [31:0]          rst2_o
    );

    reg [31:0] rst [0:31];

    always @(posedge clk_sys_i) begin
        rst [rd_addr_i]<=rd_wr_i;
    end

    always @(*) begin
        rst1_o=rst[rst1_addr_i];
    end

    always @(*) begin
        rst2_o=rst[rst2_addr_i];
    end

    endmodule //RegFile
