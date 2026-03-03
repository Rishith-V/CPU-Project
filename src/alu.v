module alu(a, b, ctrl, outp, zero);

    input [31:0] a, b;
    input [2:0] ctrl;

    output reg [31:0] outp;
    output zero;

    wire of;
    wire [31:0] b_eff, sum;

    assign b_eff = ctrl[0] ? ~b : b;

    assign sum = a + b_eff + ctrl[0];
    assign of = (ctrl[0] ^ a[31] ^ b[31]) ? 1'b0 : (sum[31] != a[31]);

    always@(*)
        begin
            case(ctrl)
                3'b000 : outp = sum;    //add
                3'b001 : outp = sum;    //sub
                3'b010 : outp = a & b;
                3'b011 : outp = a | b;
                3'b100 : outp = a ^ b;
                3'b101 : outp = {31'b0, sum[31] ^ of};  //lui doesn't enter alu at all
            endcase
        end

    assign zero = (outp == 32'b0);


endmodule