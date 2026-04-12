module forward_val_mux(rdata1_ex, rdata2_ex, result_wb, immext_mem, pcplus4_mem, aluresult_mem, forward_a, forward_b, resultsrc_mem, forward_val_a, forward_val_b, forward_mem);

    input [1:0] forward_a, forward_b, resultsrc_mem;
    input [31:0] rdata1_ex, rdata2_ex, result_wb, immext_mem, pcplus4_mem, aluresult_mem;

    output [31:0] forward_val_a, forward_val_b;
    output [31:0] forward_mem;

    assign forward_mem = (resultsrc_mem == 2'b0) ? aluresult_mem :
                        (resultsrc_mem == 2'b10) ? pcplus4_mem :
                        (resultsrc_mem == 2'b11) ? immext_mem :
                        32'b0;

    assign forward_val_a = (forward_a == 2'b01) ? forward_mem :
                        (forward_a == 2'b10) ? result_wb :
                        rdata1_ex;

    assign forward_val_b = (forward_b == 2'b01) ? forward_mem :
                        (forward_b == 2'b10) ? result_wb :
                        rdata2_ex;

endmodule