`include "../include/QianTang_header.v"
module Print_sub #(
    parameter REG_NUMBER = 16
)(
    input      clk_sys_i,
    input      finish_i,
    output reg finish_o,
    input      write_soc_en_i,
    output reg write_ps_en_o,

    input  [$clog2(REG_NUMBER)+1:0] data_addr_i,
    input  [31:0] data_i,
    output [$clog2(REG_NUMBER)+1:0]  data_addr_o,
    output [31:0] data_o
);
    //? 上升沿触发一个脉冲write_ps_en_o信号，同时把finish_r清零
    reg write_soc_en_r; 
    reg finish_r;
    always @(posedge clk_sys_i) begin
        write_soc_en_r <= write_soc_en_i;
        finish_r       <= finish_i;
    end

    always @(posedge clk_sys_i) begin
        if((write_soc_en_r == 0)&&(write_soc_en_i == 1)) begin
            write_ps_en_o <= 1;
            finish_o      <= 0;
        end else if((finish_r == 0)&&(finish_i == 1) ) begin
            finish_o <=1; 
        end else begin
            write_ps_en_o <= 0;
        end
    end


    assign data_addr_o = data_addr_i;
    assign data_o = data_i;

    
endmodule  //Print_sub
