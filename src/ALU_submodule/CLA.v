//! 三级超前进位加法器 模块参考 https://zhuanlan.zhihu.com/p/579055858
`include "../include/QianTang_header.v"
module CLA #(
	parameter WIDTH = 128
)
(
    input [WIDTH-1:0]  A,
    input [WIDTH-1:0]  B,
    input         Ci,
    output [WIDTH-1:0] S,
    output        Co
    // output        Gm,
    // output        Pm
);
        // outports wire
	wire [WIDTH/16-1:0] 	c;
	wire [WIDTH/16-1:0] 	g;
	wire [WIDTH/16-1:0] 	p;
/* verilator lint_off PINMISSING */
    genvar i;
	generate 
		for (i = 1; i <WIDTH/16; i=i+1) begin:CLU_4_gener_64
			CLA_16 #(.GM_PM  (1)) u_CLA_4(
				.A  	( A [i*16+:16]   ),
				.B  	( B [i*16+:16]   ),
				.Ci 	( c [i-1]        ),
				.S  	( S [i*16+:16]   ),
				.Gm 	( g[i]      ),
				.Pm 	( p[i]      )
			);
		end
		if(WIDTH==128)begin:gen128
			CLU u_CLU_u_ad_0(
				.G  	( g[3:0]    ),
				.P  	( p[3:0]    ),
				.Ci 	( Ci        ),
				.C  	( c[3:0]    )
			);
			CLU u_CLU_u_ad_1(
				.G  	( g[7:4]    ),
				.P  	( p[7:4]    ),
				.Ci 	( c[3]   ),
				.C  	( c[7:4]    )
			);
			assign Co = c[7];
		end else if(WIDTH==64)begin:gen64
			CLU u_CLU_u_ad(
				.G  	( g    ),
				.P  	( p    ),
				.Ci 	( Ci   ),
				.C  	( c    )
			);
			assign Co = c[3];
		end else begin:gen32
			CLU u_CLU_u_ad(
				.G  	({2'b0,g}),
				.P  	({2'b0,p}),
				.Ci 	( Ci   ),
				.C  	( c    )
			);
			assign Co = c[1];
		end
	endgenerate

	CLA_16 #(.GM_PM  (1)) u_CLA_16_0(
		.A  	( A [15:0]  ),
		.B  	( B [15:0]  ),
		.Ci 	( Ci        ),
		.S  	( S [15:0]  ),
		.Gm 	( g[0]     ),
		.Pm 	( p[0]     )
	);
/* verilator lint_on PINMISSING */
endmodule //CLA
