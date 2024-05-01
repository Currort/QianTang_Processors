//! 参考链接https://zhuanlan.zhihu.com/p/636322548
//! 该模块实现了一个组相连Cache，总容量1KB，Cache Line Size 64B，256组cache块
//! 
//! addr 16bit    tag 8bit   index 4bit   offset 4bit 
// `include "./include/QianTang_header.v"
// `include "./Library/Arbiter.v"

//?  要求 offset = clog2(SRAM_DATA_BIT / 8)

module Cache_sets #(
    parameter SETS_BIT       = 1,
    parameter TAG_BIT        = 10,
    parameter INDEX_BIT      = 2,
    parameter OFFSET_BIT     = 4,
    parameter CACHE_DATA_BIT = 64,
    parameter SRAM_DATA_BIT  = 128
) (
    input                                   clk ,
    // input                                   rst ,
    input                                   CACHE_ena_i,
    input                                   CACHE_wea_i,
    input  [$clog2(CACHE_DATA_BIT/8)-1:0]   CACHE_data_width_i,
    input  [CACHE_ADDR_BIT-1:0]             CACHE_addr_i,
    input  [CACHE_DATA_BIT-1:0]             CACHE_data_i,
    output reg [CACHE_DATA_BIT-1:0]         CACHE_data_o,
    output                                  CACHE_miss_o ,
        
    output reg                              SRAM_ena_o ,
    output reg                              SRAM_wea_o ,
    output reg [SRAM_ADDR_BIT-1:0]          SRAM_addr_o,
    input      [SRAM_DATA_BIT-1:0]          SRAM_data_i,
    output reg [SRAM_DATA_BIT-1:0]          SRAM_data_o
);  
    localparam  CACHE_ADDR_BIT = TAG_BIT + INDEX_BIT + OFFSET_BIT ;
    localparam  SRAM_ADDR_BIT  = CACHE_ADDR_BIT - $clog2(SRAM_DATA_BIT/8);
    genvar i;
    integer j;


    //? 检查addr可能读取的最后一个地址，是否命中
    /* verilator lint_off UNUSEDSIGNAL */
    wire [CACHE_ADDR_BIT-1:0]           addr_e    ;
    wire [TAG_BIT-1:0]        	        tag_e     ;
    wire [INDEX_BIT-1:0]      	        index_e   ;
    wire [OFFSET_BIT-1:0]      	        offset_e  ;
    wire                                overflow_e ;

    assign addr_e   = CACHE_addr_i + (CACHE_DATA_BIT/8)-1;
    assign tag_e    = addr_e [CACHE_ADDR_BIT-1         : CACHE_ADDR_BIT-TAG_BIT];
    assign index_e  = addr_e [OFFSET_BIT+INDEX_BIT-1   : OFFSET_BIT];
    assign offset_e = addr_e [OFFSET_BIT-1             : 0];
    assign overflow_e = (index_e != index);


    /* verilator lint_on UNUSEDSIGNAL */
    //? 输入 addr 拆分
    wire [TAG_BIT-1:0]        	tag;
    wire [INDEX_BIT-1:0]      	index;
    wire [OFFSET_BIT-1:0]     	offset;

    assign tag    =    (hit_e)  ?  CACHE_addr_i [CACHE_ADDR_BIT-1       : CACHE_ADDR_BIT-TAG_BIT] :tag_e ;
    assign index  =    (hit_e)  ?  CACHE_addr_i [OFFSET_BIT+INDEX_BIT-1 : OFFSET_BIT]             :index_e ;
    assign offset =                CACHE_addr_i [OFFSET_BIT-1           : 0]                       ;
    


//? cache line data, tags, valid, dirty
    reg  [7:0]           data_r    [(2**(SETS_BIT+INDEX_BIT+OFFSET_BIT))-1:0] ;
    reg  [TAG_BIT-1:0]   tags_r    [(2**(SETS_BIT+INDEX_BIT))-1:0] ;
    reg                  valid_r   [(2**(SETS_BIT+INDEX_BIT))-1:0] ;
    reg                  dirty_r   [(2**(SETS_BIT+INDEX_BIT))-1:0] ;
    reg  [SETS_BIT-1:0]  sets_cnt  [(2**INDEX_BIT)-1:0];

//? 是否命中
    wire   [2**SETS_BIT-1:0]   hits_w ;
    wire   [SETS_BIT-1:0]      hit_binary ;
    wire                       hit ;   

    wire   [2**SETS_BIT-1:0]   hits_w_e ;
    wire   [SETS_BIT-1:0]      hit_binary_e ;
    wire                       hit_e ;   
    generate
        for(i = 0 ; i < 2**SETS_BIT; i = i + 1)begin :hits_gen
            assign hits_w[i]    = valid_r[{i[SETS_BIT-1:0], index}] & (tag == tags_r[{i[SETS_BIT-1:0], index}]);
            assign hits_w_e[i]  = valid_r[{i[SETS_BIT-1:0], index_e}] & (tag_e == tags_r[{i[SETS_BIT-1:0], index_e}]);
        end
    endgenerate
    assign hit = |hits_w;
    assign hit_e = |hits_w_e;

    Arbiter #(
        .WIDTH        	( 2**SETS_BIT),
        .ONE_HOT_CODE 	( 1'b0  )
    )u_Arbiter(
        .request_i 	( hits_w     ),
        .grant_o   	( hit_binary )
    );

    Arbiter #(
        .WIDTH        	( 2**SETS_BIT),
        .ONE_HOT_CODE 	( 1'b0  )
    )u_Arbiter_e(
        .request_i 	( hits_w_e     ),
        .grant_o   	( hit_binary_e )
    );

