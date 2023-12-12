//! 设计参考 https://zhuanlan.zhihu.com/p/127164011?utm_source=wechat_timeline  （图文详解 wallace树 4-2压缩器设计）
//! 参考视频 https://www.bilibili.com/video/BV1s84y1W72L/?spm_id_from=333.788&vd_source=6c0ed6f5c02cda89c60827c1ea6d488f
`include "../include/QianTang_header.v"
module booth_encode64(
    input  [`REG_WIDTH-1:0] data_i,
    output [`REG_WIDTH/2-1:0] zero_index,
    output [`REG_WIDTH/2-1:0] invert_index,
    output [`REG_WIDTH/2-1:0] double_index
    // output [`REG_WIDTH/2:0] 
);

genvar i;
generate
    for (i = 0; i <=`REG_WIDTH/2-1; i = i + 1)begin :match       
        if(i==0)begin :first
            booth_encode u_booth_encode(
                .data_i       	( {data_i[1:0],1'b0}   ),
                .zero_index   	( zero_index[0]     ),
                .invert_index 	( invert_index[0]   ),
                .double_index 	( double_index[0]   )
            );
        end else begin  :other//if (i!=`REG_WIDTH/2)
            booth_encode u_booth_encode(
                .data_i       	( data_i[i*2+1:i*2-1]),
                .zero_index   	( zero_index[i]      ),
                .invert_index 	( invert_index[i]    ),
                .double_index 	( double_index[i]    )
            );
        end
        // else begin
        //     booth_encode u_booth_encode(
        //         .data_i       	( {data_i[i*2],data_i[i*2:i*2-1]}),
        //         .zero_index   	( zero_index[i]      ),
        //         .invert_index 	( invert_index[i]    ),
        //         .double_index 	( double_index[i]    )
        //     );
        // end
    end
endgenerate
//! 测试序列 0001100110011001100110011001100110011001000010000001100100001000

endmodule //booth_encode64
