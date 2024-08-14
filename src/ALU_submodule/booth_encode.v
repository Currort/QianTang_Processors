//! 设计参考 https://zhuanlan.zhihu.com/p/127164011?utm_source=wechat_timeline  （图文详解 wallace树 4-2压缩器设计）
//! 参考视频 https://www.bilibili.com/video/BV1s84y1W72L/?spm_id_from=333.788&vd_source=6c0ed6f5c02cda89c60827c1ea6d488f
//! 3bit 编码模块
`include "../include/QianTang_header.v"
module booth_encode(
    input   [2:0] data_i,
    output zero_index   ,
    output invert_index,
    output double_index
);

//! 测试1 只有无符号乘法
    assign zero_index   = data_i[2] & data_i[1] & data_i[0] | ~(data_i[2] | data_i[1] | data_i[0]);   //! 111或000 置0
    assign invert_index = data_i[2] & ~ (data_i[1] & data_i[0]) ;                              //! 1xx      取反
    assign double_index = (~data_i[2] & (data_i[1] & data_i[0])) | (data_i[2] & ~(data_i[1] | data_i[0]));   //! 100或011 2倍



endmodule //booth_ecode
