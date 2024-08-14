`include "./include/QianTang_header.v"
`include "Instr_path.v"
module SRAM_test #(
    parameter SRAM_DATA_BIT  = 256,
    parameter SRAM_ADDR_BIT  = `RAM_DATA_SIZE - $clog2(SRAM_DATA_BIT/8)
) (
    input                       clk_sys_i,
    input                       IF_SRAM_ena_i,
    input                       IF_SRAM_wea_i,
    input      [SRAM_ADDR_BIT-1:0]        IF_SRAM_addr_i,
    input      [SRAM_DATA_BIT-1:0]        IF_SRAM_data_i,
    output reg [SRAM_DATA_BIT-1:0]        IF_SRAM_data_o,

    input                       MEM_SRAM_ena_i,
    input                       MEM_SRAM_wea_i,
    input      [SRAM_ADDR_BIT-1:0]            MEM_SRAM_addr_i,
    input      [SRAM_DATA_BIT-1:0]        MEM_SRAM_data_i,
    output reg [SRAM_DATA_BIT-1:0]        MEM_SRAM_data_o
);

integer i;
    // //? 内存存储器 8位 2^`RAM_DATA_SIZE深度
    reg [7:0] SRAM [2**`RAM_DATA_SIZE-1:0];
    initial begin
        $readmemh(`INSTR_PATH, SRAM);
    end


    /* verilator lint_off WIDTHEXPAND */
     //? Debug
    /* verilator lint_off UNUSEDSIGNAL */
    wire [`RAM_DATA_SIZE-1:0] addr_test =  16'hAB60;
    reg [63:0] SRAM_wire;
    always @(*) begin
        for(i=0; i<8;i=i+1)
            SRAM_wire[i*8+:8] = SRAM[addr_test+i];
    end
    /* verilator lint_on UNUSEDSIGNAL */
    wire [$clog2(SRAM_DATA_BIT/8)-1:0] zero = 0;

    
    //? IF Cache 
    wire [`RAM_DATA_SIZE-1:0] IF_SRAM_addr_i_expand = {IF_SRAM_addr_i, zero};
    /* verilator lint_off BLKSEQ */
    always @(posedge clk_sys_i ) begin
        if (IF_SRAM_ena_i) begin
            if(!IF_SRAM_wea_i) begin
                for (i = 0; i <2**$clog2(SRAM_DATA_BIT/8); i = i+1)begin
                    IF_SRAM_data_o[i*8+:8] = SRAM[IF_SRAM_addr_i_expand+i];
                end   
            end else begin
                for (i = 0; i <2**$clog2(SRAM_DATA_BIT/8); i = i+1)
                    SRAM[IF_SRAM_addr_i_expand+i] = IF_SRAM_data_i[i*8+:8];
            end 
        end
    end

    //? Memory Cache 
    wire [`RAM_DATA_SIZE-1:0] MEM_SRAM_addr_i_expand = {MEM_SRAM_addr_i, zero};
    /* verilator lint_off BLKSEQ */
    always @(posedge clk_sys_i ) begin
        if (MEM_SRAM_ena_i) begin
            if(!MEM_SRAM_wea_i) begin
                for (i = 0; i <2**$clog2(SRAM_DATA_BIT/8); i = i+1)begin
                    MEM_SRAM_data_o[i*8+:8] = SRAM[MEM_SRAM_addr_i_expand+i];
                end   
            end else begin
                for (i = 0; i <2**$clog2(SRAM_DATA_BIT/8); i = i+1)
                    SRAM[MEM_SRAM_addr_i_expand+i] = MEM_SRAM_data_i[i*8+:8];
            end 
        end
    end

    /* verilator lint_on WIDTHEXPAND */
    /* verilator lint_on BLKSEQ */




    /* verilator lint_off UNUSEDSIGNAL */
    // wire [63:0] SRAM_data_i_test ;
    // assign SRAM_data_i_test = SRAM_data_i[addr_test[6:0]*8 +:64];
    /* verilator lint_on UNUSEDSIGNAL */
endmodule //SRAM_test
