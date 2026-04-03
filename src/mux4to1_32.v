module mux4to1_32(in0, in1, in2, in3, sel, outp);   //result mux

    input [31:0] in0, in1, in2, in3;
    input [1:0] sel;

    output [31:0] outp;

    assign outp = (sel == 2'b00) ? in0 : ((sel == 2'b01) ? in1 : ((sel == 2'b10) ? in2 : in3));

endmodule