/* verilator lint_off WIDTHEXPAND */
//? Cache 缓存数据输出
    always @(*) begin
        if(overflow_e)begin
            for(j=0 ; j < (CACHE_DATA_BIT/8) ; j = j+1)begin
                if(j < (CACHE_DATA_BIT/8)-1-offset_e )
                    CACHE_data_o[j*8+:8] = (CACHE_ena_i)? data_r [{hit_binary, index, offset+j[OFFSET_BIT-1:0]}] : 0;
                else 
                    CACHE_data_o[j*8+:8] = (CACHE_ena_i)? data_r [{hit_binary_e, index_e, offset+j[OFFSET_BIT-1:0]}] :0;
            end
        end else 
            for(j=0 ; j < (CACHE_DATA_BIT/8) ; j = j+1)
                CACHE_data_o[j*8+:8] =  data_r[{hit_binary, index, offset+j[OFFSET_BIT-1:0]}];
    end






//? 未命中cache触发暂停，并开始从SRAM读取data
    assign CACHE_miss_o        = CACHE_ena_i & ~hit;
    
//? 若该set未使用则直接读
    wire direct_read;
    assign direct_read = CACHE_ena_i & ~dirty_r[{sets_cnt[index], index}];

    

    reg [2:0] c_state;
    reg [2:0] n_state;
    localparam DISABLE     = 3'd0;   
    localparam READ        = 3'd1;
    localparam READ_DELAY  = 3'd2;
    localparam WRITE       = 3'd3;
    localparam WRITE_DELAY = 3'd4;

    always @(posedge clk) begin
        c_state <= n_state;  
    end

    always @(*) begin
        case(c_state)
            DISABLE :begin
                if(CACHE_miss_o)begin
                    if(direct_read)     n_state = READ;
                    else                n_state = WRITE;
                end else                n_state = DISABLE; 
            end
            READ :                      n_state = READ_DELAY;
            READ_DELAY :                n_state = DISABLE;
            WRITE :                     n_state = WRITE_DELAY;
            WRITE_DELAY:                n_state = READ;
            default: n_state = DISABLE;
        endcase
    end

    

    always @(posedge clk) begin
        case(n_state)
            DISABLE :begin
                SRAM_ena_o  <= 0;
                SRAM_wea_o  <= 0;
            end READ :begin
                SRAM_ena_o  <= 1;
                SRAM_wea_o  <= 0;
                SRAM_addr_o <= {tag, index};
            end READ_DELAY:begin
                
            end WRITE :begin
                SRAM_ena_o  <= 1;
                SRAM_wea_o  <= 1;
                SRAM_addr_o <= {tags_r[{sets_cnt[index], index}], index};
                for(j = 0 ; j < SRAM_DATA_BIT/8 ; j = j + 1)
                    SRAM_data_o[j*8+:8] <= data_r[{sets_cnt[index], index, j[OFFSET_BIT-1:0]}];
            end WRITE_DELAY :begin

            end default : ;
        endcase
    end

//? data_r 写
    /* verilator lint_off BLKSEQ */
    always @(posedge clk) begin
        if(CACHE_wea_i & hit & CACHE_ena_i)begin
            if(overflow_e)begin
                for(j=0 ; j <= CACHE_data_width_i ; j = j+1)begin
                    if(j < (CACHE_DATA_BIT/8)-1-offset_e )
                        data_r [{hit_binary, index, offset+j[OFFSET_BIT-1:0]}] = CACHE_data_i[(j*8) +: 8];
                    else 
                        data_r [{hit_binary_e, index_e, offset+j[OFFSET_BIT-1:0]}] = CACHE_data_i[(j*8) +: 8];
                end
            end else 
                for(j=0 ; j <= CACHE_data_width_i ; j = j+1)
                    data_r [{hit_binary, index, offset+j[OFFSET_BIT-1:0]}] = CACHE_data_i[(j*8) +: 8];
        end else if((c_state == READ_DELAY))begin
            for(j = 0 ; j < SRAM_DATA_BIT/8 ; j = j + 1)
                data_r [{sets_cnt[index], index, j[OFFSET_BIT-1:0]}] = SRAM_data_i[(j*8) +: 8];
        end
    end
    /* verilator lint_on BLKSEQ */

//? valid tags dirty sets_cnt 控制
    always @(posedge clk ) begin
        if (c_state == READ_DELAY) begin
            valid_r[{sets_cnt[index], index}]  <= 1;
            tags_r [{sets_cnt[index], index}]  <= tag;
            sets_cnt[index] <= sets_cnt[index] + 1;
        end else if (n_state == WRITE_DELAY) begin
            dirty_r[{sets_cnt[index], index}]  <= 0;
        end else if (CACHE_wea_i & hit & CACHE_ena_i) begin
            dirty_r[{hit_binary, index}]  <= 1;
        end
    end
/* verilator lint_on WIDTHEXPAND */
endmodule //Cache_sets
