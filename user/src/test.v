module test (
    input clk,
    // input [63:0] a,
    // input [63:0] b,
    // input c,
    // output reg  [63:0] q2,
    // output reg co
    input [1:0] ctrl,
    input [1:0] p,
    input [3:0]d,
    output reg  [3:0] q

);
always @(posedge clk ) begin
    case(p)
    2'b00:q <= {63'b0,d} << ctrl;
    // 2'b01:q <= {63'b0,d} >> ctrl;
    // 2'b00:q <= {63'b0,d} <<< ctrl;
    // 2'b01:q <= {63'b0,d} >>> ctrl;
    endcase 
end

// always @(posedge clk) begin
//     {co,q2} <= a+b+c;
// end

// 3 4 5 6 7  8
// 2 2 2 5 27 27
endmodule //test
