module imem(addr, instr);

    input [31:0] addr;

    output [31:0] instr;

    reg [31:0] inst_mem [0:1023];   //our memory will be of 1024 words
    initial
        begin
            $readmemh("mem/program.mem", inst_mem);
        end

    assign instr = inst_mem[addr[11:2]];  

endmodule