module dmem(clk, we, addr, wdata, rdata);

    input clk, we;
    input [31:0] addr, wdata;

    output [31:0] rdata;

    reg [31:0] data_mem [0:1023];

    initial
        begin
            $readmemh("mem/data.mem", data_mem);
        end

    assign rdata = data_mem[addr[11:2]]; 

    always@(posedge clk)
        begin
            if(we) data_mem[addr[11:2]] <= wdata;  
        end

endmodule