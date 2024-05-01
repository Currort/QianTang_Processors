`include "./include/QianTang_header.v"
module C_instr_decode (
    input  [15:0]               instr_i           ,
    output reg [31:0]           instr_unfold_o    
);
//? 压缩指令转完整指令
    wire [1:0]  opcode       = instr_i[1:0];
    wire [4:0]  rst2         = instr_i[6:2];
    wire [4:0]  rst1         = instr_i[11:7];
    wire [2:0]  funct3       = instr_i[15:13]; 

    wire [4:0]  rst2_a       = {2'b01,instr_i[4:2]};
    wire [4:0]  rst1_a       = {2'b01,instr_i[9:7]};

    wire [2:0]  funct5       = {instr_i[12], instr_i[6:5]};
    wire [1:0]  funct6       = instr_i[11:10];

    wire [11:0] imm_A        = {{6{instr_i[12]}},instr_i[12],instr_i[6:2]};
    wire [5:0]  imm_L        = {instr_i[12],instr_i[6:2]};
    wire [10:0] imm_J        = {instr_i[12], instr_i[8], instr_i[10:9], instr_i[6], instr_i[7], instr_i[2], instr_i[11], instr_i[5:3]};
    wire [11:0] imm_ADDI16SP = {{2{instr_i[12]}}, instr_i[12], instr_i[4:3], instr_i[5], instr_i[2], instr_i[6],4'b0};
    wire [11:0] imm_ADDI4SP  = {2'b0, instr_i[10:7], instr_i[12:11], instr_i[5], instr_i[6], 2'b0};
    wire [19:0] imm_LUI      = {14'b0, instr_i[12], instr_i[6:2]};
    wire [7:0]  imm_B        = {instr_i[12], instr_i[6:5], instr_i[2], instr_i[11:10], instr_i[4:3]};
    wire [11:0] imm_LW       = {5'b0, instr_i[5], instr_i[12:10], instr_i[6], 2'b0};
    wire [11:0] imm_LD       = {4'b0, instr_i[6], instr_i[5], instr_i[12:10], 3'b0};
    wire [11:0] imm_LWSP     = {4'b0, instr_i[3:2], instr_i[12], instr_i[6:4], 2'b0};
    wire [11:0] imm_LDSP     = {3'b0, instr_i[4:2], instr_i[12], instr_i[6:5], 3'b0};
    wire [11:0] imm_SWSP     = {4'b0, instr_i[8:7], instr_i[12:9], 2'b0};
    wire [11:0] imm_SDSP     = {3'b0, instr_i[9:7], instr_i[12:10], 3'b0};


    wire [2:0] funct2 ;
    assign funct2[0] = (rst2 == 5'b00000);
    assign funct2[1] = (rst1 == 5'b00000);
    assign funct2[2] = instr_i[12] ;

    always @(*) begin
        case (opcode)
            `COMPRESSED_00: begin
                case(funct3)
                    `C_ADDI4SPN: instr_unfold_o   = {imm_ADDI4SP, 5'd2, `ADDI, rst2_a, `ARITHMETIC_I};                      //? ADDI4SPN
                    `C_FLD     : instr_unfold_o   = 0;                    //? FLD
                    `C_LW      : instr_unfold_o   = {imm_LW, rst1_a, `LW, rst2_a, `ACCESS_I};                               //? LW
                    `C_LD      : instr_unfold_o   = {imm_LD, rst1_a, `LD, rst2_a, `ACCESS_I};                               //? LD
                    `C_FSD     : instr_unfold_o   = 0;                             //? FSD           
                    `C_SW      : instr_unfold_o   = {imm_LW[11:5], rst2_a, rst1_a, `SW, imm_LW[4:0], `ACCESS_S};            //? SW    
                    `C_SD      : instr_unfold_o   = {imm_LD[11:5], rst2_a, rst1_a, `SD, imm_LD[4:0], `ACCESS_S};            //? SD    
                    default    : instr_unfold_o   = 0;
                endcase
            end
            `COMPRESSED_01: begin
                case (funct3)
                    `C_ADDI_NOP    : instr_unfold_o   = (rst1==0)?   {       12'b0, rst1, `ADDI, rst1, `ARITHMETIC_I}:      //? NOP
                                                                     {       imm_A, rst1, `ADDI, rst1, `ARITHMETIC_I};      //? ADDI
                    `C_ADDIW       : instr_unfold_o   =              {       imm_A, rst1, `ADDI, rst1, `I_64_ONLY   };      //? ADDIW
                    `C_LI          : instr_unfold_o   =              {       imm_A, 5'b0, `ADDI, rst1, `ARITHMETIC_I};      //? LI
                    `C_ADDI16SP_LUI: instr_unfold_o   = (rst1==5'd2)?{imm_ADDI16SP, rst1, `ADDI, rst1, `ARITHMETIC_I}:      //? ADDI16SP
                                                                     {imm_LUI,rst1, `LUI};                                  //? LUI
                    `C01_100: begin
                        case(funct6)
                            `C_SRLI   : instr_unfold_o =     {6'b0000000,  imm_L, rst1_a, `SRLI_SRAI, rst1_a, `ARITHMETIC_I}; //? SRLI
                            `C_SRAI   : instr_unfold_o =     {6'b0100000,  imm_L, rst1_a, `SRLI_SRAI, rst1_a, `ARITHMETIC_I}; //? SRAI
                            `C_ANDI   : instr_unfold_o =     {             imm_A, rst1_a, `ANI,       rst1_a, `ARITHMETIC_I}; //? ANDI
                            `C01_100_11:begin
                                case(funct5)
                                    `C_SUB  : instr_unfold_o =     {7'b0100000, rst2_a, rst1_a, `ADD_SUB, rst1_a, `ARITHMETIC_R};   //? SUB
                                    `C_XOR  : instr_unfold_o =     {7'b0000000, rst2_a, rst1_a, `XOR,     rst1_a, `ARITHMETIC_R};   //? XOR
                                    `C_OR   : instr_unfold_o =     {7'b0000000, rst2_a, rst1_a, `OR,      rst1_a, `ARITHMETIC_R};   //? OR
                                    `C_AND  : instr_unfold_o =     {7'b0000000, rst2_a, rst1_a, `AND,     rst1_a, `ARITHMETIC_R};   //? AND
                                    `C_SUBW : instr_unfold_o =     {7'b0100000, rst2_a, rst1_a, `ADD_SUB, rst1_a, `R_64_ONLY};      //? SUBW
                                    `C_ADDW : instr_unfold_o =     {7'b0000000, rst2_a, rst1_a, `ADD_SUB, rst1_a, `R_64_ONLY};      //? ADDW
                                    default : instr_unfold_o   = 0;
                                endcase end
                        endcase end
                    `C_J     : instr_unfold_o   = {imm_J[10], imm_J[9:0], imm_J[10], {8{imm_J[10]}}, 5'b0,`JAL};                                      //? JAL
                    `C_BEQZ  : instr_unfold_o   = { {3{imm_B[7]}}, imm_B[7:4], 5'b0, rst1_a, `BEQ, imm_B[3:0], imm_B[7], `BRANCH_B};            //? BEQZ
                    `C_BNEZ  : instr_unfold_o   = {{3{imm_B[7]}}, imm_B[7:4], 5'b0, rst1_a, `BNE, imm_B[3:0], imm_B[7], `BRANCH_B};            //? BNEZ
                    default  : instr_unfold_o   = 0;
                endcase
            end
            `COMPRESSED_10: begin
                case(funct3)
                    `C_SLLI  : instr_unfold_o =     {6'b0100000,  imm_L, rst1, `SLLI, rst1, `ARITHMETIC_I};   //? SLLI64
                    `C_FLDSP : instr_unfold_o =     0; //? FLDSP
                    `C_LWSP  : instr_unfold_o =     {imm_LWSP, 5'd2, `LW, rst1, `ACCESS_I};                   //? LWSP
                    `C_LDSP  : instr_unfold_o =     {imm_LDSP, 5'd2, `LD, rst1, `ACCESS_I};                   //? LDSP
                    `C_10_100:begin
                        case(funct2)
                            `C_JR      : instr_unfold_o = {12'b0, rst1, 3'b010, 5'd0, `JALR};                      //? JR
                            `C_MV      : instr_unfold_o = {7'b0000000, 5'd0, rst2, `ADD_SUB, rst1, `ARITHMETIC_R}; //? MV
                            `C_EBREAK  : instr_unfold_o = 0 ;     //? EBREAK
                            `C_JALR    : instr_unfold_o = {12'b0, rst1, 3'b010, 5'd1, `JALR};                      //? JALR
                            `C_ADD     : instr_unfold_o = {7'b0000000, rst1, rst2, `ADD_SUB, rst1, `ARITHMETIC_R}; //? ADD
                            default    : instr_unfold_o   = 0;
                        endcase
                    end
                    `C_FSDSP : instr_unfold_o   = 0; //? FSDSP
                    `C_SWSP  : instr_unfold_o   = {imm_SWSP[11:5], rst2, 5'd2, `SW, imm_SWSP[4:0], `ACCESS_S};  //? SWSP          //? SWSP    
                    `C_SDSP  : instr_unfold_o   = {imm_SDSP[11:5], rst2, 5'd2, `SD, imm_SDSP[4:0], `ACCESS_S};  //? SWSP          //? SDSP    
                    default  : instr_unfold_o   = 0; 
                endcase
            end
            default  : instr_unfold_o   = 0; 
        endcase
    end
endmodule //C_instr_decode
