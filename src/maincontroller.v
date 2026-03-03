module maincontroller (op, regw, immsrc, alusrc, memw, branch, aluop, resultsrc, jump, jumpreg);

    input [6:0] op;

    output reg regw, alusrc, memw, branch, jump, jumpreg;
    output reg [2:0] immsrc;
    output reg [1:0] aluop, resultsrc;

    always @ (*)
        begin
            case(op)
            // R-type: add, sub, and, or, xor, slt
                7'b0110011: 
                    begin
                        regw      = 1; immsrc = 3'bxxx;
                        alusrc    = 0; aluop  = 2'b10;
                        memw      = 0; resultsrc = 2'b00;
                        branch    = 0; jump = 0; jumpreg = 0;
                    end

            // I-ALU: addi
                7'b0010011: 
                    begin
                        regw      = 1; immsrc = 3'b000;
                        alusrc    = 1; aluop  = 2'b10;
                        memw      = 0; resultsrc = 2'b00;
                        branch    = 0; jump = 0; jumpreg = 0;
                    end
            // LW
                7'b0000011: 
                    begin
                        regw      = 1; immsrc = 3'b000;
                        alusrc    = 1; aluop  = 2'b00;
                        memw      = 0; resultsrc = 2'b01;
                        branch    = 0; jump = 0; jumpreg = 0;
                    end
            // SW
                7'b0100011: 
                    begin
                        regw      = 0; immsrc = 3'b001;
                        alusrc    = 1; aluop  = 2'b00;
                        memw      = 1; resultsrc = 2'bxx;
                        branch    = 0; jump = 0; jumpreg = 0;
                    end
            // BEQ
                7'b1100011: 
                    begin
                        regw      = 0; immsrc = 3'b010;
                        alusrc    = 0; aluop  = 2'b01;
                        memw      = 0; resultsrc = 2'bxx;
                        branch    = 1; jump = 0; jumpreg = 0;
                    end
            // LUI
                7'b0110111: 
                    begin
                        regw      = 1; immsrc = 3'b100;  // U-type
                        alusrc    = 1'bx; aluop = 2'bxx;
                        memw      = 0; resultsrc = 2'b11;
                        branch    = 0; jump = 0; jumpreg = 0;
                    end
            // JAL
                7'b1101111: 
                    begin
                        regw      = 1; immsrc = 3'b011;  // J-type
                        alusrc    = 1'bx; aluop = 2'bxx;
                        memw      = 0; resultsrc = 2'b10;
                        branch    = 0; jump = 1; jumpreg = 0;
                    end
            // JALR
                7'b1100111: 
                    begin
                        regw      = 1; immsrc = 3'b000;
                        alusrc    = 1; aluop  = 2'b00;
                        memw      = 0; resultsrc = 2'b10;
                        branch    = 0; jump = 0; jumpreg = 1;
                    end
                default: 
                    begin
                        regw      = 0; immsrc = 3'bxxx;
                        alusrc    = 1'bx; aluop = 2'bxx;
                        memw      = 0; resultsrc = 2'bxx;
                        branch    = 0; jump = 0; jumpreg = 0;
                    end

            endcase
        end

endmodule