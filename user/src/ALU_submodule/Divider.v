//! 本模块实现了 SRT4算法的除法器，输入前需将 start_i 拉高1时钟再拉低，然后等待 finish_o 完成信号
`ifndef QIANTANG_HEADER
    `include "../include/QianTang_header.v"
`endif
module Divider #(
    parameter WIDTH = 64
)(  
    input  clk_i,
    input  start_i,
    input  sign_ctrl_i,
    input  [WIDTH-1:0]  div_i,
    input  [WIDTH-1:0]  divd_i,
    output [WIDTH-1:0] q_o,
    output [WIDTH-1:0] rem_o,
    output finish_o
);  

    // reg clk_i;
    // reg start_i;
    // reg finish_o;
    // reg sign_ctrl_i;
    // reg [WIDTH-1:0]  div_i;
    // reg [WIDTH-1:0]  divd_i;
    // wire [WIDTH-1:0] q_o;
    // wire [WIDTH-1:0] rem_o;
    // initial begin
    //     clk_i = 0;
    //     forever #0.25 clk_i = ~clk_i;
    // end



//! SRT算法验证
`ifdef DIVIDER_TEST
    initial begin
        start_i = 1;
        sign_ctrl_i=1;
        div_i  = $random( $time*399)*$random( $time*127);
        divd_i = $random( $time*3)*$random( $time*7);
        #1 start_i =0;
        forever begin
            #20 start_i =1;
                div_i  = $random($time*399)*$random( $time*127);
                divd_i = $random($time*3/7*6/9*6*189)*$random( $time*207);
            #5 start_i =0;
        end
    end
    wire [WIDTH-1:0] quot_std;
    wire [WIDTH-1:0] rem_std;
    
    assign quot_std = divd_i / div_i;
    assign rem_std  = divd_i -  quot_std * div_i;
    //! 归一化 
        wire [WIDTH+5:0] div_scale;
        wire [WIDTH+5:0] divd_scale;
        wire [5:0] left_bits_div;
        wire [5:0] left_bits_divd;
        Arbiter #(
            .WIDTH      (64),
            .ONE_HOT_CODE(0))
        div_Arbiter(
            .request_i 	( div_i  ),
            .grant_o   	( left_bits_div  )
        );
        Arbiter #(
            .WIDTH      (64),
            .ONE_HOT_CODE(0))
        divd_Arbiter(
            .request_i 	( divd_i  ),
            .grant_o   	( left_bits_divd  )
        );

        assign div_scale  = {3'b0,{div_i  << 63-left_bits_div},3'b0};
        assign divd_scale = {5'b0,{divd_i << 63-left_bits_divd},1'b0};
    //! 迭代
        wire [WIDTH+5:0] div_2  = 2*div_scale;
        wire [WIDTH+5:0] div_1  = 1*div_scale;
        wire [WIDTH+5:0] div_0  = 0*div_scale;
        wire [WIDTH+5:0] div_1n =-1*div_scale;
        wire [WIDTH+5:0] div_2n =-2*div_scale;
        // outports wire
        wire [4:0] 	quot_pro;
        reg  signed [WIDTH+5:0]  w_pro;
        wire signed [WIDTH+5:0] w4_pro;
        wire  [2:0] div_trunc;
        wire  [6:0] w_trunc;

        assign div_trunc=div_scale[WIDTH+1:WIDTH-1];
        assign w4_pro = w_pro<<2;
        assign w_trunc = w4_pro[WIDTH+5:WIDTH-1];
        QDS u_QDS(
            .div 	( div_trunc),
            .w   	( w_trunc   ),
            .q   	( quot_pro   )
        );
        reg [WIDTH-1:0] q_reg;
        reg [WIDTH-1:0] rem_reg;
        reg [WIDTH-1:0] q_end;
        reg [WIDTH-1:0] rem_end;
        reg [5:0]       q_cnt;
        reg [WIDTH-1:0] on_the_fly_A ;
        reg [WIDTH-1:0] on_the_fly_B ;
        reg [WIDTH-1:0] on_the_fly_end;
        wire [WIDTH-1:0] on_the_fly_next_A ;
        wire [WIDTH-1:0] on_the_fly_next_B ;
        
        wire [5:0]  m_n      = left_bits_divd- left_bits_div +1;
        reg [WIDTH-1:0]  q_A ;
        reg [WIDTH-1:0]  q_B ;
        always @(*) begin
            casez (quot_pro)
                5'bzzzz1: begin q_A <=  64'd2 ; q_B <= 64'd1 ; end
                5'bzzz1z: begin q_A <=  64'd3 ; q_B <= 64'd2 ; end
                5'bzz1zz: begin q_A <=  64'd0 ; q_B <= 64'd3 ; end
                5'bz1zzz: begin q_A <=  64'd1 ; q_B <= 64'd0 ; end
                5'b1zzzz: begin q_A <=  64'd2 ; q_B <= 64'd1 ; end
            endcase
        end

        assign on_the_fly_next_A = (quot_pro>5'b00010)? on_the_fly_A + (q_A << q_cnt*2): on_the_fly_B + (q_A << q_cnt*2);
        assign on_the_fly_next_B = (quot_pro>5'b00100)? on_the_fly_A + (q_B << q_cnt*2): on_the_fly_B + (q_B << q_cnt*2);

        
        always @(posedge clk_i) begin
            if(start_i == 1) begin
                w_pro <= (m_n[0]) ? divd_scale : divd_scale>>1;
                on_the_fly_A <=0;
                on_the_fly_B <=0;
                if(left_bits_divd>=left_bits_div)begin
                    q_reg <= 0;
                    q_cnt <= m_n/2;
                end else begin
                    q_end <= 0;
                    rem_end <= divd_i;
                    q_cnt <= 6'b111101;
                    on_the_fly_end <= 0;
                end
            end else if(q_cnt[5]==0)begin
                rem_reg <= w_pro>>(WIDTH-left_bits_div+2);
                on_the_fly_A <= on_the_fly_next_A ;
                on_the_fly_B <= on_the_fly_next_B ;
                casez (quot_pro)
                    5'bzzzz1: begin
                        w_pro <= w4_pro + div_2;
                        q_reg <= -64'd2*4**q_cnt+q_reg;
                        q_cnt <= q_cnt-1;
                    end
                    5'bzzz1z: begin
                        w_pro <= w4_pro + div_1;
                        q_reg <= -64'd1*4**q_cnt+q_reg;
                        q_cnt <= q_cnt-1;
                    end 
                    5'bzz1zz: begin
                        w_pro <= w4_pro + div_0;
                        q_reg <= -64'd0*4**q_cnt+q_reg;
                        q_cnt <= q_cnt-1;
                    end
                    5'bz1zzz: begin
                        w_pro <= w4_pro + div_1n;
                        q_reg <= 64'd1*4**q_cnt+q_reg;
                        q_cnt <= q_cnt-1;
                    end
                    5'b1zzzz: begin
                        w_pro <= w4_pro + div_2n;
                        q_reg <= 64'd2*4**q_cnt+q_reg;
                        q_cnt <= q_cnt-1;
                    end
                    default: $warning("encode error");
                endcase
            end else if (q_cnt==6'b111111)begin
                if(w_pro[WIDTH+5]==1) begin
                    q_reg <= q_reg-1;
                    w_pro <=w_pro+div_1;
                    on_the_fly_A <= on_the_fly_A-1;
                end
                q_cnt<=q_cnt-1;
                rem_reg <= w_pro>>(WIDTH-left_bits_div+2);
            end else if (q_cnt==6'b111110)begin
                    q_cnt<=q_cnt-1;
                    q_end   <=  q_reg;
                    on_the_fly_end <= on_the_fly_A;
                    rem_reg <= w_pro>>(WIDTH-left_bits_div+2);
                    rem_end <= w_pro>>(WIDTH-left_bits_div+2);
            end else if (q_cnt==6'b111101)begin
                if(q_end!=quot_std || rem_end!=rem_std ||on_the_fly_end!=quot_std)begin                    
                        $warning("error time:%d",$time);
                        $finish;
                end
                q_cnt<=q_cnt-1;
            end
        end
`endif

//! RTL实现
    //! 预处理
        wire [WIDTH+5:0] div_scale;
        wire [WIDTH+5:0] divd_scale;
        wire [5:0]       left_bits_div;
        wire [5:0]       left_bits_divd;
        wire [5:0]       m_n;
        wire [WIDTH-1:0] div_pre;
        wire [WIDTH-1:0] divd_pre;
        assign div_pre  = (sign_ctrl_i&&div_i[WIDTH-1])  ? (~div_i+1)  : div_i;
        assign divd_pre = (sign_ctrl_i&&divd_i[WIDTH-1]) ? (~divd_i+1) : divd_i;
        Arbiter #(
            .WIDTH      (64),
            .ONE_HOT_CODE(0))
        div_Arbiter(
            .request_i 	( div_pre  ),
            .grant_o   	( left_bits_div  )
        );
        Arbiter #(
            .WIDTH      (64),
            .ONE_HOT_CODE(0))
        divd_Arbiter(
            .request_i 	( divd_pre  ),
            .grant_o   	( left_bits_divd  )
        );
        assign div_scale  = {3'b0,{div_pre  << 63-left_bits_div},3'b0};
        assign divd_scale = {5'b0,{divd_pre << 63-left_bits_divd},1'b0};
        assign m_n        = left_bits_divd- left_bits_div +1;
     //! 除数集
        wire [WIDTH+5:0] div_2  = 2*div_scale;
        wire [WIDTH+5:0] div_1  = 1*div_scale;
        wire [WIDTH+5:0] div_0  = 0*div_scale;
        wire [WIDTH+5:0] div_1n =-1*div_scale;
        wire [WIDTH+5:0] div_2n =-2*div_scale;
    //! QDS及部分余数生成    
        wire  [4:0] 	         quot_pro;
        wire   [WIDTH+5:0]       div_pro;
        wire  [2:0]             div_trunc;
        wire  [6:0]             w_trunc;    
        assign div_trunc = div_scale[WIDTH+1:WIDTH-1];
        QDS QDS_rtl(
            .div 	( div_trunc),
            .w   	( w_trunc   ),
            .q   	( quot_pro   )
        );
        reg  [WIDTH+5:0] 	w_S_pro;
        reg  [WIDTH+5:0] 	w_C_pro;
        wire [WIDTH+5:0] 	w_S_next;
        wire [WIDTH+5:0] 	w_C_next;
        wire [WIDTH+5:0] 	w4_S_pro;
        /* verilator lint_off UNUSEDSIGNAL */ 
        wire [WIDTH+5:0] 	w4_C_pro;
        /* verilator lint_on UNUSEDSIGNAL */ 
        Compressors_32 #(.WIDTH(70)) 
        w_compress(
            .A  	( w4_S_pro   ),
            .B  	({w4_C_pro[WIDTH+4:0],1'b0}),
            .C  	( div_pro   ),
            .S  	( w_S_next  ),
            .Co 	( w_C_next  )
        );
        assign w4_S_pro = w_S_pro  << 2 ;
        assign w4_C_pro = w_C_pro  << 2 ;
        assign w_trunc  = {w4_C_pro[WIDTH+4:WIDTH-2]} + w4_S_pro[WIDTH+5:WIDTH-1] ;
        assign div_pro  = quot_pro[4] ? div_2n : 
                          quot_pro[3] ? div_1n :
                          quot_pro[2] ? div_0  : 
                          quot_pro[1] ? div_1  :
                                        div_2  ;
        // always @(*) begin
        //     casez (quot_pro)
        //         5'bzzzz1: begin div_pro <= div_2  ;end
        //         5'bzzz1z: begin div_pro <= div_1  ;end
        //         5'bzz1zz: begin div_pro <= div_0  ;end
        //         5'bz1zzz: begin div_pro <= div_1n ;end
        //         5'b1zzzz: begin div_pro <= div_2n ;end
        //     endcase
        // end
    //! 商飞速转换
        reg  [WIDTH-1:0] on_the_fly_A ;
        reg  [WIDTH-1:0] on_the_fly_B ;
        wire  [WIDTH-1:0]  q_A ;
        wire  [WIDTH-1:0]  q_B ;
        wire [WIDTH-1:0]  on_the_fly_next_A ;
        wire [WIDTH-1:0]  on_the_fly_next_B ;
        reg  [6:0]       q_cnt;
        assign q_A      = quot_pro[4] ? 64'd2  : 
                          quot_pro[3] ? 64'd1  :
                          quot_pro[2] ? 64'd0  : 
                          quot_pro[1] ? 64'd3  :
                                        64'd2  ;
        assign q_B      = quot_pro[4] ? 64'd1  : 
                          quot_pro[3] ? 64'd0  :
                          quot_pro[2] ? 64'd3  : 
                          quot_pro[1] ? 64'd2  :
                                        64'd1  ;
        // always @(*) begin
        //     casez (quot_pro)
        //         5'bzzzz1: begin q_A <=  64'd2 ; q_B <= 64'd1 ; end
        //         5'bzzz1z: begin q_A <=  64'd3 ; q_B <= 64'd2 ; end
        //         5'bzz1zz: begin q_A <=  64'd0 ; q_B <= 64'd3 ; end
        //         5'bz1zzz: begin q_A <=  64'd1 ; q_B <= 64'd0 ; end
        //         5'b1zzzz: begin q_A <=  64'd2 ; q_B <= 64'd1 ; end
        //     endcase
        // end
        assign on_the_fly_next_A = (quot_pro>5'b00010)? on_the_fly_A + (q_A << q_cnt*2): on_the_fly_B + (q_A << q_cnt*2);
        assign on_the_fly_next_B = (quot_pro>5'b00100)? on_the_fly_A + (q_B << q_cnt*2): on_the_fly_B + (q_B << q_cnt*2);
    //! 加法器
        reg   [WIDTH+5:0] w_S_end;
        reg   [WIDTH+5:0] w_C_end;
        wire  [WIDTH-1:0] w_pro_0;
        wire  [5:0]       w_pro_1;
        wire  [WIDTH+5:0] w_pro;
        wire  w_co;
        /* verilator lint_off PINMISSING */
        CLA #(.WIDTH(64))
        CLA_last_Adder(
            .A  	( w_S_end[WIDTH-1:0]   ),
            .B  	( w_C_end[WIDTH-1:0]   ),
            .Ci 	( 0         ),
            .S  	( w_pro_0   ),
            .Co     ( w_co)
        );
        /* verilator lint_on PINMISSING */
        assign w_pro_1 = w_S_end [WIDTH+5:WIDTH] + w_C_end [WIDTH+5:WIDTH] + {5'b0, w_co};
        assign w_pro   = {w_pro_1,w_pro_0};
    //! 捕捉 start_i 上升沿
        (* ASYNC_REG = "TRUE" *)
        reg 	start_sync1;
        wire  	start_up;
        always @(posedge clk_i) begin 
            start_sync1 <= start_i; 
        end
        assign start_up    = ( ~start_sync1 & start_i);
    //! 迭代
   
        reg [WIDTH-1:0] rem_end;
        reg [WIDTH-1:0] q_end;
        reg             finish_r = 1;
        always @(posedge clk_i) begin
            /* verilator lint_off WIDTHTRUNC */
            if(start_up == 1) begin
                if(left_bits_divd>=left_bits_div)begin
                    w_S_pro        <= (m_n[0]) ? divd_scale : divd_scale>>1;
                    w_C_pro        <= 0;
                    on_the_fly_A   <= 0;
                    on_the_fly_B   <= 0;
                    q_cnt          <= {1'b0, m_n} >>1;
                    finish_r       <= 0;
                end else begin
                    rem_end        <= divd_i;
                    q_end          <= 0;
                    q_cnt          <= 7'b1111101;
                    finish_r       <= 1;
                end
            end else if(q_cnt==0)begin
                w_S_end            <= w_S_next;
                w_C_end            <= {w_C_next[WIDTH+4:0],1'b0};
                on_the_fly_A       <= on_the_fly_next_A ;
                on_the_fly_B       <= on_the_fly_next_B ;
                q_cnt              <= q_cnt-1;
            end else if(q_cnt[6]==0)begin
                on_the_fly_A       <= on_the_fly_next_A ;
                on_the_fly_B       <= on_the_fly_next_B ;
                w_S_pro            <= w_S_next;
                w_C_pro            <= w_C_next;
                q_cnt              <= q_cnt-1;
            end else if (q_cnt==7'b1111111)begin
                if(w_pro[WIDTH+5]==1) begin
                    w_S_end        <= w_pro;
                    w_C_end        <= div_1;
                    on_the_fly_A   <= on_the_fly_A-1;
                end
                q_cnt              <= q_cnt-1;
            end else if (q_cnt==7'b1111110)begin
                q_cnt              <= q_cnt-1;
                q_end              <= on_the_fly_A;
                rem_end            <= w_pro>>(WIDTH-left_bits_div+2);
                finish_r           <= 1;
            end
            /* verilator lint_on WIDTHTRUNC */
        end
    assign q_o   =(sign_ctrl_i&&(div_i[WIDTH-1]^divd_i[WIDTH-1]))   ? -q_end  :  q_end;
    assign rem_o =(sign_ctrl_i&&(rem_end[WIDTH-1]^divd_i[WIDTH-1])) ? -rem_end:rem_end;
    assign finish_o = (start_up)? 0:finish_r ;
    // //! RTL验证
    // generate   
    // wire signed [63:0] div_i_sign    =div_i;
    // wire signed [63:0] divd_i_sign   =divd_i;
    // wire [63:0] quot_std;
    // wire [63:0] rem_std;
    // assign quot_std = divd_i / div_i;
    // assign rem_std  = divd_i -  quot_std * div_i;
    // wire [63:0] quot_std_sign;
    // wire [63:0] rem_std_sign;
    // assign quot_std_sign = divd_i_sign / div_i_sign;
    // assign rem_std_sign  = divd_i_sign -  quot_std_sign * div_i_sign;
    // always @(posedge clk_i) begin
    //     if((q_o!=quot_std || rem_o!=rem_std)&&
    //       (finish_o==1)&&(sign_ctrl_i==0))begin
    //         $warning("RTL unsign_error time:%d",$time);
    //         $finish;
    //       end else if((q_o!=quot_std_sign || rem_o!=rem_std_sign)&&
    //       (finish_o==1)&&(sign_ctrl_i==1))begin
    //         $warning("RTL sign_error time:%d",$time);
    //         $finish;
    //     end
    // end
    // endgenerate

endmodule //Divider

