module pcreg(inp, outp, clk, reset);

    input [31:0] inp;
    output reg [31:0] outp;
    input clk, reset;

    always@(posedge clk)
        begin
            if(reset)
                outp <= 32'b0;
            else
                outp <= inp;
        end

endmodule