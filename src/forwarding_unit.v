module forwarding_unit(rs1_ex, rs2_ex, rd_mem, rd_wb, regw_mem, regw_wb, forward_a, forward_b);

    input regw_mem, regw_wb;
    input [4:0] rs1_ex, rs2_ex, rd_mem, rd_wb;
    
    output [1:0] forward_a, forward_b;

    assign forward_a = (rs1_ex == rd_mem && regw_mem && rd_mem != 5'b0) ? 2'b01 :   //for rs1
                        (rs1_ex == rd_wb && regw_wb && rd_wb != 5'b0) ? 2'b10 : 
                        2'b00;
    
    assign forward_b = (rs2_ex == rd_mem && regw_mem && rd_mem != 5'b0) ? 2'b01 :   //for rs2
                        (rs2_ex == rd_wb && regw_wb && rd_wb != 5'b0) ? 2'b10 : 
                        2'b00;




endmodule