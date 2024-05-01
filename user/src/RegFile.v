//! 该模块实现了整数通用寄存器只有译码阶段才会读取寄存器，写回阶段才会写入寄存器，所以整数通用寄存器有两个读端口和一个写端口
//! 未完成优化：门控时钟
`include "./include/QianTang_header.v"
module RegFile(
        input                            rst_i            ,
        input                            clk_sys_i        ,
        input  [4:0]                     rst1_addr_i      ,
        input  [4:0]                     rst2_addr_i      ,
        input  [4:0]                     rd_addr_i        ,
        input                            rd_wen_i         , 
        input  [`REG_WIDTH-1:0]          result_i         ,
        output reg [`REG_WIDTH-1:0]          rst1_o           ,
        output reg [`REG_WIDTH-1:0]          rst2_o           


    );
    integer i;
    reg [`REG_WIDTH-1:0] rst [31:0] ;

    wire [`REG_WIDTH-1:0] zero  /*verilator public_flat_rd*/ =rst[0];
    wire [`REG_WIDTH-1:0] ra    /*verilator public_flat_rd*/ =rst[1];
    wire [`REG_WIDTH-1:0] sp    /*verilator public_flat_rd*/ =rst[2];
    wire [`REG_WIDTH-1:0] gp    /*verilator public_flat_rd*/ =rst[3];
    wire [`REG_WIDTH-1:0] tp    /*verilator public_flat_rd*/ =rst[4];
    wire [`REG_WIDTH-1:0] t0    /*verilator public_flat_rd*/ =rst[5];
    wire [`REG_WIDTH-1:0] t1    /*verilator public_flat_rd*/ =rst[6];
    wire [`REG_WIDTH-1:0] t2    /*verilator public_flat_rd*/ =rst[7];
    wire [`REG_WIDTH-1:0] s0    /*verilator public_flat_rd*/ =rst[8];
    wire [`REG_WIDTH-1:0] s1    /*verilator public_flat_rd*/ =rst[9];
    wire [`REG_WIDTH-1:0] a0    /*verilator public_flat_rd*/ =rst[10];
    wire [`REG_WIDTH-1:0] a1    /*verilator public_flat_rd*/ =rst[11];
    wire [`REG_WIDTH-1:0] a2    /*verilator public_flat_rd*/ =rst[12];
    wire [`REG_WIDTH-1:0] a3    /*verilator public_flat_rd*/ =rst[13];
    wire [`REG_WIDTH-1:0] a4    /*verilator public_flat_rd*/ =rst[14];
    wire [`REG_WIDTH-1:0] a5    /*verilator public_flat_rd*/ =rst[15];
    wire [`REG_WIDTH-1:0] a6    /*verilator public_flat_rd*/ =rst[16];
    wire [`REG_WIDTH-1:0] a7    /*verilator public_flat_rd*/ =rst[17];
    wire [`REG_WIDTH-1:0] s2    /*verilator public_flat_rd*/ =rst[18];
    wire [`REG_WIDTH-1:0] s3    /*verilator public_flat_rd*/ =rst[19];
    wire [`REG_WIDTH-1:0] s4    /*verilator public_flat_rd*/ =rst[20];
    wire [`REG_WIDTH-1:0] s5    /*verilator public_flat_rd*/ =rst[21];
    wire [`REG_WIDTH-1:0] s6    /*verilator public_flat_rd*/ =rst[22];
    wire [`REG_WIDTH-1:0] s7    /*verilator public_flat_rd*/ =rst[23];
    wire [`REG_WIDTH-1:0] s8    /*verilator public_flat_rd*/ =rst[24];
    wire [`REG_WIDTH-1:0] s9    /*verilator public_flat_rd*/ =rst[25];
    wire [`REG_WIDTH-1:0] s10   /*verilator public_flat_rd*/ =rst[26];
    wire [`REG_WIDTH-1:0] s11   /*verilator public_flat_rd*/ =rst[27];
    wire [`REG_WIDTH-1:0] t3    /*verilator public_flat_rd*/ =rst[28];
    wire [`REG_WIDTH-1:0] t4    /*verilator public_flat_rd*/ =rst[29];
    wire [`REG_WIDTH-1:0] t5    /*verilator public_flat_rd*/ =rst[30];
    wire [`REG_WIDTH-1:0] t6    /*verilator public_flat_rd*/ =rst[31];




    always @(posedge clk_sys_i) begin
        if(rst_i) begin //? 模拟spike中 pk程序加载后初始值
            for(i = 0; i < 32 ; i = i+1) begin
                if (i==2) rst[2] <= 64'h0000003ffffffb20;
                else      rst[i] <= 0;
            end
            // rst[3] <= 64'h000000000009012;
        end
        else if (rd_addr_i == 0) ;
        else if (rd_wen_i) rst [rd_addr_i] <= result_i;
    end

    always @(*) begin
        if     (rst1_addr_i == 0) rst1_o =0 ;
        else rst1_o = rst[rst1_addr_i];
    end

    always @(*) begin
        if     (rst2_addr_i == 0) rst2_o =0 ;
        else rst2_o = rst[rst2_addr_i];
    end



    endmodule //RegFile
    
