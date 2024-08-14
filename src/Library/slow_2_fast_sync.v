//! 该模块实现 慢 >>> 快 跨时钟域同步
module slow_2_fast_sync (
    input  clk_i        ,
    input  async_i    ,
    output sync_o       ,
    output sync_up_o    ,
    output sync_down_o
);
    (* ASYNC_REG = "TRUE" *)
    reg 	sync1_reg, sync2_reg;
    always @(posedge clk_i) begin 
        sync1_reg <= async_i   ; 
        sync2_reg <= sync1_reg ;
    end
    assign sync_up_o    = ( sync1_reg & ~sync2_reg);
    assign sync_down_o  = (~sync1_reg &  sync2_reg);
    assign sync_o       = sync2_reg                ;

endmodule
