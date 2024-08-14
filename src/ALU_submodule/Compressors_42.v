//! 设计参考 https://zhuanlan.zhihu.com/p/127164011?utm_source=wechat_timeline  （图文详解 wallace树 4-2压缩器设计）
//! 参考视频 https://www.bilibili.com/video/BV1s84y1W72L/?spm_id_from=333.788&vd_source=6c0ed6f5c02cda89c60827c1ea6d488f
module Compressors_42 #(
    parameter WIDTH = 98
)
(
    input  [WIDTH-1:0]    A,
    input  [WIDTH-1:0]    B,
    input  [WIDTH-1:0]    C,
    input  [WIDTH-1:0]    D,
    input                 Ei,
    output                Eo,
    output [WIDTH-1:0]    S,
    output [WIDTH-1:0]    Co
);
    wire [WIDTH-1:0] E ;

    assign E = ( A ^ B ) & C | ~( A ^ B ) & A;

    
    generate //! 若位宽大于1则采用级联模式
        if(WIDTH>=2)begin :S_generate
            assign S = A ^ B ^ C ^ D ^ {E[WIDTH-2:0],Ei};
            assign Co = (~(A ^ B ^ C ^ D) & D) | ({E[WIDTH-2:0],Ei} & (A ^ B ^ C ^ D));
        end else begin :S_generate
            assign S = A ^ B ^ C ^ D ^ Ei;
        end
    endgenerate
    assign Eo = E[WIDTH-1];

endmodule //Compressors_42


