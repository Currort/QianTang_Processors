//! 设计参考 https://blog.csdn.net/kekeshu_k/article/details/114236090  3-2压缩器

module Compressors_32 #(
    parameter WIDTH = 64
)
(
    input  [WIDTH-1:0]    A,
    input  [WIDTH-1:0]    B,
    input  [WIDTH-1:0]    C,
    output [WIDTH-1:0]    S,
    output [WIDTH-1:0]    Co
);

    assign Co = A & B | C & (A ^ B);
    assign S = A ^ B ^ C ;

endmodule //Compressors_32



