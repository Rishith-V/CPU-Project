module if_id_pipe(inst_id, pcplus4_id, pc_id, pc_if, inst_if, pcplus4_if, clk, reset);

    input clk, reset;
    input [31:0] inst_if, pcplus4_if, pc_if;

    output reg [31:0] inst_id, pcplus4_id, pc_id;

    always@(posedge clk or posedge reset)
        begin
            if(reset)
                begin
                    inst_id <= 32'b0;
                    pcplus4_id <= 32'b0;
                    pc_id <= 32'b0;
                end
            else
                begin
                    inst_id <= inst_if;
                    pcplus4_id <= pcplus4_if;
                    pc_id <= pc_if;
                end
        end

endmodule