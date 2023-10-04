//! 三级超前进位加法器 模块参考 https://zhuanlan.zhihu.com/p/579055858
`include "RISC_V_instr_def.v" 
module CLA_64_32 (
    input [64-1:0]  A,
    input [64-1:0]  B,
    input         Ci,
    output [64-1:0] S,
    output        Co,
    output        Gm,
    output        Pm
);
        // outports wire
	wire [3:0] 	c;
	wire [3:0] 	g;
	wire [3:0] 	p;

	
`ifdef RV64GC_ISA
    genvar i;
	generate 
        for (i = 1; i <4;i=i+1) begin:CLU_4_gener_64
			CLA_16 #(.GM_PM  (1)) u_CLA_4(
				.A  	( A [i*16+:16]   ),
				.B  	( B [i*16+:16]   ),
				.Ci 	( c [i-1]    ),
				.S  	( S [i*16+:16]   ),
				.Gm 	( g[i]      ),
				.Pm 	( p[i]      )
			);
            assign Co = c[3];
		end
    endgenerate
`elsif RV32GC_ISA
    genvar i;
    generate 
        for (i = 1; i <2;i=i+1) begin:CLU_4_gener_32
			CLA_16 #(.GM_PM  (1)) u_CLA_4(
				.A  	( A [i*16+:16]   ),
				.B  	( B [i*16+:16]   ),
				.Ci 	( c [i-1]        ),
				.S  	( S [i*16+:16]   ),
				.Gm 	( g[i]          ),
				.Pm 	( p[i]          )
			);
	    end
        assign p[3:2]=0;
        assign g[3:2]=0;
        assign Co = c[1];
	endgenerate
`endif

	CLU u_CLU_u_ad(
		.G  	( g   ),
		.P  	( p   ),
		.Ci 	( Ci   ),
		.C  	( c    )
	);

	CLA_16 #(.GM_PM  (1)) u_CLA_16_0(
		.A  	( A [15:0]  ),
		.B  	( B [15:0]  ),
		.Ci 	( Ci        ),
		.S  	( S [15:0]  ),
		.Gm 	( g[0]     ),
		.Pm 	( p[0]     )
	);

endmodule //CLA_64_32
