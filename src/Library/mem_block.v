module mem_block #(
    parameter SIZE   = 8,
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64
)(
    input                                               clk_i,
    input  [$clog2(DATA_WIDTH/SIZE):0]                  write_bits_i,
    input  [ADDR_WIDTH-1:0]                             addr_i,
    input  [DATA_WIDTH-1:0]                             data_i,
    output [DATA_WIDTH-1:0]                             data_o
);
    
    // 
    generate
        genvar i;
        if(ADDR_WIDTH<=16) begin: less_and_equal_16
            reg [SIZE-1:0] block [2**ADDR_WIDTH-1:0];
            for(i=0; i<DATA_WIDTH / SIZE ; i = i + 1 ) begin
                assign data_o[i * 8 +: 8]  = block[addr_i + i];
            end
            integer x;
            /* verilator lint_off WIDTHEXPAND */
            /* verilator lint_off BLKSEQ */
            always @(posedge clk_i) begin
                for (x = 0; x < write_bits_i ; x = x + 1) begin 
                    block[addr_i + x] =  data_i[x * 8 +: 8];
                end
            end
            /* verilator lint_on BLKSEQ */
            /* verilator lint_on WIDTHEXPAND */
        end else begin: more_16
            for(i= 0; i < (2**(ADDR_WIDTH-16)); i=i+1) begin: mem_block
                reg [SIZE-1:0] block [2**16-1:0];
            end
            for(i=0; i<DATA_WIDTH / SIZE ; i = i + 1 ) begin
                assign data_o[i * 8 +: 8]  = mem_block[addr_i[ADDR_WIDTH-1:16]].block[addr_i[15:0] + i];
            end
            integer x;
            /* verilator lint_off WIDTHEXPAND */
            /* verilator lint_off BLKSEQ */
            always @(posedge clk_i) begin
                for (x = 0; x < write_bits_i ; x = x + 1) begin 
                    mem_block[addr_i[ADDR_WIDTH-1:16]].block[addr_i[15:0] + x] =  data_i[x * 8 +: 8];
                end
            end
            /* verilator lint_on BLKSEQ */
            /* verilator lint_on WIDTHEXPAND */
        end
    endgenerate

endmodule //mem_block
