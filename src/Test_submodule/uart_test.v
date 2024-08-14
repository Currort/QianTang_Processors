module uart_test (
	input         clk_sys_i,
	input         uart_start_i,
    output 		  uart_finish_o,
	input  [31:0] uart_data_i,
	output [$clog2(16)+1:0]  uart_data_addr_o,
	output        test_finish
);
	/* verilator lint_off WIDTHEXPAND */
	/* verilator lint_off WIDTHTRUNC */
	assign test_finish = finish_r;

	reg [7:0] cnt = 0;
	reg intr_r;
	reg [$clog2(16)+2:0] data_cnt =0;
	reg finish_r=0;
	assign uart_finish_o = finish_r ;
	assign uart_data_addr_o = data_cnt;
	wire end_of_uart;

	assign end_of_uart = (uart_data_i[7:0]   == 8'h21) ||
						 (uart_data_i[15:8]  == 8'h21) ||
						 (uart_data_i[23:16] == 8'h21) ||
						 (uart_data_i[31:24] == 8'h21) ;
	always @( posedge clk_sys_i )
	begin
	    if (uart_start_i)begin
			data_cnt <= 0;
			intr_r   <= 0;
			finish_r  <= 0;
			cnt <= 0;
		end else if (intr_r) begin
			if(cnt == 8'hFF) begin
				intr_r   <= 0;
				finish_r  <= 1;
			end else if (cnt < 8'hFF) begin
				cnt <= cnt + 1;
			end
		end else if(data_cnt < (16 * 4))  begin
			data_cnt		  <= data_cnt+4;
			if(end_of_uart) begin
				intr_r        <= 1;
				data_cnt      <= (16 * 4);
			end
		end
	end
	/* verilator lint_on WIDTHEXPAND */
	/* verilator lint_on WIDTHTRUNC */
endmodule //uart_test
