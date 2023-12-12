//! 仲裁器模块 参考链接 https://zhuanlan.zhihu.com/p/640893388 
//! 经过验证 在64位情况下比补码转换快 1逻辑级数 默认固定优先级，左边为最高优先级
module Arbiter #(
    parameter WIDTH      = 64,
    parameter ONE_HOT_CODE   = 1'b1
)(
    input  [WIDTH-1:0] request_i,
    output [(WIDTH)*ONE_HOT_CODE+$clog2(WIDTH)*(!ONE_HOT_CODE)-1:0] grant_o
);
/* verilator lint_off UNUSEDSIGNAL */
genvar i,j;
generate 
    if(ONE_HOT_CODE)begin:one_hot_gen //! 独热码形式输出
        wire [WIDTH-1:0] data [WIDTH-1:0];
        for(i=0;i<WIDTH;i=i+1)begin
            assign data[i] = {{WIDTH-i-1{1'b0}},1'b1,{i{1'b0}}};
        end
        for(i=1;i<=$clog2(WIDTH);i=i+1)begin:level
        wire [WIDTH-1:0] mux [WIDTH/2**i-1:0] ;
        wire [WIDTH/2**i-1:0] max;
        wire [WIDTH/2**i-1:0] select;
            for(j=0;j<WIDTH/2**i;j=j+1)begin:max_gen
                if(i==1)begin :first
                    assign select[j] = request_i[j*2+1];
                    assign mux[j]    = (select[j])? data[j*2+1] : data[j*2];
                    assign max[j]    = request_i[j*2+1] | request_i[j*2];
                end else begin :last
                    assign select[j] = level[i-1].max[j*2+1];
                    assign mux[j]    = (select[j])? level[i-1].mux[j*2+1] : level[i-1].mux[j*2];
                    assign max[j]    = level[i-1].max[j*2+1] | level[i-1].max[j*2];
                end  
            end
        end
        assign grant_o = level[$clog2(WIDTH)].mux[0];
    end else begin:integer_gen   //! 整数编码形式输出
        wire [$clog2(WIDTH)-1:0] data [WIDTH-1:0];
        for(i=0;i<WIDTH;i=i+1)begin
            assign data[i] = i;
        end
        for(i=1;i<=$clog2(WIDTH);i=i+1)begin:level
        wire [$clog2(WIDTH)-1:0] mux [WIDTH/2**i-1:0] ;
        wire [WIDTH/2**i-1:0] max;
        wire [WIDTH/2**i-1:0] select;
            for(j=0;j<WIDTH/2**i;j=j+1)begin:max_gen
                if(i==1)begin :first
                    assign select[j] = request_i[j*2+1];
                    assign mux[j]    = (select[j])? data[j*2+1] : data[j*2];
                    assign max[j]    = request_i[j*2+1] | request_i[j*2];
                end else begin :last 
                    assign select[j] = level[i-1].max[j*2+1];
                    assign mux[j]    = (select[j])? level[i-1].mux[j*2+1] : level[i-1].mux[j*2];
                    assign max[j]    = level[i-1].max[j*2+1] | level[i-1].max[j*2];
                end  
            end
        end
        assign grant_o = level[$clog2(WIDTH)].mux[0];
    end
/* verilator lint_on UNUSEDSIGNAL */
endgenerate

endmodule //Arbiter
