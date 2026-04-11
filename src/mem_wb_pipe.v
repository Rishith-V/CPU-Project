module mem_wb_pipe(aluresult_wb, pcplus4_wb, memresult_wb, immext_wb, rd_wb, regw_wb, resultsrc_wb, clk, reset, aluresult_mem, memresult_mem, pcplus4_mem, immext_mem, rd_mem, resultsrc_mem, regw_mem);

    input clk, reset, regw_mem;
    input [1:0] resultsrc_mem;
    input [4:0] rd_mem;
    input [31:0] aluresult_mem, pcplus4_mem, memresult_mem, immext_mem;

    output reg regw_wb;
    output reg [1:0] resultsrc_wb;
    output reg [4:0] rd_wb;
    output reg [31:0] aluresult_wb, pcplus4_wb, memresult_wb, immext_wb;

    always@(posedge clk or posedge reset)
        begin
            if(reset)
                begin
                    regw_wb <= 1'b0;
                    resultsrc_wb <= 2'b0;
                    rd_wb <= 5'b0;
                    aluresult_wb <= 32'b0;
                    pcplus4_wb <= 32'b0;
                    memresult_wb <= 32'b0;
                    immext_wb <= 32'b0;
                end
            else
                begin
                    regw_wb <= regw_mem;
                    resultsrc_wb <= resultsrc_mem;
                    rd_wb <= rd_mem;
                    aluresult_wb <= aluresult_mem;
                    pcplus4_wb <= pcplus4_mem;
                    memresult_wb <= memresult_mem;
                    immext_wb <= immext_mem;
                end
        end

endmodule