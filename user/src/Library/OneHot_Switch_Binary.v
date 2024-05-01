module OneHot_Switch_Binary #(
    parameter WIDTH     = 4,
    parameter TO_BINARY = 1
)(
    input [(WIDTH)*TO_BINARY+$clog2(WIDTH)*(!TO_BINARY)-1:0] in,
    output reg [(WIDTH)*(!TO_BINARY)+$clog2(WIDTH)*TO_BINARY-1:0] out
);
    integer i;
    generate
        if (TO_BINARY) begin : to_binary
            always @(*) begin
                for (i = 0; i<WIDTH ; i = i+1) begin
                    if(in == 0) out = 0;
                    else if(in[i]) out = i;
                end
            end
        end else begin : to_one_hot
            always @(*) begin
                for (i = 0; i<WIDTH ; i = i+1) begin
                    if(i==in) out[i] =1;
                    else      out[i] =0;
                end
            end
        end
    endgenerate



endmodule