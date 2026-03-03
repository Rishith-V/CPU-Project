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
                        RegWrite  = 1; ImmSrc = 3'bxxx;
                        ALUSrc    = 0; ALUOp  = 2'b10;
                        MemWrite  = 0; ResultSrc = 2'b00;
                        Branch    = 0; Jump = 0; JumpReg = 0;
                    end

            // I-ALU: addi (and future andi, ori etc)
                7'b0010011: 
                    begin
                        RegWrite  = 1; ImmSrc = 3'b000;
                        ALUSrc    = 1; ALUOp  = 2'b10;
                        MemWrite  = 0; ResultSrc = 2'b00;
                        Branch    = 0; Jump = 0; JumpReg = 0;
                    end
            // LW
                7'b0000011: 
                    begin
                        RegWrite  = 1; ImmSrc = 3'b000;
                        ALUSrc    = 1; ALUOp  = 2'b00;
                        MemWrite  = 0; ResultSrc = 2'b01;
                        Branch    = 0; Jump = 0; JumpReg = 0;
                    end
            // SW
                7'b0100011: 
                    begin
                        RegWrite  = 0; ImmSrc = 3'b001;
                        ALUSrc    = 1; ALUOp  = 2'b00;
                        MemWrite  = 1; ResultSrc = 2'bxx;
                        Branch    = 0; Jump = 0; JumpReg = 0;
                    end
            // BEQ
                7'b1100011: 
                    begin
                        RegWrite  = 0; ImmSrc = 3'b010;
                        ALUSrc    = 0; ALUOp  = 2'b01;
                        MemWrite  = 0; ResultSrc = 2'bxx;
                        Branch    = 1; Jump = 0; JumpReg = 0;
                    end
            // LUI
                7'b0110111: 
                    begin
                        RegWrite  = 1; ImmSrc = 3'b011;
                        ALUSrc    = 1'bx; ALUOp = 2'bxx;
                        MemWrite  = 0; ResultSrc = 2'b11;
                        Branch    = 0; Jump = 0; JumpReg = 0;
                    end
            // JAL
                7'b1101111: 
                    begin
                        RegWrite  = 1; ImmSrc = 3'b100;
                        ALUSrc    = 1'bx; ALUOp = 2'bxx;
                        MemWrite  = 0; ResultSrc = 2'b10;
                        Branch    = 0; Jump = 1; JumpReg = 0;
                    end
            // JALR
                7'b1100111: 
                    begin
                        RegWrite  = 1; ImmSrc = 3'b000;
                        ALUSrc    = 1; ALUOp  = 2'b00;
                        MemWrite  = 0; ResultSrc = 2'b10;
                        Branch    = 0; Jump = 0; JumpReg = 1;
                    end
                default: 
                    begin
                        RegWrite  = 0; ImmSrc = 3'bxxx;
                        ALUSrc    = 1'bx; ALUOp = 2'bxx;
                        MemWrite  = 0; ResultSrc = 2'bxx;
                        Branch    = 0; Jump = 0; JumpReg = 0;
                    end

            endcase
        end

endmodule