module alucontroller(aluop, funct3, funct7, aluctrl);

    input [1:0] aluop;
    input [2:0] funct3;
    input funct7;

    output reg [2:0] aluctrl;

    always @ (*)
        begin
            case(aluop)
                2'b00: aluctrl = 3'b000;  //add
                2'b01: aluctrl = 3'b001;  //sub
                2'b10: 
                    case(funct3)
                        3'b000: aluctrl = funct7 ? 3'b001 : 3'b000;  //sub or add
                        3'b110: aluctrl = 3'b011;  //or
                        3'b111: aluctrl = 3'b010;  //and    
                        3'b100: aluctrl = 3'b100;  //xor
                        3'b010: aluctrl = 3'b101;  //slt
                        default: aluctrl = 3'bxxx;
                    endcase
                2'b11: aluctrl = 3'bxxx;    
                default: aluctrl = 3'bxxx;
            endcase
        end

endmodule