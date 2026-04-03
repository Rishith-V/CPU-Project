module mux2to1_32(in0, in1, sel, outp);     //alu srcb mux

    input [31:0] in0, in1;
    input sel;

    output [31:0] outp;

    assign outp = sel ? in1 : in0;

endmodule