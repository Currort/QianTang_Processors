//! 商选择模块
module QDS (
    input  [2:0] div,
    input  [6:0] w,
    output [4:0] q
);
    // reg [2:0] div;
    // reg [5:0] w;
    // wire  [4:0] q;
    // reg clk ; 
    // initial begin
    //     clk = 0;
    //     div = 0;
    //     w = 0;
    //     forever #5 clk= ~clk;
    // end
    // always @(posedge clk) begin
    //     w <= w+1;
    // end
    wire [7:0] q2;
    wire [7:0] q1;
    wire [7:0] q0;
    wire [7:0] q1_n;
    wire [7:0] q2_n;
//! 商选择表 
    //?       -64,-13,-4,4,12,64  div = 000
    assign    q2  [0]= ~w[6] & (w[2] | w[4] | w[5]) & (w[3] | w[4] | w[5]) ;
    assign    q1  [0]= ~w[4] & ~w[5] & ~w[6] & (w[2] | w[3]) & (~w[2] | ~w[3]) ;
    assign    q0  [0]= (w[2] | ~w[6]) & (w[3] | ~w[5]) & (w[4] | ~w[2]) & (w[5] | ~w[4]) & (w[6] | ~w[3]) ;
    assign    q1_n[0]= w[4] & w[5] & w[6] & (w[0] | w[2] | w[3]) & (w[1] | w[2] | w[3]) & (~w[2] | ~w[3]) ;
    assign    q2_n[0]= w[6] & (~w[2] | ~w[4] | ~w[5]) & (~w[3] | ~w[4] | ~w[5]) & (~w[0] | ~w[1] | ~w[4] | ~w[5]) ;
    //?       -64,-15,-6,4,14,64  div = 001
    assign    q2  [1]= ~w[6] & (w[1] | w[4] | w[5]) & (w[2] | w[4] | w[5]) & (w[3] | w[4] | w[5]) ;
    assign    q1  [1]= ~w[4] & ~w[5] & ~w[6] & (w[2] | w[3]) & (~w[1] | ~w[2] | ~w[3]) ;
    assign    q0  [1]= (w[3] | ~w[2]) & (w[3] | ~w[6]) & (w[4] | ~w[5]) & (w[5] | ~w[3]) & (w[6] | ~w[4]) & (w[1] | w[2] | ~w[6]) ;
    assign    q1_n[1]= w[4] & w[5] & w[6] & (~w[1] | ~w[3]) & (~w[2] | ~w[3]) & (w[0] | w[1] | w[2] | w[3]) ;
    assign    q2_n[1]= w[6] & (~w[0] | ~w[4] | ~w[5]) & (~w[1] | ~w[4] | ~w[5]) & (~w[2] | ~w[4] | ~w[5]) & (~w[3] | ~w[4] | ~w[5]) ;
    //?       -64,-16,-6,4,15,64  div = 010
    assign    q2  [2]= ~w[6] & (w[0] | w[4] | w[5]) & (w[1] | w[4] | w[5]) & (w[2] | w[4] | w[5]) & (w[3] | w[4] | w[5]) ;
    assign    q1  [2]= ~w[4] & ~w[5] & ~w[6] & (w[2] | w[3]) & (~w[0] | ~w[1] | ~w[2] | ~w[3]) ;
    assign    q0  [2]= (w[3] | ~w[2]) & (w[3] | ~w[6]) & (w[4] | ~w[5]) & (w[5] | ~w[3]) & (w[6] | ~w[4]) & (w[1] | w[2] | ~w[6]) ;
    assign    q1_n[2]= w[4] & w[5] & w[6] & (~w[1] | ~w[3]) & (~w[2] | ~w[3]) ;
    assign    q2_n[2]= w[6] & (~w[4] | ~w[5]) ;
    //?       -64,-18,-6,4,16,64  div = 011
    assign    q2  [3]= ~w[6] & (w[4] | w[5]) ;
    assign    q1  [3]= ~w[4] & ~w[5] & ~w[6] & (w[2] | w[3]) ;
    assign    q0  [3]= (w[3] | ~w[2]) & (w[3] | ~w[6]) & (w[4] | ~w[5]) & (w[5] | ~w[3]) & (w[6] | ~w[4]) & (w[1] | w[2] | ~w[6]) ;
    assign    q1_n[3]= w[5] & w[6] & (w[1] | w[4]) & (w[3] | w[4]) & (w[2] | ~w[1] | ~w[3]) & (~w[2] | ~w[3] | ~w[4]) ;
    assign    q2_n[3]= w[6] & (~w[4] | ~w[5]) & (~w[1] | ~w[2] | ~w[3] | ~w[5]) ;
    //?       -64,-20,-8,6,18,64  div = 100
    assign    q2  [4]= ~w[6] & (w[4] | w[5]) & (w[1] | w[2] | w[3] | w[5]) ;
    assign    q1  [4]= ~w[5] & ~w[6] & (w[1] | w[3] | w[4]) & (~w[2] | ~w[4]) & (~w[3] | ~w[4]) & (w[2] | w[3] | ~w[1]) ;
    assign    q0  [4]= (w[3] | ~w[6]) & (w[4] | ~w[5]) & (w[5] | ~w[3]) & (w[6] | ~w[4]) & (w[3] | ~w[1] | ~w[2]) ;
    assign    q1_n[4]= w[5] & w[6] & (w[2] | w[4]) & (w[3] | w[4]) & (~w[3] | ~w[4]) ;
    assign    q2_n[4]= w[6] & (~w[4] | ~w[5]) & (~w[2] | ~w[3] | ~w[5]) ;
    //?       -64,-20,-8,6,19,64  div = 101
    assign    q2  [5]= ~w[6] & (w[4] | w[5]) & (w[0] | w[2] | w[3] | w[5]) & (w[1] | w[2] | w[3] | w[5]) ;
    assign    q1  [5]= ~w[5] & ~w[6] & (w[1] | w[3] | w[4]) & (w[2] | w[3] | w[4]) & (~w[2] | ~w[4]) & (~w[3] | ~w[4]) & (~w[0] | ~w[1] | ~w[4]) ;
    assign    q0  [5]= (w[3] | ~w[6]) & (w[4] | ~w[5]) & (w[5] | ~w[3]) & (w[6] | ~w[4]) & (w[3] | ~w[1] | ~w[2]) ;
    assign    q1_n[5]= w[5] & w[6] & (w[2] | w[4]) & (w[3] | w[4]) & (~w[3] | ~w[4]) ;
    assign    q2_n[5]= w[6] & (~w[4] | ~w[5]) & (~w[2] | ~w[3] | ~w[5]) ;
    //?       -64,-22,-8,8,20,64  div = 110
    assign    q2  [6]= ~w[6] & (w[4] | w[5]) & (w[2] | w[3] | w[5]) ;
    assign    q1  [6]= ~w[5] & ~w[6] & (w[3] | w[4]) & (w[3] | ~w[2]) & (~w[3] | ~w[4]) ;
    assign    q0  [6]= (w[3] | ~w[6]) & (w[4] | ~w[5]) & (w[5] | ~w[3]) & (w[6] | ~w[4]) ;
    assign    q1_n[6]= w[5] & w[6] & (w[3] | w[4]) & (w[1] | w[2] | w[4]) & (~w[3] | ~w[4]) ;
    assign    q2_n[6]= w[6] & (~w[4] | ~w[5]) & (~w[1] | ~w[3] | ~w[5]) & (~w[2] | ~w[3] | ~w[5]) ;
    //?       -64,-24,-8,8,24,64  div = 111
    assign    q2  [7]= ~w[6] & (w[3] | w[5]) & (w[4] | w[5]) ;
    assign    q1  [7]= ~w[5] & ~w[6] & (w[3] | w[4]) & (~w[3] | ~w[4]) ;
    assign    q0  [7]= (w[3] | ~w[6]) & (w[4] | ~w[5]) & (w[5] | ~w[3]) & (w[6] | ~w[4]) ;
    assign    q1_n[7]= w[5] & w[6] & (w[3] | w[4]) & (~w[3] | ~w[4]) ;
    assign    q2_n[7]= w[6] & (~w[3] | ~w[5]) & (~w[4] | ~w[5]) ;



    assign q={q2[div],q1[div],q0[div],q1_n[div],q2_n[div]};
endmodule //QDS
