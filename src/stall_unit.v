module stall_unit(flush_if_id, flush_id_ex, stall, resultsrc_ex, opcode_id, rs1_id, rs2_id, rd_ex, jump_ex, jumpreg_ex, branch_ex, zero_ex);

    input jump_ex, jumpreg_ex, branch_ex, zero_ex;
    input [1:0] resultsrc_ex;
    input [4:0] rs1_id, rs2_id, rd_ex;
    input [6:0] opcode_id;

    output reg flush_if_id, flush_id_ex, stall;

    always@(*)
        begin
            if(resultsrc_ex == 2'b01 && (rs1_id == rd_ex) && (rd_ex != 5'b0) && (opcode_id == 7'b0110011 || opcode_id == 7'b0010011 || opcode_id == 7'b0000011 || opcode_id == 7'b0100011 || opcode_id == 7'b1100011 || opcode_id == 7'b1100111))
                begin                       //for rs1
                    stall = 1'b1;
                    flush_id_ex = 1'b1;
                    flush_if_id = 1'b0;
                end
            else if(resultsrc_ex == 2'b01 && (rs2_id == rd_ex) && (rd_ex != 5'b0) && (opcode_id == 7'b0110011 || opcode_id == 7'b0100011 || opcode_id == 7'b1100011))
                begin                       //for rs2
                    stall = 1'b1;
                    flush_id_ex = 1'b1;
                    flush_if_id = 1'b0;
                end
            else if(jump_ex || jumpreg_ex || (branch_ex && zero_ex))
                begin       //for control hazards
                    stall = 1'b0;
                    flush_id_ex = 1'b1;
                    flush_if_id = 1'b1;
                end
            else
                begin
                    stall = 1'b0;
                    flush_id_ex = 1'b0;
                    flush_if_id = 1'b0;
                end
        end

endmodule