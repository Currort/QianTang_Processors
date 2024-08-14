//! CLU模块，使用CLU级联CLA模块实现多级超前进位加法器

//! 参考链接 https://zhuanlan.zhihu.com/p/579055858


module CLU (
	input 	[3:0]	G,
	input 	[3:0]	P,
	input 		    Ci,
	output 	[3:0]	C
);
				
	assign C[0]=G[0]|Ci&P[0];
	assign C[1]=G[1]|G[0]&P[1]|Ci&P[1]&P[0];
	assign C[2]=G[2]|G[1]&P[2]|G[0]&P[2]&P[1]|Ci&P[2]&P[1]&P[0];
	assign C[3]=G[3]|G[2]&P[3]|G[1]&P[3]&P[2]|G[0]&P[3]&P[2]&P[1]|Ci&P[3]&P[2]&P[1]&P[0];

endmodule
