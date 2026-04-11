module ex_mem_pipe(aluresult_mem, pcplus4_mem, rdata2_mem, rd_mem, regw_mem, memw_mem, resultsrc_mem, immext_mem, clk, reset, aluresult_ex, pcplus4_ex, rdata2_ex, rd_ex, regw_ex, memw_ex, resultsrc_ex, immext_ex);

    input clk, reset, regw_ex, memw_ex;
    input [1:0] resultsrc_ex;
    input [4:0] rd_ex;
    input [31:0] aluresult_ex, pcplus4_ex, rdata2_ex, immext_ex;

    output reg regw_mem, memw_mem;
    output reg [1:0] resultsrc_mem;
    output reg [4:0] rd_mem;
    output reg [31:0] aluresult_mem, pcplus4_mem, rdata2_mem, immext_mem;

    always@(posedge clk or posedge reset)
        begin
            if(reset)
                begin
                    regw_mem <= 1'b0;
                    memw_mem <= 1'b0;
                    resultsrc_mem <= 2'b0;
                    rd_mem <= 5'b0;
                    aluresult_mem <= 32'b0;
                    pcplus4_mem <= 32'b0;
                    rdata2_mem <= 32'b0;
                    immext_mem <= 32'b0;
                end
            else
                begin
                    regw_mem <= regw_ex;
                    memw_mem <= memw_ex;
                    resultsrc_mem <= resultsrc_ex;
                    rd_mem <= rd_ex;
                    aluresult_mem <= aluresult_ex;
                    pcplus4_mem <= pcplus4_ex;
                    rdata2_mem <= rdata2_ex;
                    immext_mem <= immext_ex;
                end
        end



endmodule