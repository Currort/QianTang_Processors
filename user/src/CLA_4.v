//! 超前进位加法器 模块参考 https://zhuanlan.zhihu.com/p/579055858

module CLA_4 #(
    parameter GM_PM=1'b1 
)
(
    input   [3:0]  A,
    input   [3:0]  B,
    input          Ci,
    output  [3:0]  S,
    output         Co,
    output         Gm,
    output         Pm
);
    genvar i;
    wire [3:0] g;
    wire [3:0] p;
    wire [3:0] t;
    wire [3:0] c;

    //! 生成PG模块，G生成，P传播
    assign g = A & B;
    assign p = A | B; 

    //! PG组合生成除进位以外的计算结果T
    assign  t = ~g & p;

    // //! 计算超前进位
    CLU u_CLU_CLA_4(
        .G  	( g   ),
        .P  	( p   ),
        .Ci 	( Ci  ),
        .C 	    ( c   )
    );
    // assign c[0]=g[0]|Ci&p[0];
	// assign c[1]=g[1]|g[0]&p[1]|Ci&p[1]&p[0];
	// assign c[2]=g[2]|g[1]&p[2]|g[0]&p[2]&p[1]|Ci&p[2]&p[1]&p[0];
	// assign c[3]=g[3]|g[2]&p[3]|g[1]&p[3]&p[2]|g[0]&p[3]&p[2]&p[1]|Ci&p[3]&p[2]&p[1]&p[0];

    assign Co=c[3];

    generate                    
        for ( i=0 ; i<4 ; i=i+1 ) begin :C_generate        //! 将超前进位与T异或算出CLA结果
            if(i==0)begin
                assign  S[i] = t[i] ^ Ci;
            end else begin
                assign  S[i] = t[i] ^ c[i-1];
            end
        end
    endgenerate

    generate
        if(GM_PM) begin
            assign Gm=g[3]|g[2]&p[3]|g[1]&p[3]&p[2]|g[0]&p[3]&p[2]&p[1];
            assign Pm=p[3]&p[2]&p[1]&p[0];
        end
    endgenerate

endmodule //CLA_4