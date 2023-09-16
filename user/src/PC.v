//! 该模块实现了程序计数器，其自增模式与跳转模式由 add4_en_i 信号控制

module PC
    #(
         localparam ADDR_WIDTH =  'd16
     )(
         input               clk_sys_i      ,
         input      [31:0]   iaddr_i        ,
         input               add4_en_i      ,
         output reg [31:0]   iaddr_o
     );

    always @(clk_sys_i) begin
        if (add4_en_i) begin
            iaddr_o <= iaddr_o + 4;
        end
        else begin
            iaddr_o <= iaddr_i;
        end
    end

endmodule //PC

