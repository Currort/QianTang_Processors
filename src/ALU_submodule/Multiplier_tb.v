`include "../include/QianTang_header.v"
module Multiplier_tb (
    
);  
    reg [31:0] clk =0;
    reg [`REG_WIDTH-1:0] A;
    reg [`REG_WIDTH-1:0] B;
    reg  unsign_ctrl_A_i;
    reg  unsign_ctrl_B_i;
    wire [`REG_WIDTH-2:0] A_inv;
    wire signed [`REG_WIDTH-1:0] 	test_signed_A = A;
	wire signed [`REG_WIDTH-1:0] 	test_signed_B = B;
	wire signed [`REG_WIDTH*2-1:0]  test_signed_S;
	wire        [`REG_WIDTH*2-1:0]  test_unsigned_S;
	wire signed [`REG_WIDTH*2-1:0]  test_signed_unsigned_S;
    wire [`REG_WIDTH*2-1:0] 	S;
    assign A_inv = -test_signed_A;
    assign test_unsigned_S = A*B;
	assign test_signed_S   = test_signed_A*test_signed_B;
    assign test_signed_unsigned_S = (test_signed_A<0)? -(A_inv * B) : A * B;
initial begin
    forever #5 clk = clk+1;
end

always @(posedge clk[0]) begin
    if (clk<32'hffffffff-1) begin
        A = $random( $time*978)*$random( $time*774);
        B = $random( $time*565)*$random( $time*7036);
        unsign_ctrl_A_i = 0;
        unsign_ctrl_B_i = 0;
    end else begin
        $display("finish !");
        $finish;
    end
end
	always @(negedge clk[0])begin
		if(unsign_ctrl_A_i&&unsign_ctrl_B_i)begin
            if(S != test_unsigned_S) begin
                $warning("warning unsigned S!\n S ! = test_unsigned_S  : clk = %10d ",clk);
                $finish;
            end
        end else if((unsign_ctrl_A_i==0)&&(unsign_ctrl_B_i==1)) begin
            if(S != test_signed_unsigned_S)   begin
                $warning("warning signed and unsign S!\n S ! = test_signed_S  : clk = %10d ",clk);
                $finish;
            end
        end else if((unsign_ctrl_A_i==0)&&(unsign_ctrl_B_i==0)) begin
            if(S != test_signed_S)   begin
                $warning("warning signed S!\n S ! = test_signed_S  : clk = %10d ",clk);
                $finish;
            end
        end
	end

	



Multiplier #(
    .TEST_MODE(0)
)
u_Multiplier(
	.A             	( A              ),
	.B             	( B              ),
	.unsign_ctrl_A_i 	( unsign_ctrl_A_i  ),
    .unsign_ctrl_B_i    ( unsign_ctrl_B_i ),
	.S             	( S              )
);

endmodule //Multiplier_tb

