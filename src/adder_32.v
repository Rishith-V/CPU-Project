module adder_32(in0, in1, outp);

    input [31:0] in0, in1;

    output [31:0] outp;

    assign outp = in0 + in1;

endmodule