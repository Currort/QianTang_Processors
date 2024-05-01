// `include "../Cache_sets.v"
module Cache_test (
);
reg  clk_sys_i;
reg  CACHE_ena_i;       
reg  CACHE_wea_i;       
reg [$clog2(64/8)-1:0] CACHE_data_width_i;
reg [16-1:0]           CACHE_addr_i;      
reg [64-1:0]           CACHE_data_i;   
initial begin
    clk_sys_i = 0;
    forever #2 clk_sys_i = ~clk_sys_i;
end

initial begin
    CACHE_ena_i        = 0 ;
    CACHE_wea_i        = 0 ;
    CACHE_data_width_i = 7 ;
    CACHE_addr_i       = 'h2016 ;
    CACHE_data_i       = 64'h123456789abcdef ;
    #20 CACHE_ena_i = 1;
    CACHE_wea_i        = 0 ;
    #20 CACHE_wea_i = 1;
    #20 CACHE_wea_i =0;
    #20 CACHE_addr_i =CACHE_addr_i+ 'h200;
    #20 CACHE_addr_i =CACHE_addr_i+ 'h200;
    #20 CACHE_addr_i =CACHE_addr_i+ 'h200;
    #20 CACHE_addr_i =CACHE_addr_i+ 'h200;
end


    // outports wire
    wire [64-1:0]           	CACHE_data_o;
    wire                                	CACHE_miss_o;
    wire                                	SRAM_ena_o;
    wire                                	SRAM_wea_o;
    wire [9-1:0]            	SRAM_addr_o;
    wire [1024-1:0]            	SRAM_data_i;
    wire [1024-1:0]            	SRAM_data_o;
    
    Cache_sets #(
        .SETS_BIT       	( 2     ),
        .TAG_BIT        	( 7     ),
        .INDEX_BIT      	( 2     ),
        .OFFSET_BIT     	( 7     ),
        .CACHE_ADDR_BIT 	( 16    ),
        .CACHE_DATA_BIT 	( 64    ),
        .SRAM_ADDR_BIT  	( 9     ),
        .SRAM_DATA_BIT  	( 1024  )
    )u_Cache_sets
    (
        .clk_sys_i          	( clk_sys_i           ),
        .CACHE_ena_i        	( CACHE_ena_i         ),
        .CACHE_wea_i        	( CACHE_wea_i         ),
        .CACHE_data_width_i 	( CACHE_data_width_i  ),
        .CACHE_addr_i       	( CACHE_addr_i        ),
        .CACHE_data_i       	( CACHE_data_i        ),
        .CACHE_data_o       	( CACHE_data_o        ),
        .CACHE_miss_o      	    ( CACHE_miss_o       ),
        .SRAM_ena_o         	( SRAM_ena_o          ),
        .SRAM_wea_o         	( SRAM_wea_o          ),
        .SRAM_addr_o        	( SRAM_addr_o         ),
        .SRAM_data_i        	( SRAM_data_i         ),
        .SRAM_data_o        	( SRAM_data_o         )
    );

    wire [63:0] test; 
    wire [1023:0] doutb;
    assign test = doutb[176+:64];
    block_memory block_memory_u (
        .clka(clk_sys_i),    
        .ena(SRAM_ena_o),    
        .wea(SRAM_wea_o),    
        .addra(SRAM_addr_o), 
        .dina(SRAM_data_o),  
        .douta(SRAM_data_i), 
        .clkb(clk_sys_i),    
        .enb(1),      
        .web(0),      
        .addrb(9'h40),  
        .dinb(0),    
        .doutb(doutb)  
    );
endmodule //Cache_test
