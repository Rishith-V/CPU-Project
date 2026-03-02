module regfile(clk, we, rd, wdata, rs1, rs2, rdata1, rdata2);

    input [4:0] rd, rs1, rs2;
    input [31:0] wdata;
    input clk, we;

    output [31:0] rdata1, rdata2;

    reg [31:0] rf [0:31];

    assign rdata1 = (rs1 != 5'b0) ? rf[rs1] : 32'b0;
    assign rdata2 = (rs2 != 5'b0) ? rf[rs2] : 32'b0;

    always @ (negedge clk)  //write on falling edge, read on rising edge
        begin
            if(we && rd != 5'b0) rf[rd] <= wdata;  // x0 hardwired to zero
        end

endmodule