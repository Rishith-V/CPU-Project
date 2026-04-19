module pcreg(inp, outp, clk, reset, stall);

    input [31:0] inp;
    output reg [31:0] outp;
    input clk, reset, stall;

    always@(posedge clk)
        begin
            if(reset)
                outp <= 32'b0;
            else if(!stall)
                outp <= inp;
        end

endmodule