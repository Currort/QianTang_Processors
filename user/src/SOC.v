`include "include/QianTang_header.v"
module SOC (
    input clk_sys_i,
	input rst_sys_i
);
//todo jump流水线冲刷
// outports wire
wire [31:0] 	        IF_instr_o;
wire [`REG_WIDTH-1:0] 	IF_pc_o;

IF IF(
	.rst_i       	    ( rst_sys_i      ),
	.clk_sys_i   	    ( clk_sys_i      ),
	.pause_i     	    ( ALU_pause_o    ),
	.jump_i      	    ( ALU_jump_o     ),
	.jump_addr_i 	    ( ALU_jump_addr_o),
	.trap_enter_i       ( trap_enter_o   ),
	.trap_enter_addr_i  ( mtvec_o		 ),
	.trap_exit_i      	( trap_exit_o    ),
	.trap_exit_addr_i 	( mepc_o 		 ),
	.instr_o     		( IF_instr_o     ),
	.pc_o     	    	( IF_pc_o        )
);


// outports wire
wire [4:0]  			ID_rst1_addr_o;
wire [4:0]  			ID_rst2_addr_o;
wire [`REG_WIDTH-1:0] 	ID_rst1_read_o;
wire [`REG_WIDTH-1:0] 	ID_rst2_read_o;
wire [`REG_WIDTH-1:0] 	ID_pc_o;
wire [`REG_WIDTH-1:0] 	ID_imm_o;
wire [4:0]  			ID_rd_o;
wire [7:0]  			ID_ctrl_o;
wire 					ID_csr_read_ena_o ;
wire [11:0]				ID_csr_read_addr_o;
wire [`REG_WIDTH-1:0]	ID_csr_read_data_o     ;
wire 					ID_csr_write_ena_o ;
wire [11:0]				ID_csr_write_addr_o;
wire [4:0]              ID_forwarding_rst1_addr_o;
wire [4:0]              ID_forwarding_rst2_addr_o;
// assign 
ID ID(
	.clk_sys_i   	 ( clk_sys_i       ),
	.pause_i         ( ALU_pause_o     ),
	.instr_i     	 ( IF_instr_o      ),
	.rst1_i      	 ( RegFile_rst1_o  ),
	.rst2_i      	 ( RegFile_rst2_o  ),
	.pc_i			 ( IF_pc_o		  ),
	.rst1_addr_o 	 ( ID_rst1_addr_o  ),
	.rst2_addr_o 	 ( ID_rst2_addr_o  ),
	.rst1_read_o 	 ( ID_rst1_read_o  ),
	.rst2_read_o 	 ( ID_rst2_read_o  ),
	.imm_o       	 ( ID_imm_o        ),
	.pc_o            ( ID_pc_o		  ),
	.rd_o        	 ( ID_rd_o         ),
	.ctrl_o      	 ( ID_ctrl_o       ),
	.csr_read_ena_o  ( ID_csr_read_ena_o  ),
	.csr_read_addr_o ( ID_csr_read_addr_o ),
	.csr_read_data_i ( CSR_read_data_o    ),
	.csr_read_data_o ( ID_csr_read_data_o ),
	.csr_write_ena_o ( ID_csr_write_ena_o  ),
	.csr_write_addr_o( ID_csr_write_addr_o ),
	.forwarding_rst1_addr_o ( ID_forwarding_rst1_addr_o ),
	.forwarding_rst2_addr_o ( ID_forwarding_rst2_addr_o )
);

// outports wire
wire [`REG_WIDTH-1:0] 	RegFile_rst1_o;
wire [`REG_WIDTH-1:0] 	RegFile_rst2_o;

RegFile RegFile(
	.rst_i       	        ( rst_sys_i            ),
	.clk_sys_i   			( clk_sys_i            ),
	.rst1_addr_i 			( ID_rst1_addr_o       ),
	.rst2_addr_i 			( ID_rst2_addr_o       ),
	.rd_addr_i   			( WB_rd_o              ),
	.rd_wen_i    			( WB_rd_wen_o          ),
	.result_i    			( WB_result_o          ),
	.rst1_o      			( RegFile_rst1_o       ),
	.rst2_o      			( RegFile_rst2_o       )
);


// outports wire
wire                  	ALU_pause_o;
wire                    ALU_jump_o;
wire [`REG_WIDTH-1:0]   ALU_jump_addr_o;
wire [`REG_WIDTH-1:0] 	ALU_result_o;
wire [`REG_WIDTH-1:0] 	ALU_save_data_o;
wire [4:0]            	ALU_rd_o;
wire [7:0]            	ALU_ctrl_o;
wire                  	ALU_csr_write_ena_o ;
wire [11:0]           	ALU_csr_write_addr_o;
wire [`REG_WIDTH-1:0] 	ALU_csr_write_data_o;
wire 					ALU_ena_forwarding_o;
ALU ALU(
	.clk_sys_i   	  		( clk_sys_i   	    ),
	.rst1_read_i 	  		( ID_rst1_read_o      ),
	.rst2_read_i 	  		( ID_rst2_read_o      ),
	.imm_i       	  		( ID_imm_o            ),
	.pc_i        	  		( ID_pc_o             ),
	.rd_i        	  		( ID_rd_o             ),
	.ctrl_i      	  		( ID_ctrl_o           ),
	.pause_o     	  		( ALU_pause_o         ),
	.jump_o           		( ALU_jump_o          ),
	.jump_addr_o            ( ALU_jump_addr_o     ),
	.result_o    	  		( ALU_result_o        ),
	.save_data_o      		( ALU_save_data_o     ),
	.rd_o        	  		( ALU_rd_o            ),
	.ctrl_o      	  		( ALU_ctrl_o          ),
	.csr_write_ena_i  		( ID_csr_write_ena_o  ),
	.csr_write_addr_i 		( ID_csr_write_addr_o ),
	.csr_read_data_i  		( ID_csr_read_data_o  ),
	.csr_write_ena_o  		( ALU_csr_write_ena_o ),
	.csr_write_addr_o 		( ALU_csr_write_addr_o),
	.csr_write_data_o 		( ALU_csr_write_data_o),
	.ALU_ena_forwarding_o   ( ALU_ena_forwarding_o ),
	.forwarding_rst1_addr_i ( ID_forwarding_rst1_addr_o ),
	.forwarding_rst2_addr_i ( ID_forwarding_rst2_addr_o ),

	.ALU_ena_forwarding_i   ( ALU_ena_forwarding_o ),
	.ALU_addr_forwarding_i  ( ALU_rd_o 			   ),	
	.ALU_data_forwarding_i  ( ALU_result_o         ),
	.MEM_ena_forwarding_i   ( MEM_ena_forwarding_o ),
	.MEM_addr_forwarding_i  ( MEM_rd_o             ),
	.MEM_data_forwarding_i  ( MEM_result_o         ),
	.WB_ena_forwarding_i    ( WB_ena_forwarding_o  ),
	.WB_addr_forwarding_i   ( WB_addr_forwarding_o ),
	.WB_data_forwarding_i   ( WB_data_forwarding_o ),
	.LD_ena_forwarding_i    ( LD_ena_forwarding_o ),
	.LD_addr_forwarding_i   ( ALU_rd_o ),
	.LD_data_forwarding_i   ( LD_data_forwarding_o )
);

// outports wire
wire [7:0]            	MEM_ctrl_o;
wire [4:0]            	MEM_rd_o;
wire [`REG_WIDTH-1:0] 	MEM_result_o;
wire                    MEM_software_intr_o;
wire                    MEM_time_intr_o;
wire 					MEM_ena_forwarding_o;
wire                    LD_ena_forwarding_o;
wire  [`REG_WIDTH-1:0]  LD_data_forwarding_o ;
Memory MEM(
	.clk_sys_i 			  ( clk_sys_i 		     ),
	.ctrl_i    			  ( ALU_ctrl_o     	     ),
	.rd_i      			  ( ALU_rd_o       	     ),
	.result_i  			  ( ALU_result_o   	     ),
	.data_i     		  ( ALU_save_data_o	     ),
	.ctrl_o    			  ( MEM_ctrl_o     	     ),
	.rd_o      			  ( MEM_rd_o       	     ),
	.result_o  			  ( MEM_result_o   	     ),
	.software_intr_o	  ( MEM_software_intr_o  ),
	.time_intr_o    	  ( MEM_time_intr_o      ),
	.ALU_ena_forwarding_i ( ALU_ena_forwarding_o ),
	.MEM_ena_forwarding_o ( MEM_ena_forwarding_o ),
	.LD_ena_forwarding_o  ( LD_ena_forwarding_o ),
	.LD_data_forwarding_o ( LD_data_forwarding_o )
);


// outports wire
wire [`REG_WIDTH-1:0] 	WB_result_o;
wire [4:0]            	WB_rd_o;
wire                  	WB_rd_wen_o;
wire                    WB_ena_forwarding_o;
wire [4:0]              WB_addr_forwarding_o;
wire [`REG_WIDTH-1:0] 	WB_data_forwarding_o;
Write_back WB(
	.clk_sys_i 	( clk_sys_i     ),
	.result_i 	( MEM_result_o  ),
	.rd_i     	( MEM_rd_o      ),
	.ctrl_i   	( MEM_ctrl_o    ),
	.result_o 	( WB_result_o  ),
	.rd_o     	( WB_rd_o      ),
	.rd_wen_o 	( WB_rd_wen_o  ),
	.MEM_ena_forwarding_i (MEM_ena_forwarding_o),
	.WB_ena_forwarding_o  (WB_ena_forwarding_o ),
	.WB_addr_forwarding_o (WB_addr_forwarding_o),
	.WB_data_forwarding_o (WB_data_forwarding_o)
);

// outports wire
wire [`REG_WIDTH-1:0] 	CSR_read_data_o;
wire [`REG_WIDTH-1:0] 	mtvec_o;
wire [`REG_WIDTH-1:0] 	mepc_o;
wire                  	trap_enter_o;
wire                    trap_exit_o;
CSR_regfile CSR_regfile(
	.clk_sys_i       	( clk_sys_i           ),
	.pause_i            ( ALU_pause_o         ),
	.read_ena_i      	( ID_csr_read_ena_o   ),
	.read_addr_i     	( ID_csr_read_addr_o  ),
	.read_data_o     	( CSR_read_data_o     ),
	.write_ena_i     	( ALU_csr_write_ena_o ),
	.write_addr_i    	( ALU_csr_write_addr_o),
	.write_data_i    	( ALU_csr_write_data_o),
	.pc_i            	( IF_pc_o             ),
	.software_intr_i 	( MEM_software_intr_o ),
	.time_intr_i     	( MEM_time_intr_o     ),
	.external_intr_i 	( 0 	  ),
	.ret_i           	( 0           	  ),
	.mtvec_o         	( mtvec_o         	  ),
	.mepc_o          	( mepc_o          	  ),
	.trap_enter_o       ( trap_enter_o        ),
	.trap_exit_o        ( trap_exit_o )
);







endmodule //SOC
