//! 参考链接https://zhuanlan.zhihu.com/p/636322548
//! 该模块实现了一个4路组相连Cache，总容量64KB，Cache Line Size 64B，256组cache块，支持切换32/64位指令集，支持修改寻址范围
//! 
// 32bit addr  index 8bit offset 6bit 
`include "./include/QianTang_header.v"

module Cache_4ways (
    input                    clk_sys_i,
    input                    ena_i,
    input                    write_load_switch_i,
    input [3:0]              funct,
    input [`REG_WIDTH-1:0]   cache_addr_i,
    output[`REG_WIDTH-1:0]   ram_data_o,
    output                   tag_hit
);
    wire [`RAM_SIZE-5:0]    tag    = cache_addr_i[`RAM_SIZE-1:4];
    wire [7:0]              index  = cache_addr_i[13:6];
    wire [5:0]              offset = cache_addr_i[5:0];


    reg [7:0]           cache_line_data_r [255:0] [3:0] [63:0] ; 
    reg [`RAM_SIZE-5:0] cache_line_tag_r  [255:0] [3:0];
    reg                 cache_valid_r     [255:0] ;

    //! 由 index寻组，组内并行比较 tag，若命中则 tag_hit 置 1
    wire [`RAM_SIZE-5:0] line0_tag   = (cache_valid_r[index]) ? cache_line_tag_r[index][0] : 0;
    wire [`RAM_SIZE-5:0] line1_tag   = (cache_valid_r[index]) ? cache_line_tag_r[index][1] : 0;
    wire [`RAM_SIZE-5:0] line2_tag   = (cache_valid_r[index]) ? cache_line_tag_r[index][2] : 0;
    wire [`RAM_SIZE-5:0] line3_tag   = (cache_valid_r[index]) ? cache_line_tag_r[index][3] : 0;
  
    wire                 line0_hit   = (cache_valid_r[index]) ? (tag==line0_tag) : 0;
    wire                 line1_hit   = (cache_valid_r[index]) ? (tag==line1_tag) : 0;
    wire                 line2_hit   = (cache_valid_r[index]) ? (tag==line2_tag) : 0;
    wire                 line3_hit   = (cache_valid_r[index]) ? (tag==line3_tag) : 0;

    wire [1:0] line_hit = line1_hit+line2_hitline3_hit;

    wire tag_hit   = line0_hit|line1_hit|line2_hit|line3_hit;

    //! tag_hit 置1后根据指令搬运数据
    //! 计划通过ddr3内存读取，目前为读取ram ip核
always @(*) begin
    if (tag_hit) begin
        if(write_load_switch_i)begin
            case (funct)
                `SB:begin
                    ram_data_o=cache_line_data_r[idnex][line_hit][offset];
                end `SH:begin
                    ram_data_o={cache_line_data_r[idnex][line_hit][offset],cache_line_data_r[idnex][line_hit][offset+1]};
                    //? -1?
                end `SW:begin
                    ram_data_o={cache_line_data_r[idnex][line_hit][offset],cache_line_data_r[idnex][line_hit][offset+1],
                                cache_line_data_r[idnex][line_hit][offset+2],cache_line_data_r[idnex][line_hit][offset+3]};
                    //? -1?
                end default:begin
                end
            endcase
        end
    end
end

always @(posedge clk_sys_i) begin
    case 
        
    endcase
end




endmodule //Cache_4ways
