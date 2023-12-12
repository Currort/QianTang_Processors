//! 两级超前进位加法器 模块参考 https://zhuanlan.zhihu.com/p/579055858
module CLA_16#(
    parameter GM_PM=1'b1 
)(
    input [15:0]  A,
    input [15:0]  B,
    input         Ci,
    output [15:0] S,
    output        Co,
	output        Gm,
	output		  Pm
);
    // outports wire
	wire [3:0] 	c;
	wire [3:0] 	g;
	wire [3:0] 	p;

	assign Co = c[3];
/* verilator lint_off PINMISSING */
	CLA_4 #(.GM_PM  (1)) u_CLA_4_0(
		.A  	( A [3:0]  ),
		.B  	( B [3:0]  ),
		.Ci 	( Ci        ),
		.S  	( S [3:0]  ),
		.Gm 	( g[0]     ),
		.Pm 	( p[0]     )
	);

	genvar i;
	generate 
		for (i = 1; i <4;i=i+1) begin:CLU_4_gener
				CLA_4 #(.GM_PM  (1)) u_CLA_4(
					.A  	( A [i*4+:4]   ),
					.B  	( B [i*4+:4]   ),
					.Ci 	( c [i-1]    ),
					.S  	( S [i*4+:4]   ),
					.Gm 	( g[i]      ),
					.Pm 	( p[i]      )
				);
		end
	endgenerate

	CLU u_CLU_u_0(
		.G  	( g   ),
		.P  	( p   ),
		.Ci 	( Ci   ),
		.C  	( c    )
	);

	generate
        if(GM_PM) begin :out_GM_PM
            assign Gm=g[3]|g[2]&p[3]|g[1]&p[3]&p[2]|g[0]&p[3]&p[2]&p[1];
            assign Pm=p[3]&p[2]&p[1]&p[0];
        end
    endgenerate
/* verilator lint_on PINMISSING */
endmodule //CLA_16
