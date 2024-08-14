`include "./include/QianTang_header.v"
module real_time (
    input           clk_sys_i,
    output  reg     clk_real_time_o
);

reg [$clog2(`MTIME_FREQUENCY)-1 : 0] time_cnt_reg;
    always @(posedge clk_sys_i) begin
        time_cnt_reg <= time_cnt_reg + 1;
        if (time_cnt_reg == `MTIME_FREQUENCY) begin
            time_cnt_reg    <= 0;
            clk_real_time_o <= ~clk_real_time_o;
        end
    end

endmodule //time
