
module SOC_test (
    input  clk_XTAL_i,
    input  rstn_i,
    output led_o
);
    wire rst_i;
    assign rst_i = ~rstn_i;
    assign led_o = wfi_o;
    // outports wire
    wire        	print_ps_en_o;
    wire [31:0] 	print_ps_data_o;
    wire            ecall_o;
    wire            wfi_o;
    wire            rst_sys_i;
    assign rst_sys_i = ~locked | rst_i;
    SOC u_SOC(
        .clk_sys_i            	( clk_10M               ),
        .clk_ILA_i              ( clk_50M               ),
        .rst_sys_i            	( rst_sys_i             ),
        .print_ps_finish_i    	( print_ps_finish_i     ),
        .print_ps_data_addr_i 	( print_ps_data_addr_i  ),
        .print_ps_en_o        	( print_ps_en_o         ),
        .print_ps_data_o      	( print_ps_data_o       ),
        .ecall_o                ( ecall_o ),
        .wfi_o                  ( wfi_o )
    );
    wire [$clog2(16)+1:0] print_ps_data_addr_i;
    wire print_ps_finish_i;
	uart_test u_uart_test(
		.clk_sys_i        	( clk_10M           ),
		.uart_start_i     	( print_ps_en_o     ),
		.uart_finish_o    	( print_ps_finish_i ),
		.uart_data_i      	( print_ps_data_o   ),
		.uart_data_addr_o 	( print_ps_data_addr_i  )
	);
    wire locked;
    wire clk_50M;
    wire clk_10M;
      PLL u_PLL
    (
        .clk_50M  (clk_50M),    
        .clk_10M  (clk_10M), 
        .reset    (0  ),         
        .locked   (locked ),       
        .clk_in1  (clk_XTAL_i)      
    );


endmodule //SOC_test


