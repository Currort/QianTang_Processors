`include "./Print_test.v"


`include "./SOC.v"


module Print_test (
    
);

	wire clk_sys_i;
	wire rst_sys_i;


	// outports wire
	wire        	print_ps_finish_o;
	wire        	print_ps_en_o;
	wire [31:0] 	print_ps_data_o;

	SOC u_SOC(
		.clk_sys_i            	( clk_sys_i             ),
		.rst_sys_i            	( rst_sys_i             ),
		.print_ps_finish_i    	( print_ps_finish_i     ),
		.print_ps_data_addr_i 	( print_ps_data_addr_i  ),
		.print_ps_finish_o    	( print_ps_finish_o     ),
		.print_ps_en_o        	( print_ps_en_o         ),
		.print_ps_data_o      	( print_ps_data_o       )
	);
	wire print_ps_finish_i;
	wire print_ps_data_addr_i;



endmodule //Print_testul