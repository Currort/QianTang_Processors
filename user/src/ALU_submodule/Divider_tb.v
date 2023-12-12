
module Divider_tb (
    
);
    reg  clk_i    ;
    reg  start_i  ;
    reg [63:0] div_i    ;
    reg [63:0] divd_i   ;
    wire signed [63:0] div_i_sign    =div_i;
    wire signed [63:0] divd_i_sign   =divd_i;
    reg sign_ctrl_i=1;
    wire  [63:0] q_o;
    wire  [63:0] rem_o;
    wire  finish_o ;
    initial begin
        clk_i = 0;
        forever #0.25 clk_i = ~ clk_i ;
    end
    initial begin
        start_i = 1;
        div_i  = $random( $time*379)*$random( $time*127);
        divd_i = $random( $time*342)*$random( $time*7428);
        #1 start_i =0;
        forever begin
            #20 start_i =1;
                div_i  = $random($time*39049)*$random( $time*14527);
                divd_i = $random($time*3/7*610/9*6*189)*$random( $time*204537);
            #5 start_i =0;
        end
    end


    Divider #(.WIDTH(64),.TEST_MODE(0))
    u_Divider(
        .clk_i    	( clk_i     ),
        .sign_ctrl_i( sign_ctrl_i),
        .start_i  	( start_i   ),
        .div_i    	( div_i     ),
        .divd_i   	( divd_i    ),
        .q_o      	( q_o       ),
        .rem_o    	( rem_o     ),
        .finish_o 	( finish_o  )
    );
    wire [63:0] quot_std;
    wire [63:0] rem_std;
    assign quot_std = divd_i / div_i;
    assign rem_std  = divd_i -  quot_std * div_i;
    wire [63:0] quot_std_sign;
    wire [63:0] rem_std_sign;
    assign quot_std_sign = divd_i_sign / div_i_sign;
    assign rem_std_sign  = divd_i_sign -  quot_std_sign * div_i_sign;
    always @(posedge clk_i) begin
        if((q_o!=quot_std || rem_o!=rem_std)&&
          (start_i!=1)&&(finish_o==1)&&(sign_ctrl_i==0))begin
            $warning("RTL unsign_error time:%d",$time);
            $finish;
          end else if((q_o!=quot_std_sign || rem_o!=rem_std_sign)&&
          (start_i!=1)&&(finish_o==1)&&(sign_ctrl_i==1))begin
            $warning("RTL sign_error time:%d",$time);
            $finish;
        end
    end
endmodule //Divider_tb
