//! 该模块实现了小端模式存取,
`include "./include/QianTang_header.v"
// `include "./real_time.v"

module Memory #(
    parameter SETS_BIT       = 1         , 
    parameter TAG_BIT        = 10         ,
    parameter INDEX_BIT      = 2         ,
    parameter OFFSET_BIT     = 4         ,
    parameter CACHE_DATA_BIT = `REG_WIDTH,
    parameter SRAM_DATA_BIT  = 128       ,
    parameter REG_NUMBER     = 16
)(           
    output print_hit,
        input                          clk_sys_i           ,
        input      [7:0]               ctrl_i              ,                              
        input      [4:0]               rd_i                ,
        /* verilator lint_off UNUSEDSIGNAL */
        input      [`REG_WIDTH-1:0]    result_i            ,
        /* verilator lint_on UNUSEDSIGNAL */
        input      [`REG_WIDTH-1:0]    data_i              ,
        output reg [7:0]               ctrl_o              ,
        output reg [4:0]               rd_o                ,
        output reg [`REG_WIDTH-1:0]    result_o            ,
        output                         time_intr_o         ,
        output                         software_intr_o     ,
        input                          ALU_ena_forwarding_i,
        output reg                     MEM_ena_forwarding_o,
        output reg                     LD_ena_forwarding_o,
        output reg [`REG_WIDTH-1:0]    LD_data_forwarding_o,

        /* verilator lint_off UNUSEDSIGNAL */
        input      [$clog2(REG_NUMBER)+1:0]     Print_data_addr_i,
        output reg [31:0]                       MEM_Print_data_o,
        input                                   Print_finish_i,
        output                                  MEM_Print_start_o,
        /* verilator lint_on UNUSEDSIGNAL */
        output CACHE_miss_o ,

        output                                  SRAM_ena_o ,
        output                                  SRAM_wea_o ,
        output [SRAM_ADDR_BIT-1:0]              SRAM_addr_o,
        output [SRAM_DATA_BIT-1:0]              SRAM_data_o,
        input  [SRAM_DATA_BIT-1:0]              SRAM_data_i
    );







    localparam SRAM_ADDR_BIT  = `RAM_DATA_SIZE - $clog2(SRAM_DATA_BIT/8);
    integer i;

    reg  [`REG_WIDTH-1:0] mem_w ;
    /* verilator lint_off UNUSEDSIGNAL */
    reg  [7:0]            print_ram [`PRINT_DEPTH-1:0];
    wire [`RAM_DATA_SIZE-1:0] print_addr;
    // wire print_hit;
    /* verilator lint_off WIDTHTRUNC */
    wire [9:0] print_ram_addr;
    assign print_addr = `PRINT_ADDR;
    assign print_hit = (addr[`RAM_DATA_SIZE-1:0] >= `PRINT_ADDR) & (addr[`RAM_DATA_SIZE-1:0] < `PRINT_ADDR +`PRINT_DEPTH);
    assign print_ram_addr = addr[`RAM_DATA_SIZE-1:0] - print_addr;
    /* verilator lint_on WIDTHTRUNC */
    //! CLINT 
    wire       clk_real_time_o     ;
    wire       clk_mtime_sync_up_o ;
    wire [`REG_WIDTH-1:0] addr  ;
    reg        msip                /*verilator public_flat_rd*/;
    reg [63:0] mtime               /*verilator public_flat_rd*/;
    reg [63:0] mtimecmp            /*verilator public_flat_rd*/;
    wire msip_hit    ;
    wire mtime_hit   ;
    wire mtimecmp_hit;
    assign msip_hit            = (addr[`RAM_DATA_SIZE-1:0]==`MMIO_MSIP    );
    assign mtime_hit           = (addr[`RAM_DATA_SIZE-1:0]==`MMIO_MTIME   );
    assign mtimecmp_hit        = (addr[`RAM_DATA_SIZE-1:0]==`MMIO_MTIMECMP);
    assign time_intr_o     = (mtime >= mtimecmp) ;
    assign software_intr_o = msip ;
    assign addr = result_i;
    
    /* verilator lint_off WIDTHEXPAND */
    /* verilator lint_off WIDTHTRUNC */
    reg [2:0] data_width_i;
    /* verilator lint_off LATCH */
    always @(*) begin
        if((ctrl_i[6:3] == `CTRL_ACCESS_I) | (ctrl_i[6:3] ==`CTRL_ACCESS_S))begin
            case(ctrl_i[1:0])
                2'b00: data_width_i = 3'd0;
                2'b01: data_width_i = 3'd1;
                2'b10: data_width_i = 3'd3;
                2'b11: data_width_i = 3'd7;
            endcase
        end
    end
    /* verilator lint_on LATCH */
    always @(*) begin
        if(ctrl_i[6:3] == `CTRL_ACCESS_I)begin   //! 读取
            LD_ena_forwarding_o =1;
            for(i = 0; i <= 7; i = i + 1)begin
                if(i>data_width_i)
                        LD_data_forwarding_o [i*8+:8] = (ctrl_i[2]) ? {8{1'b0}}: {8{mem_w[(data_width_i+1)*8-1]}};
                else    LD_data_forwarding_o [i*8+:8] = mem_w [i*8+:8];
            end
                
            // for(i = data_width_i+1; i <= 7; i = i + 1 )begin
            //     if (ctrl_i[2]) LD_data_forwarding_o [i*8+:8] = {8{1'b0}};
            //     else           LD_data_forwarding_o [i*8+:8] = {8{mem_w[(data_width_i+1)*8-1]}};
            // end

        end else begin
            LD_ena_forwarding_o = 0;
            LD_data_forwarding_o = 0;
        end
    end

    wire non_cache_hit ;
    assign non_cache_hit = print_hit | msip_hit | mtime_hit | mtimecmp_hit;

    //? 小端模式访存

    always @(*) begin
        if(addr == 64'h3ffffffb20)begin
            mem_w = 'h1;
        end else if(non_cache_hit)begin
            if(print_hit)begin
                for(i = 0; i < `REG_WIDTH /8 ; i = i+1)begin
                    if(i==0) mem_w [7:0]    = {7'b0, Print_finish_i};
                    else mem_w [i*8+:8]     = print_ram [print_ram_addr + i];
                end
            end else if(msip_hit)begin
                mem_w[0] = msip ;
                mem_w[`REG_WIDTH-1:1] = 'b0;
            end else if(mtime_hit)begin
                mem_w  = mtime;
            end else if(mtimecmp_hit)begin
                mem_w  = mtimecmp;
            end else 
                mem_w  = 0;
        end else begin
            mem_w  = CACHE_data_o;
        end
    end

    always @(posedge clk_sys_i) begin
        if(ctrl_i[6:3] == `CTRL_ACCESS_I) MEM_ena_forwarding_o <= 1'b1;
        else                              MEM_ena_forwarding_o <= ALU_ena_forwarding_i;
    end

    assign       CACHE_addr_i = addr[`RAM_DATA_SIZE-1:0];
    assign       CACHE_data_width_i = data_width_i;
    assign       CACHE_data_i = data_i;

//? Cache控制
    always @(*) begin
        if(non_cache_hit)begin
            CACHE_ena_i = 0;
            CACHE_wea_i = 0;
        end else if(ctrl_i[6:3] == `CTRL_ACCESS_I)begin  
            CACHE_ena_i  = 1;
            CACHE_wea_i  = 0;
        end else if (ctrl_i[6:3] ==`CTRL_ACCESS_S)begin
            CACHE_ena_i = 1;
            CACHE_wea_i = 1;
        end else begin
            CACHE_ena_i = 0;
            CACHE_wea_i = 0;
        end
    end
    always @(posedge clk_sys_i ) begin
        if((ctrl_i[6:3] == `CTRL_ACCESS_S)&(mtime_hit))begin
            for(i = 0; i <= data_width_i ; i = i+1)
                mtime[i*8+:8]  <= data_i[i*8+:8];
        end else if(clk_mtime_sync_up_o)begin
            mtime <= mtime+1;
        end else 
            mtime <= mtime;
    end
/* verilator lint_off BLKSEQ */
    always@(posedge clk_sys_i) begin     
        rd_o   <= rd_i;
        ctrl_o <= ctrl_i;
        if(ctrl_i[6:3] == `CTRL_ACCESS_I)begin   //! 读取
            for(i = 0; i <= 7; i = i + 1)begin
                if(i>data_width_i)
                        result_o [i*8+:8] <= (ctrl_i[2]) ? {8{1'b0}}: {8{mem_w[(data_width_i+1)*8-1]}};
                else    result_o [i*8+:8] <= mem_w [i*8+:8];
            end
            // for(i = 0; i <= data_width_i; i = i + 1)
            //     result_o [i*8+:8] <= mem_w [i*8+:8];
            // for(i = data_width_i+1; i <= 7; i = i + 1 )
            //     if (ctrl_i[2]) result_o [i*8+:8] <= {8{1'b0}};
            //     else           result_o [i*8+:8] <= {8{mem_w[(data_width_i+1)*8-1]}};
        end else if((ctrl_i[6:3] == `CTRL_ACCESS_S)&(non_cache_hit)) begin //! 存储
            if(print_hit)begin
                for(i = 0; i <= data_width_i ; i = i+1)
                    print_ram[print_ram_addr + i] = data_i[i*8+:8];
            end else if(msip_hit)begin
                msip  <= data_i[0];
            end else if(mtimecmp_hit)begin
                for(i = 0; i <= data_width_i ; i = i+1)
                    mtimecmp[i*8]  <= data_i[i*8+:8];
            end 
        end else begin
            result_o <= result_i;
        end
    end
/* verilator lint_on BLKSEQ */
    //! 真实时钟

    real_time u_real_time(
        .clk_sys_i       	( clk_sys_i        ),
        .clk_real_time_o 	( clk_real_time_o  )
    );
    //! 上升沿同步
/* verilator lint_off PINMISSING */
    slow_2_fast_sync u_slow_2_fast_sync(
        .clk_i       	( clk_sys_i        ),
        .async_i     	( clk_real_time_o  ),
        .sync_up_o   	( clk_mtime_sync_up_o)
    );
    
    always @(*) begin
        MEM_Print_data_o[7:0]   = print_ram[Print_data_addr_i  ];
        MEM_Print_data_o[15:8]  = print_ram[Print_data_addr_i+1];
        MEM_Print_data_o[23:16] = print_ram[Print_data_addr_i+2];
        MEM_Print_data_o[31:24] = print_ram[Print_data_addr_i+3];
    end
    /* verilator lint_off UNUSEDSIGNAL */
    wire [7:0] start = print_ram[1];
    assign MEM_Print_start_o = start[0];
    /* verilator lint_on UNUSEDSIGNAL */
    reg CACHE_ena_i;
    reg CACHE_wea_i;
    wire [2:0]CACHE_data_width_i;
    wire [`RAM_DATA_SIZE-1:0]CACHE_addr_i;
    wire [`REG_WIDTH-1:0]CACHE_data_i;
    wire [`REG_WIDTH-1:0]           	            CACHE_data_o;


    Cache_sets #(
        .SETS_BIT       	( SETS_BIT     ),
        .TAG_BIT        	( TAG_BIT    ),
        .INDEX_BIT      	( INDEX_BIT     ),
        .OFFSET_BIT     	( OFFSET_BIT    ),
        .CACHE_DATA_BIT 	( CACHE_DATA_BIT    ),
        .SRAM_DATA_BIT  	( SRAM_DATA_BIT  )
    )MEM_Cache_sets(
        .clk                	( clk_sys_i           ),
        .CACHE_ena_i        	( CACHE_ena_i         ),
        .CACHE_wea_i        	( CACHE_wea_i         ),
        .CACHE_data_width_i 	( CACHE_data_width_i  ),
        .CACHE_addr_i       	( CACHE_addr_i        ),
        .CACHE_data_i       	( CACHE_data_i        ),
        .CACHE_data_o       	( CACHE_data_o        ),
        .CACHE_miss_o       	( CACHE_miss_o        ),
        .SRAM_ena_o         	( SRAM_ena_o          ),
        .SRAM_wea_o         	( SRAM_wea_o          ),
        .SRAM_addr_o        	( SRAM_addr_o         ),
        .SRAM_data_i        	( SRAM_data_i         ),
        .SRAM_data_o        	( SRAM_data_o         )
    );





/* verilator lint_on PINMISSING */
/* verilator lint_on WIDTHEXPAND */
/* verilator lint_on WIDTHTRUNC */
endmodule //IM
