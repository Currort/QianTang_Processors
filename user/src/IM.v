//! 该模块实现了小端模式取指，为只读存储器，无需时钟介入

module IM(                                         
        input  [31:0]    iaddr_i,
        output [31:0]    instr_o    
    );

    reg  [7:0] im_r [0:2^^32-1];            //? 指令存储器 8位 2^32深度

    always@(*) begin                        //? 小端模式取指
        instr_o[7:0]    = im_r [iaddr_i];
        instr_o[15:8]   = im_r [iaddr_i+1];
        instr_o[23:16]  = im_r [iaddr_i+2];
        instr_o[31:24]  = im_r [iaddr_i+3];
    end

endmodule //IM
