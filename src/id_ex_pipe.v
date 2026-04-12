module id_ex_pipe(immext_ex, rdata1_ex, rdata2_ex, rd_ex, pc_ex, pcplus4_ex, regw_ex, alusrc_ex, memw_ex, branch_ex, jump_ex, jumpreg_ex, aluctrl_ex, resultsrc_ex, rs1_ex, rs2_ex, clk, reset,immext_id, rdata1_id, rdata2_id, rd_id, pc_id, pcplus4_id, regw_id, alusrc_id, memw_id, branch_id, jump_id, jumpreg_id, aluctrl_id, resultsrc_id, rs1_id, rs2_id);

    input clk, reset, regw_id, memw_id, branch_id, jump_id, jumpreg_id, alusrc_id;
    input [1:0] resultsrc_id;
    input [31:0] rdata1_id, rdata2_id, pc_id, pcplus4_id, immext_id;
    input [4:0] rd_id, rs1_id, rs2_id;
    input [2:0] aluctrl_id;


    output reg regw_ex, memw_ex, branch_ex, jump_ex, jumpreg_ex, alusrc_ex;
    output reg [1:0] resultsrc_ex;
    output reg [2:0] aluctrl_ex;
    output reg [31:0] rdata1_ex, rdata2_ex, pc_ex, pcplus4_ex, immext_ex;
    output reg [4:0] rd_ex, rs1_ex, rs2_ex;

    always@(posedge clk or posedge reset)
        begin
            if(reset)
                begin
                    regw_ex <= 1'b0;
                    alusrc_ex <= 1'b0;
                    memw_ex <= 1'b0;
                    branch_ex <= 1'b0;
                    jump_ex <= 1'b0;
                    jumpreg_ex <= 1'b0;
                    resultsrc_ex <= 2'b0;
                    rdata1_ex <= 32'b0;
                    rdata2_ex <= 32'b0;
                    pc_ex <= 32'b0;
                    pcplus4_ex <= 32'b0;
                    immext_ex <= 32'b0;
                    rd_ex <= 5'b0;
                    aluctrl_ex <= 3'b0;
                    rs1_ex <= rs1_id;
                    rs2_ex <= rs2_id;
                end
            else
                begin
                    regw_ex <= regw_id;
                    alusrc_ex <= alusrc_id;
                    memw_ex <= memw_id;
                    branch_ex <= branch_id;
                    jump_ex <= jump_id;
                    jumpreg_ex <= jumpreg_id;
                    resultsrc_ex <= resultsrc_id;
                    rdata1_ex <= rdata1_id;
                    rdata2_ex <= rdata2_id; 
                    pc_ex <= pc_id;
                    pcplus4_ex <= pcplus4_id;
                    immext_ex <= immext_id;
                    rd_ex <= rd_id;
                    aluctrl_ex <= aluctrl_id;
                    rs1_ex <= rs1_id;
                    rs2_ex <= rs2_id;
                end
        end

endmodule