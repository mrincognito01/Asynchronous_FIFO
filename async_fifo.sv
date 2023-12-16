module async_fifo #(
    parameter WIDTH=8,   // in bits 
    parameter DEPTH=16   // in bits
)
    (   input logic [WIDTH-1:0]in,
        input logic wr_clk,
        input logic rd_clk,
        input logic wr_reset_n,
        input logic rd_reset_n,
        input logic wr_en,
        input logic rd_en,
        output logic full,
        output logic empty,
        output logic [WIDTH-1:0]out
    );

    logic [WIDTH-1:0]mem[DEPTH-1:0];
    
    logic [$clog2(DEPTH):0]wr_ptr,wr_ptrg,wr_ptrb,wr_g,wr_sync,wr_temp;
    logic [$clog2(DEPTH):0]rd_ptr,rd_ptrg,rd_ptrb,rd_g,rd_sync,rd_temp;

    logic [$clog2(DEPTH)-1:0]wr_addr,rd_addr;

    logic full_v,empty_v;

   
    assign full_v = (wr_ptrg=={ ~wr_sync[($clog2(DEPTH)):($clog2(DEPTH)-1)], wr_sync[($clog2(DEPTH)-2):0]} || (wr_sync == DEPTH-'b1));

    assign empty_v = (rd_ptrg==rd_sync) || (rd_sync == DEPTH-'b1);

   


           assign wr_ptrb = (wr_ptr==DEPTH-1)?'b0:(wr_ptr + (wr_en && !full));          // Next Write Pointer
           assign wr_ptrg = (wr_ptrb >> 'b1) ^ (wr_ptrb);                               // Bin 2 Gray Converter
           assign wr_addr = wr_ptr[($clog2(DEPTH)-1):0];                                // Wr_Addr

           always_ff@(posedge wr_clk or negedge wr_reset_n)
           begin
               if(!wr_reset_n)
               begin
                   wr_ptr               <=       'b0;
                   for(int i=0;i<DEPTH;i++)
                   mem[i]               <=       '0;
                   wr_g                 <=       'b0;
                   wr_temp              <=       'b0;
                   full                 <=       'b0;
                   wr_sync              <=       'b0;
               end

               else 
               begin
                   {wr_ptr,wr_g}        <=     {wr_ptrb,wr_ptrg};
                   {wr_sync,wr_temp}    <=     {wr_temp,rd_g};    //2_Flip_Flop Synchronizer
                   full                 <=     full_v;
                   if(wr_en && !full)
                    mem[wr_addr]        <=     in;

               end
           end


        
           assign rd_ptrb = (rd_ptr == DEPTH-1)?'b0:(rd_ptr + (rd_en && !empty));         // Next Read Pointer
           assign rd_ptrg = (rd_ptrb >> 'b1) ^ (rd_ptrb);                                 // Bin 2 Gray Converter
           assign rd_addr= rd_ptr[($clog2(DEPTH)-1):0];                                  //  Rd_Addr

           always_ff@(posedge rd_clk or negedge rd_reset_n)
           begin
               if(!rd_reset_n)
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
                   {rd_sync,rd_temp}     <=     {rd_temp,wr_g};   //2_Flip_flop_synchronizer
                   empty                 <=     empty_v;
                  // if(rd_en && !empty)
                    out                  <=     mem[rd_addr];
               end
           end

endmodule
