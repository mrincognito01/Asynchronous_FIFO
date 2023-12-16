module async_fifo #(parameter WIDTH=8,DEPTH=16)
    (   input logic [WIDTH:0]in,
        input logic wr_clk,
        input logic rd_clk,
        input logic wr_reset,
        input logic rd_reset,
        input logic wr_en,
        input logic rd_en,
        output logic full,
        output logic empty,
        output logic [WIDTH:0]out);

    logic [WIDTH-1:0]mem[DEPTH-1:0];
    
    logic [$clog2(DEPTH):0]wr_ptr,wr_ptrg,wr_ptrb,wr_g,wr_sync,wr_temp;
    logic [$clog2(DEPTH):0]rd_ptr,rd_ptrg,rd_ptrb,rd_g,rd_sync,rd_temp;

    logic [$clog2(DEPTH)-1:0]wr_addr,rd_addr;

    logic full_v,empty_v;

   
    assign full_v = (wr_ptrg=={ ~wr_sync[($clog2(DEPTH)):($clog2(DEPTH)-1)], wr_sync[($clog2(DEPTH)-2):0]});

    assign empty_v = (rd_ptrg==rd_sync);

   
    //////////////////////// WRITE BLOCK ////////////////////////

           assign wr_ptrb = wr_ptr + (wr_en && !full);
           assign wr_ptrg = (wr_ptrb >> 'b1) ^ (wr_ptrb);
           assign wr_addr = wr_ptr[($clog2(DEPTH)-1):0];

           always_ff@(posedge wr_clk or negedge wr_reset)
           begin
               if(!wr_reset)
               begin
                   wr_ptr               <=       'b0;
                   mem                  <=       '{default:'b0};
                   wr_g                 <=       'b0;
                   wr_temp              <=       'b0;
                   full                 <=       'b0;
                   wr_sync              <=       'b0;
               end

               else 
               begin
                   {wr_ptr,wr_g}        <=     {wr_ptrb,wr_ptrg};
                   {wr_sync,wr_temp}    <=     {wr_temp,rd_g};
                   full                 <=     full_v;
                   if(wr_en && !full)
                    mem[wr_addr]        <=     in;

               end
           end


   //////////////////////// READ BLOCK ////////////////////////

    
        
           assign rd_ptrb = rd_ptr + (rd_en && !empty);
           assign rd_ptrg = (rd_ptrb >> 'b1) ^ (rd_ptrb);
           assign rd_addr= rd_ptr[($clog2(DEPTH)-1):0];

           always_ff@(posedge rd_clk or negedge rd_reset)
           begin
               if(!rd_reset)
               begin
                   rd_ptr                <=      'b0;
                   out                   <=      'b0;
                   rd_g                  <=      'b0;
                   empty                 <=      'b0;
                   rd_temp               <=      'b0;
                   rd_sync               <=      'b0;
               end

               else
               begin
                   {rd_ptr,rd_g}         <=     {rd_ptrb,rd_ptrg};
                   {rd_sync,rd_temp}     <=     {rd_temp,wr_g};
                   rd_sync               <=     rd_temp;
                   empty                 <=     empty_v;
                   if(rd_en && !empty)
                    out                  <=     mem[rd_addr];
               end
           end
       end

   endgenerate

endmodule





