module async_fifo_tb;
    parameter WIDTH = 8;
    parameter DEPTH = 16;
    logic [WIDTH-1:0]in;
    logic wr_clk;
    logic rd_clk;
    logic wr_reset;
    logic rd_reset;
    logic wr_en;
    logic rd_en;
    logic full;
    logic empty;
    logic [WIDTH-1:0]out;

    async_fifo uut(.in(in),.wr_clk(wr_clk),.rd_clk(rd_clk),.wr_reset(wr_reset),.rd_reset(rd_reset),.wr_en(wr_en),.rd_en(rd_en),.full(full),.empty(empty),.out(out));

    initial begin
        wr_clk='b0;
        forever #5 wr_clk=~wr_clk;
    end

    initial begin
        rd_clk='b0;
        forever #10 rd_clk=~rd_clk;
    end

    initial begin
        wr_reset='b1;
        rd_reset='b1;
        #15;
        wr_reset='b0;
        rd_reset='b0;
        
        

        wr_en='b1;
        rd_en='b0;

        repeat(16)
        begin
            in=$random;
            #10;
        end
        #160;

        wr_en='b0;
        rd_en='b1;
        #320;

        rd_en='b0;
        wr_en='b1;

        repeat(16)
        begin
            in=$random;
            #10;
        end
        #160;

        wr_en='b0;
        rd_en='b1;
        #320;

        rd_en='b0;
        #20;

     $finish;
    end
endmodule
    
