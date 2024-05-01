//! 设计参考 https://zhuanlan.zhihu.com/p/127164011?utm_source=wechat_timeline  （图文详解 wallace树 4-2压缩器设计）
//! 原理讲解 https://www.bilibili.com/video/BV1s84y1W72L/?spm_id_from=333.788&vd_source=6c0ed6f5c02cda89c60827c1ea6d488f
//! https://zhuanlan.zhihu.com/p/148289578?utm_id=0
//! 基于标准单元库扩展的快速乘法器设计 - 曾宪恺 郑丹丹 严晓浪 吕冬明 葛海通
`ifndef QIANTANG_HEADER
    `include "../include/QianTang_header.v"
`endif
module Multiplier
(
	input  clk_i,
	input  start_i,
	output finish_o,
    input  [`REG_WIDTH-1:0] A,
    input  [`REG_WIDTH-1:0] B,
	input  unsign_ctrl_A_i,
	input  unsign_ctrl_B_i,
    output [`REG_WIDTH*2-1:0] S
);

//! 模拟延迟
	reg [1:0] cnt = 0;
	reg flag = 0;
	assign finish_o = (start_i & ~flag) ? 0 : (cnt == 2'b0);
	always @( posedge clk_i) begin
		if(start_i && ~flag)begin
			flag <= 1;
			cnt <= 2'b11;
		end else if(cnt == 2'b0)begin
			cnt <= 0;
			flag <= 0;
		end else begin
			cnt <= cnt-1;
		end
	end


// //! 对有符号数和无符号数统一进行符号拓展
	wire signed  [`REG_WIDTH:0] A_sign_extend;

	assign A_sign_extend = (unsign_ctrl_A_i)? {1'b0,A} :{A[`REG_WIDTH-1],A};

//! booth编码

	wire [`REG_WIDTH/2-1:0] 	zero_index;
	wire [`REG_WIDTH/2-1:0] 	invert_index;
	wire [`REG_WIDTH/2-1:0] 	double_index;

	booth_encode64 u_booth_encode64(	//! 对 B 进行booth编码 
		.data_i       	( B             ),
		.zero_index   	( zero_index    ),
		.invert_index 	( invert_index  ),
		.double_index 	( double_index  )
	);
	
//! 对于 32/64 位加法器的有符号数，经过符号拓展后，最高位booth编码为000或111，可直接省略，
//! 对于 无符号数 ，最高位booth编码为000或001，所以可以直接编码符号拓展
	wire [`REG_WIDTH*2-1:0] sign_booth;
	wire no_zero_index;
	assign no_zero_index = unsign_ctrl_B_i & B[`REG_WIDTH-1];
	assign sign_booth = (no_zero_index)? {A,                     {{1'b0,invert_index[`REG_WIDTH/2-1]}<<double_index[`REG_WIDTH/2-1]} , {(`REG_WIDTH-2){1'b0}}}
									   : {{(`REG_WIDTH){1'b0}},  {{1'b0,invert_index[`REG_WIDTH/2-1]}<<double_index[`REG_WIDTH/2-1]} , {(`REG_WIDTH-2){1'b0}}};


//!  对 A进行 B的booth解码，只解码 zero_index、double_index和invert_index的取反部分，+1部分在输入4-2压缩器前解码
	reg [`REG_WIDTH+3:0] booth [`REG_WIDTH/2-3:0] ;//! 除去第一个部分积和最后一个部分积，编码中间值
	reg [`REG_WIDTH+4:0] booth_first;
	reg [`REG_WIDTH+1:0] booth_last;

	//! A_temp 包含 ~S 位
	reg [`REG_WIDTH:0] A_temp        [`REG_WIDTH/2-3:0] ;//! 除去第一个部分积和最后一个部分积，编码中间值
	reg [`REG_WIDTH/2-3:0] A_temp_signed  ;
	reg [`REG_WIDTH:0] A_temp_first;
	reg [`REG_WIDTH:0] A_temp_last;

	genvar i;
	generate 
		for (i=0 ;i<`REG_WIDTH/2; i=i+1 ) begin:generate_booth 
			if(i==0)begin :first//! 第一个部分积 booth编码 {~S,S,S,booth_encode}
				always @(*) begin
					A_temp_first = (invert_index[0]) ? ~A_sign_extend : A_sign_extend;
					if(zero_index[0])
						booth_first = {1'b1,{(`REG_WIDTH+4){1'b0}}};
					else if(double_index[0])
						booth_first = {~A_temp_first[`REG_WIDTH], A_temp_first[`REG_WIDTH], A_temp_first[`REG_WIDTH], {A_temp_first,1'b0}};
					else 
						booth_first = {~A_temp_first[`REG_WIDTH], A_temp_first[`REG_WIDTH], A_temp_first[`REG_WIDTH], {A_temp_first[`REG_WIDTH],A_temp_first}};
				end	
			end	else if(i<`REG_WIDTH/2-1)begin: middle //! 中间 booth编码 {1,~S,booth_encode}
				always @(*) begin 
					A_temp[i-1] =(invert_index[i])? ~A_sign_extend : A_sign_extend ;
					A_temp_signed[i-1] = (invert_index[i])? ~A_sign_extend[`REG_WIDTH]: A_sign_extend[`REG_WIDTH];
					if(zero_index[i])
						booth[i-1] =   {2'b11,{(`REG_WIDTH+2){1'b0}}};
					else if(double_index[i])
						booth[i-1] =   {1'b1, ~A_temp_signed[i-1],	A_temp[i-1],1'b0};
					else 
						booth[i-1] =   {1'b1, ~A_temp_signed[i-1],	A_temp_signed[i-1],A_temp[i-1]};
				end
			end else begin :last						//! 最后一个部分积 booth编码 {booth_encode}，符号位超出乘积范围，舍弃
				always @(*) begin
					A_temp_last =(invert_index[i])?~A_sign_extend:A_sign_extend;
					if(zero_index[i])
						booth_last =   {(`REG_WIDTH+2){1'b0}};
					else if(double_index[i])
						booth_last =   {A_temp_last,1'b0};
					else 
						booth_last =   {A_temp_last[`REG_WIDTH],A_temp_last};
				end
			end
		end
	endgenerate


//! 标准过程数据  
`ifdef MULTIPLIER_TEST
	//! Sum 标准结果
	wire signed [`REG_WIDTH-1:0] 	test_signed_A = A;
	wire signed [`REG_WIDTH-1:0] 	test_signed_B = B;
	wire signed [`REG_WIDTH*2-1:0]  test_signed_S;
	wire  [`REG_WIDTH*2-1:0] 	    test_unsigned_S;
	wire  [`REG_WIDTH*2-1:0] 		test_sign_booth;
	assign test_unsigned_S = A*B;
	assign test_signed_S   = test_signed_A*test_signed_B;
	assign test_sign_booth = (no_zero_index)?{A,{(`REG_WIDTH){0}}}:{{(`REG_WIDTH*2){0}}};
	always @(*)begin
		if(unsign_ctrl_A_i)
			if(S != test_unsigned_S) $warning("warning unsigned S!\n S ! = test_unsigned_S");
		else if(unsign_ctrl_B_i==0)
			if(S != test_signed_S)   $warning("warning signed S!\n S ! = test_signed_S");
	end
	//! booth编码 符号位直接拓展到 2*`REG_WIDTH 再进行求和的 标准过程编码
	reg  [`REG_WIDTH*2-1:0] test_booth_full [`REG_WIDTH/2-1:0];
	wire [`REG_WIDTH*2-1:0] test_multi_full [`REG_WIDTH/2-1:0];
	wire [`REG_WIDTH*2-1:0] test_S_full;
	assign test_S_full = test_multi_full[`REG_WIDTH/2-1] + test_sign_booth;
	for(i=0;i<`REG_WIDTH/2;i=i+1)begin:full_encode
		if(i==0)
			assign test_multi_full[i] = test_booth_full[i];
		else 
			assign test_multi_full[i] = test_booth_full[i]+test_multi_full[i-1];
		always @(*) begin
			casex ({zero_index[i],invert_index[i],double_index[i]})
				3'b1xx: test_booth_full[i] =  0;
				3'b001: test_booth_full[i] = ( A_sign_extend<<<1)<<<2*i;
				3'b010: test_booth_full[i] = (-A_sign_extend    )<<<2*i;
				3'b011: test_booth_full[i] = (-A_sign_extend<<<1)<<<2*i;
				3'b000: test_booth_full[i] = ( A_sign_extend    )<<<2*i;
			endcase
		end
	end
	//! booth编码 全部符号位拓展求和后，只有首位为 {~S S S}，其余为 {1 ~S},再进行求和的  标准过程编码
	reg  [`REG_WIDTH*2-1:0] test_booth_lite [`REG_WIDTH/2-1:0];
	wire [`REG_WIDTH*2-1:0] test_multi_lite [`REG_WIDTH/2-1:0];
	wire [`REG_WIDTH*2-1:0] test_S_lite;
	assign test_S_lite = test_multi_lite[`REG_WIDTH/2-1] + test_sign_booth;
	for(i=0;i<`REG_WIDTH/2;i=i+1)begin:lite_encode
		if(i==0)begin
			assign test_multi_lite[i] = test_booth_lite[i];
			always @(*) begin
				casex ({zero_index[i],invert_index[i],double_index[i]})
					3'b1xx: test_booth_lite[i] = {3'b100, ( {(`REG_WIDTH+2){1'b0}} ), {(2*i){1'b0}}};
					3'b001: test_booth_lite[i] = {~A_sign_extend[`REG_WIDTH], {2{A_sign_extend[`REG_WIDTH]} }, ( A_sign_extend ),    1'b0,    {(2*i){1'b0}}};
					3'b010: test_booth_lite[i] = { A_sign_extend[`REG_WIDTH], {3{~A_sign_extend[`REG_WIDTH]}}, ((~A_sign_extend+1)    ),      {(2*i){1'b0}}};
					3'b011: test_booth_lite[i] = { A_sign_extend[`REG_WIDTH], {2{~A_sign_extend[`REG_WIDTH]}}, ((~A_sign_extend+1) ), 1'b0,   {(2*i){1'b0}}};
					3'b000: test_booth_lite[i] = {~A_sign_extend[`REG_WIDTH], {3{A_sign_extend[`REG_WIDTH]} }, ( A_sign_extend    ),          {(2*i){1'b0}}};
				endcase
			end
		end
		else begin
			assign test_multi_lite[i] = test_booth_lite[i]+test_multi_lite[i-1];
			always @(*) begin
				casex ({zero_index[i],invert_index[i],double_index[i]})
					3'b1xx: test_booth_lite[i] = {2'b11, ( {(`REG_WIDTH+2){1'b0}} ), {(2*i){1'b0}}};
					3'b001: test_booth_lite[i] = {1'b1, ~A_sign_extend[`REG_WIDTH] ,                              ( A_sign_extend ),    1'b0,  {(2*i){1'b0}}};
					3'b010: test_booth_lite[i] = {1'b1,  A_sign_extend[`REG_WIDTH] ,{~A_sign_extend[`REG_WIDTH]}, ((~A_sign_extend+1)    ),    {(2*i){1'b0}}};
					3'b011: test_booth_lite[i] = {1'b1,  A_sign_extend[`REG_WIDTH] ,                              ((~A_sign_extend+1) ),1'b0,  {(2*i){1'b0}}};
					3'b000: test_booth_lite[i] = {1'b1, ~A_sign_extend[`REG_WIDTH] ,{A_sign_extend[`REG_WIDTH]} , ( A_sign_extend    ),        {(2*i){1'b0}}};
				endcase
			end
		end
	end
	//! booth编码 全部符号位拓展求和后，只有首位为 {~S S S}，其余为 {1 ~S}
	//! 同时将求补码的+1,编码到下一位 的标志过程编码
	reg  [`REG_WIDTH*2-1:0] test_booth_lite_plus [`REG_WIDTH/2-1:0];
	wire [`REG_WIDTH*2-1:0] test_multi_lite_plus [`REG_WIDTH/2-1:0];
	wire [`REG_WIDTH*2-1:0] test_S_lite_plus;
	wire [`REG_WIDTH*2-1:0] test_booth_lite_plus_wire [`REG_WIDTH/2-1:0];
	// wire [1:0] 
	assign test_S_lite_plus = test_multi_lite_plus[`REG_WIDTH/2-1] + sign_booth;
	for(i=0;i<`REG_WIDTH/2;i=i+1)begin:lite_plus_encode
		if(i==0)begin
			assign test_multi_lite_plus[i] = test_booth_lite_plus[i];
			assign test_booth_lite_plus_wire[i] = booth_first;
			always @(*) begin
				casex ({zero_index[i],invert_index[i],double_index[i]})
					3'b1xx: test_booth_lite_plus[i] = {3'b100, ( {(`REG_WIDTH+2){1'b0}} ), {(2*i){1'b0}}};
					3'b001: test_booth_lite_plus[i] = {~A_sign_extend[`REG_WIDTH], {2{A_sign_extend[`REG_WIDTH]} }, ( A_sign_extend   ), 1'b0};
					3'b010: test_booth_lite_plus[i] = { A_sign_extend[`REG_WIDTH], {3{~A_sign_extend[`REG_WIDTH]}}, ((~A_sign_extend) )      };
					3'b011: test_booth_lite_plus[i] = { A_sign_extend[`REG_WIDTH], {2{~A_sign_extend[`REG_WIDTH]}}, ((~A_sign_extend) ), 1'b0};
					3'b000: test_booth_lite_plus[i] = {~A_sign_extend[`REG_WIDTH], {3{A_sign_extend[`REG_WIDTH]} }, ( A_sign_extend   )      };
				endcase
			end
		end
		else begin
			assign test_multi_lite_plus[i] = test_booth_lite_plus[i]+test_multi_lite_plus[i-1];
			if(i<`REG_WIDTH/2-1)
				assign test_booth_lite_plus_wire[i] = {booth[i-1],{{1'b0,invert_index[i-1]}<<double_index[i-1]}, {(2*(i-1)){1'b0}}};
			else
				assign test_booth_lite_plus_wire[i] = {booth_last,{{1'b0,invert_index[i-1]}<<double_index[i-1]}, {(2*(i-1)){1'b0}}};
			always @(*) begin
				casex ({zero_index[i],invert_index[i],double_index[i]})
					3'b1xx: test_booth_lite_plus[i] = {2'b11, ( {(`REG_WIDTH+2){1'b0}} ),                                                        {{1'b0,invert_index[i-1]}<<double_index[i-1]}, {(2*(i-1)){1'b0}}};		
					3'b001: test_booth_lite_plus[i] = {1'b1, ~A_sign_extend[`REG_WIDTH] ,                              ( A_sign_extend  ), 1'b0, {{1'b0,invert_index[i-1]}<<double_index[i-1]}, {(2*(i-1)){1'b0}}};
					3'b010: test_booth_lite_plus[i] = {1'b1,  A_sign_extend[`REG_WIDTH] ,{~A_sign_extend[`REG_WIDTH]}, ((~A_sign_extend)),       {{1'b0,invert_index[i-1]}<<double_index[i-1]}, {(2*(i-1)){1'b0}}};
					3'b011: test_booth_lite_plus[i] = {1'b1,  A_sign_extend[`REG_WIDTH] ,                              ((~A_sign_extend)), 1'b0, {{1'b0,invert_index[i-1]}<<double_index[i-1]}, {(2*(i-1)){1'b0}}};
					3'b000: test_booth_lite_plus[i] = {1'b1, ~A_sign_extend[`REG_WIDTH] ,{A_sign_extend[`REG_WIDTH]} , ( A_sign_extend  ),       {{1'b0,invert_index[i-1]}<<double_index[i-1]}, {(2*(i-1)){1'b0}}};
				endcase
			end
		end
		always @(*) begin
			if(test_booth_lite_plus_wire[i]!=test_booth_lite_plus[i])
				$warning("warning! test_booth_lite_plus[%2d] no equal to booth[%2d]",i,i);
		end
	end
	//! 一级压缩标准过程结果
	wire  [`REG_WIDTH*2-1:0] test_multi_level_1         [`REG_WIDTH/8-1:0];
	wire  [`REG_WIDTH*2-1:0] test_compr_level_1         [`REG_WIDTH/8-1:0];
	for(i=0;i<`REG_WIDTH/8;i=i+1)begin:level_1_test_booth
		assign test_multi_level_1[i]   = test_booth_lite_plus[i*4]
									    +test_booth_lite_plus[i*4+1]
									    +test_booth_lite_plus[i*4+2]
									    +test_booth_lite_plus[i*4+3];
		if (i==0) assign test_compr_level_1[0] = {level_1_first_Eo,level_1_first_S} + {level_1_first_Co,1'b0};
		else 	  assign test_compr_level_1[i] = (i!=`REG_WIDTH/8-1) ? {({level_1_Eo[i-1],level_1_S[i-1]} + {level_1_Co[i-1],1'b0}),{(6+8*(i-1)){1'b0}}}
																 		   : {(level_1_last_S +      	    {level_1_last_Co,1'b0}),{(6+8*(i-1)){1'b0}}};
		always @(*) begin
			if(test_multi_level_1[i]!=test_compr_level_1[i])
				$warning("warning level 1!\n test_multi_level_1[%2d] ! = test_compr_level_1[%2d]",i,i);
		end
	end
	//! 二级压缩标准过程结果
	wire  [`REG_WIDTH*2-1:0] test_multi_level_2         [`REG_WIDTH/16-1:0];
	wire  [`REG_WIDTH*2-1:0] test_compr_level_2         [`REG_WIDTH/16-1:0];
	for(i=0;i<`REG_WIDTH/16;i=i+1)begin:level_2_test_booth
		assign test_multi_level_2[i]   = test_multi_level_1[i*2]
									    +test_multi_level_1[i*2+1];
		if (i==0) begin 
			assign test_compr_level_2[0] = {level_2_first_Eo,level_2_first_S} + {level_2_first_Co,1'b0};
		`ifdef RV64GC_ISA
			end	else if(i!=0) begin
				assign test_compr_level_2[i] = (i!=`REG_WIDTH/16-1) ? {({level_2_Eo[i-1],level_2_S[i-1]} + {level_2_Co[i-1],1'b0}),{(14+16*(i-1)){1'b0}}}
																			: {(level_2_last_S +      	     {level_2_last_Co,1'b0}),{(14+16*(i-1)){1'b0}}}; 
		`else
			end	else begin
				assign test_compr_level_2[i] = {(level_2_last_S +      	     {level_2_last_Co,1'b0}),{(14+16*(i-1)){1'b0}}};
		`endif
		end
		always @(*) begin
			if(test_multi_level_2[i]!=test_compr_level_2[i])
				$warning("warning level 2!\n test_multi_level_2[%2d] ! = test_compr_level_2[%2d]",i,i);
		end
	end
	//! 三级压缩标准过程结果
	`ifdef RV64GC_ISA
		wire  [`REG_WIDTH*2-1:0] test_multi_level_3         [`REG_WIDTH/32-1:0];
		wire  [`REG_WIDTH*2-1:0] test_compr_level_3         [`REG_WIDTH/32-1:0];
	`else
		wire  [`REG_WIDTH*2-1:0] test_multi_level_3         ;
		wire  [`REG_WIDTH*2-1:0] test_compr_level_3         ;
	`endif
	`ifdef RV64GC_ISA
		for(i=0;i<`REG_WIDTH/32;i=i+1)begin
			assign test_multi_level_3[i]   = test_multi_level_2[i*2]
											+test_multi_level_2[i*2+1];
			if (i==0) assign test_compr_level_3[0] = {level_3_first_Eo,level_3_first_S} + {level_3_first_Co,1'b0};
			else 	  assign test_compr_level_3[1] = {(level_3_last_S +{level_3_last_Co,1'b0}),{30{1'b0}}};
			always @(*) begin
				if(test_multi_level_3[i]!=test_compr_level_3[i])
					$warning("warning level 3!\n test_multi_level_3[%2d] ! = test_compr_level_3[%2d]",i,i);
			end
		end
	`else
		assign test_multi_level_3   =     test_multi_level_2[0]
									   +  test_multi_level_2[1];
		assign test_compr_level_3 = level_3_last_S + {level_3_last_Co,1'b0};
		always @(*) begin
			if(test_multi_level_3 != test_compr_level_3)
				$warning("warning level 3!\n test_multi_level_3 ! = test_compr_level_3");
		end
	`endif
	//! 四级压缩标准过程结果
	`ifdef RV64GC_ISA
		wire  [`REG_WIDTH*2-1:0] test_multi_level_4         ;
		wire  [`REG_WIDTH*2-1:0] test_compr_level_4         ;
		assign test_multi_level_4   =     test_multi_level_3[0]
									   +  test_multi_level_3[1];
		assign test_compr_level_4 = level_4_S + {level_4_Co,1'b0};
		always @(*) begin
			if(test_multi_level_4 != test_compr_level_4)
				$warning("warning level 4!\n test_multi_level_4 ! = test_compr_level_4");
		end
	`endif
	//! 最终压缩标准过程结果
	wire  [`REG_WIDTH*2-1:0] test_multi_final       ;
	wire  [`REG_WIDTH*2-1:0] test_compr_final       ;
	assign test_compr_final = Final_S + {Final_Co,1'b0};
	`ifdef RV64GC_ISA	
		assign test_multi_final =     test_multi_level_4 + sign_booth;
	`else 
		assign test_multi_final =     test_multi_level_3 + sign_booth;
	`endif
	always @(*) begin
			if(test_multi_final != test_compr_final)
				$warning("warning final!\n test_multi_final ! = test_compr_final");
		end
`endif
//! RTL实现
	//! 压缩一级部分积
		wire  [`REG_WIDTH+11:0]    level_1_S  [`REG_WIDTH/8-3:0];
		wire  [`REG_WIDTH+11:0]    level_1_Co [`REG_WIDTH/8-3:0];
		wire  [`REG_WIDTH/8-3:0]   level_1_Eo;

		wire   [`REG_WIDTH+9:0]    level_1_first_S ;	//! 第一位位宽不同，特殊处理
		/* verilator lint_off UNUSEDSIGNAL */ 
		wire   [`REG_WIDTH+9:0]    level_1_first_Co;
		wire   					   level_1_first_Eo;
		wire   [`REG_WIDTH+9:0]    level_1_last_S ;		//! 最后一位位宽不同，特殊处理
		wire   [`REG_WIDTH+9:0]    level_1_last_Co;
		generate	
			for( i = 0; i <`REG_WIDTH/8 ; i=i+1)begin:compressors_level1	
				if(i ==0)begin :first
					Compressors_42 #(
						.WIDTH  ( `REG_WIDTH+10  ))//! 最高位相比最低位高6
					u_Compressors_42(
						.A  	({ 5'b0, booth_first}),
						.B  	({ 4'b0, booth[0], {{1'b0, invert_index[0]}<<double_index[0]}      }),
						.C  	({ 2'b0, booth[1], {{1'b0, invert_index[1]}<<double_index[1]}, 2'b0}),
						.D  	({ 		 booth[2], {{1'b0, invert_index[2]}<<double_index[2]}, 4'b0}),
						.Ei 	( 0   ),
						.Eo 	( level_1_first_Eo  ),
						.S  	( level_1_first_S   ),
						.Co 	( level_1_first_Co  )
					);
				end	else if(i !=`REG_WIDTH/8-1) begin :middle
					Compressors_42 #(
						.WIDTH  ( `REG_WIDTH+12  ))//! 最高位相比最低位高6
					u_Compressors_42(
						.A  	({ 6'b0, booth[i*4-1], {{1'b0, invert_index[i*4-1]}<<double_index[i*4-1]}      }),
						.B  	({ 4'b0, booth[i*4  ], {{1'b0, invert_index[i*4  ]}<<double_index[i*4  ]}, 2'b0}),
						.C  	({ 2'b0, booth[i*4+1], {{1'b0, invert_index[i*4+1]}<<double_index[i*4+1]}, 4'b0}),
						.D  	({ 		 booth[i*4+2], {{1'b0, invert_index[i*4+2]}<<double_index[i*4+2]}, 6'b0}),
						.Ei 	( 0  ),
						.Eo 	( level_1_Eo[i-1]  ),
						.S  	( level_1_S [i-1]  ),
						.Co 	( level_1_Co[i-1]  )
					);
				end else begin :last
					/* verilator lint_off PINMISSING */
					Compressors_42 #(
						.WIDTH  ( `REG_WIDTH+10  ))//! 最高位相比最低位高4
					u_Compressors_42(
						.A  	({ 4'b0, booth[i*4-1], {{1'b0, invert_index[i*4-1]}<<double_index[i*4-1]}      }),
						.B  	({ 2'b0, booth[i*4  ], {{1'b0, invert_index[i*4  ]}<<double_index[i*4  ]}, 2'b0}),
						.C  	({       booth[i*4+1], {{1'b0, invert_index[i*4+1]}<<double_index[i*4+1]}, 4'b0}),
						.D  	({ 		 booth_last  , {{1'b0, invert_index[i*4+2]}<<double_index[i*4+2]}, 6'b0}),
						.Ei 	( 0  ),
						.S  	( level_1_last_S   ),
						.Co 	( level_1_last_Co  )
					);
					/* verilator lint_on PINMISSING */
				end	
			end
		endgenerate
	//! 压缩二级部分积
		`ifdef RV64GC_ISA
			wire   [`REG_WIDTH+20:0] 			level_2_S  [`REG_WIDTH/16-3:0];
			wire   [`REG_WIDTH+20:0] 			level_2_Co [`REG_WIDTH/16-3:0];
			wire   [`REG_WIDTH/16-3:0]          level_2_Eo;
		`endif
		wire   [`REG_WIDTH+18:0] 		    level_2_first_S ;	//! 第一位溢出，特殊处理
		wire   [`REG_WIDTH+18:0] 		    level_2_first_Co;
		wire                                level_2_first_Eo;
		wire   [`REG_WIDTH+17:0] 		    level_2_last_S ;	//! 最后一位溢出，特殊处理
		wire   [`REG_WIDTH+17:0] 		    level_2_last_Co;
		generate	
			for( i = 0; i <`REG_WIDTH/16 ; i=i+1)begin:compressors_level2	
				if (i== 0) begin :first
					Compressors_42 #(
						.WIDTH  ( `REG_WIDTH+19  ))//! 最高位相比最低位高 9
					u_Compressors_42(
						.A  	({ 8'b0, level_1_first_Eo, level_1_first_S}),
						.B  	({ 8'b0, level_1_first_Co,            1'b0}),
						.C  	({       level_1_Eo[0], level_1_S[0], 6'b0}),
						.D  	({       level_1_Co[0],               7'b0}),
						.Ei 	( 0   ),
						.Eo 	( level_2_first_Eo  ),
						.S  	( level_2_first_S   ),
						.Co 	( level_2_first_Co  )
					);
			`ifdef RV64GC_ISA
				end else if(i !=`REG_WIDTH/16 -1)begin :middle 
						Compressors_42 #(
							.WIDTH  ( `REG_WIDTH+21  ))//! 最高位相比最低位高 9
						u_Compressors_42(
							.A  	({ 8'b0, level_1_Eo[i*2-1],   level_1_S[i*2-1]}),
							.B  	({ 8'b0, level_1_Co[i*2-1],               1'b0}),
							.C  	({       level_1_Eo[i*2], level_1_S[i*2], 8'b0}),
							.D  	({       level_1_Co[i*2],                 9'b0}),
							.Ei 	( 0   ),
							.Eo 	( level_2_Eo[i-1]  ),
							.S  	( level_2_S [i-1]  ),
							.Co 	( level_2_Co[i-1]  )
						);
			`endif
				end else begin :last 
					/* verilator lint_off PINMISSING */
					Compressors_42 #(
						.WIDTH  ( `REG_WIDTH+18  ))//! 最高位相比最低位高 6
					u_Compressors_42(
						.A  	({ 5'b0, level_1_Eo[i*2-1], level_1_S[i*2-1]}),
						.B  	({ 5'b0, level_1_Co[i*2-1],               1'b0}),
						.C  	({       level_1_last_S                 , 8'b0}),//! 由于溢出，舍弃Co最高位和Eo
						.D  	({       level_1_last_Co[`REG_WIDTH+8:0], 9'b0}),
						.Ei 	( 0   ),
						.S  	( level_2_last_S   ),
						.Co 	( level_2_last_Co  )
					);
					/* verilator lint_on PINMISSING */
				end	
			end
		endgenerate
	//! 压缩三级部分积
		`ifdef RV64GC_ISA
			wire [`REG_WIDTH+35:0] 		level_3_first_S ;
			wire [`REG_WIDTH+35:0] 		level_3_first_Co;
			wire [`REG_WIDTH/32-2:0]    level_3_first_Eo;
		`endif
		wire  [`REG_WIDTH+33:0] 		level_3_last_S ;	//! 最后一位溢出，特殊处理
		wire  [`REG_WIDTH+33:0] 		level_3_last_Co;
		generate 
			`ifdef RV64GC_ISA
				Compressors_42 #(
					.WIDTH  ( `REG_WIDTH+36  ))//! 最高位相比最低位高 9
				u_Compressors_42_l3_first(
					.A  	({ 16'b0, level_2_first_Eo ,   level_2_first_S}),
					.B  	({ 16'b0, level_2_first_Co ,               1'b0}),
					.C  	({        level_2_Eo[0], level_2_S[0], 14'b0}),
					.D  	({        level_2_Co[0],               15'b0}),
					.Ei 	( 0   ),
					.Eo 	( level_3_first_Eo  ),
					.S  	( level_3_first_S   ),
					.Co 	( level_3_first_Co  )
				);
				/* verilator lint_off PINMISSING */
				Compressors_42 #(
					.WIDTH  ( `REG_WIDTH+34  ))//! booth_temp 最高位相比最低位高6
				u_Compressors_42_l3_last(
					.A  	({ 12'b0, level_2_Eo[1], level_2_S[1]}),
					.B  	({ 12'b0, level_2_Co[1],                    1'b0}),
					.C  	({        level_2_last_S                  , 16'b0}),//! 由于溢出，舍弃Co最高位和Eo
					.D  	({        level_2_last_Co[`REG_WIDTH+16:0], 17'b0}),
					.Ei 	( 0   ),
					.S  	( level_3_last_S   ),
					.Co 	( level_3_last_Co  )
				);
				/* verilator lint_on PINMISSING */
			`else
				Compressors_42 #(
						.WIDTH  ( `REG_WIDTH+32  ))//! booth_temp 最高位相比最低位高6
					u_Compressors_42_32bit(
						.A  	({ 12'b0, level_2_first_Eo, level_2_first_S}),
						.B  	({ 12'b0, level_2_first_Co,                  1'b0}),
						.C  	({        level_2_last_S                  , 14'b0}),//! 由于溢出，舍弃Co最高位和Eo
						.D  	({        level_2_last_Co[`REG_WIDTH+14:0], 15'b0}),
						.Ei 	( 0   ),
						.S  	( level_3_last_S   ),
						.Co 	( level_3_last_Co  )
					);
			`endif
		endgenerate
	//! 64位 压缩四级部分积
		`ifdef RV64GC_ISA
			wire  [`REG_WIDTH+63:0] 		level_4_S ;
			wire  [`REG_WIDTH+63:0] 		level_4_Co;
			//! 压缩第三级部分积
			generate	
				/* verilator lint_off PINMISSING */
				Compressors_42 #(
					.WIDTH  ( `REG_WIDTH+64  ))//! booth_temp 最高位相比最低位高6
				u_Compressors_42(
					.A  	({ 27'b0, level_3_first_Eo, level_3_first_S}),
					.B  	({ 27'b0, level_3_first_Co,                  1'b0}),
					.C  	({        level_3_last_S                  , 30'b0}),//! 由于溢出，舍弃Co最高位和Eo
					.D  	({        level_3_last_Co[`REG_WIDTH+32:0], 31'b0}),
					.Ei 	( 0   ),
					.S  	( level_4_S   ),
					.Co 	( level_4_Co  )
				);
				/* verilator lint_on PINMISSING */
			endgenerate
		`endif

	//! 最终压缩
		wire  [`REG_WIDTH*2-1:0] Final_S;
		wire  [`REG_WIDTH*2-1:0] Final_Co;
		//! 64位 
			`ifdef RV64GC_ISA
				Compressors_32 #(
					.WIDTH  ( 128  ))//! 最高位相比最低位高 9u_Compressors_32
				Final_64_Compressors_32(
					.A  	( level_4_S   ),
					.B  	( {level_4_Co[`REG_WIDTH+62:0], 1'b0}   ),
					.C  	( sign_booth   ),
					.S  	( Final_S   ),
					.Co 	( Final_Co  )
				);
		//! 32位 
			`else
				Compressors_32 #(
					.WIDTH  ( 64  ))//! 最高位相比最低位高 9u_Compressors_32
				Final_32_Compressors_32(
					.A  	(  level_3_last_S   ),
					.B  	( {level_3_last_Co, 1'b0}),
					.C  	( sign_booth   ),
					.S  	( Final_S   ),
					.Co 	( Final_Co  )
				);
				
			`endif
	//! CLA加法器2-1
		//! 64位 
		/* verilator lint_off PINMISSING */
			`ifdef RV64GC_ISA
				CLA #(
					.WIDTH  (128)
				)u_CLA(
					.A  	( Final_S   ),
					.B  	( {Final_Co[`REG_WIDTH*2-2:0],1'b0}),
					.Ci 	( 0   ),
					.S  	( S   )
					// .Co 	( Co  )
				);
		//! 32位 
		
			`else
				CLA #(
					.WIDTH  (64)
				)u_CLA(
					.A  	( Final_S   ),
					.B  	( {Final_Co[`REG_WIDTH*2-2:0],1'b0}),
					.Ci 	( 0   ),
					.S  	( S   )
					// .Co 	( Co  )
				);
			`endif
		/* verilator lint_on UNUSEDSIGNAL */ 
		/* verilator lint_on PINMISSING */
endmodule //Multiplier

