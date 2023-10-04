module testbench();


parameter DATA_WIDTH = 64;
parameter ADDR_WIDTH = 64;
parameter MAIN_FRE   = 100; //unit MHz
reg                   sys_clk = 0;
reg                   sys_rst = 1;
reg                   sys_clk_0=0;
reg [DATA_WIDTH-1:0]  A = 0;
reg [ADDR_WIDTH-1:0]  B = 0;
reg   Ci = 0;

always begin
    #(500/MAIN_FRE) sys_clk = ~sys_clk;
end

always begin
    #(10000/MAIN_FRE) sys_clk_0 = ~sys_clk_0;
end

always begin
    #500 sys_rst = 0;
end

always @(posedge sys_clk) begin
    if (sys_rst) 
        A = 0;
    else      
        A = A + 1;
end
always @(posedge sys_clk_0) begin
    if (sys_rst) 
        B = 0;
    else      
        B = B + 1;
end

always @(posedge sys_clk) begin
    if (sys_rst) 
        Ci = 0;
    else      
        Ci = Ci + 1;
end


//Instance 
// outports wire
wire [64-1:0] 	S;
wire                  	Co;
wire                  	Gm;
wire                  	Pm;

CLA_64_32 u_CLA_64_32(
	.A  	( A   ),
	.B  	( B   ),
	.Ci 	( Ci  ),
	.S  	( S   ),
	.Co 	( Co  ),
	.Gm 	( Gm  ),
	.Pm 	( Pm  )
);

endmodule  //TOP



