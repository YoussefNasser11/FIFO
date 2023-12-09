// FIFO 
// Author: Eng. Youssef Nasser
// Lab: Lab 2 - Verilog
// Issued to: Egypt Make Electronics


module My_FIFO #(
    parameter Data_Width = 16 , Depth = 4
) (
    clk,reset,w,data_in,r,data_out,full_o,empty_o
);

input  clk,reset;
input  w,r; //write and read
input  [Data_Width-1:0] data_in;
output [Data_Width-1:0] data_out;
output full_o,empty_o;


localparam ST_PUSH = 2'b10;
localparam ST_POP = 2'b01;
localparam ST_BOTH = 2'b11;

localparam PTR_W = $clog2(Depth) ;

reg [Data_Width-1:0] fifo_data_q [Depth-1:0];

reg [PTR_W-1:0] rd_ptr_q;
reg [PTR_W-1:0] wr_ptr_q;
reg [PTR_W-1:0] nxt_rd_ptr;
reg [PTR_W-1:0] nxt_wr_ptr;

reg [Data_Width-1:0] nxt_fifo_data;
reg [Data_Width-1:0] pop_data;

//extra
reg wrapped_rd_ptr_q;
reg wrapped_wr_ptr_q;
reg nxt_wrapped_rd_ptr;
reg nxt_wrapped_wr_ptr;
wire empty;
wire full;

//FSM FOR THE FIFO

//Flops for FIFO Pointers

always @(posedge clk or posedge reset )
 begin
    if (reset) 
    begin
        rd_ptr_q <= 1'b0;
        wr_ptr_q <= 1'b0;
        //extra
        wrapped_rd_ptr_q <= 1'b0;
        wrapped_wr_ptr_q <= 1'b0;
    end   
    else
        begin
            rd_ptr_q <= nxt_rd_ptr;
            wr_ptr_q <= nxt_wr_ptr;
            //extra
            wrapped_rd_ptr_q <= nxt_wrapped_rd_ptr;
            wrapped_wr_ptr_q <= nxt_wrapped_wr_ptr;
        end
 end

 // Pointer logic for push and pop

 always @(*)
  begin
    nxt_fifo_data = fifo_data_q[wr_ptr_q[PTR_W-1:0]];
    nxt_rd_ptr = rd_ptr_q;
    nxt_wr_ptr = wr_ptr_q;
    nxt_wrapped_rd_ptr = wrapped_rd_ptr_q;
    nxt_wrapped_wr_ptr = wrapped_wr_ptr_q;
    case ({w,r}) // 2-bit signal with push as MSB and POP as LSB
        ST_PUSH:
        begin
            nxt_fifo_data = data_in;
            //manipulate the write pointer , Depth = 6 , wr_ptr_q = 5 , wr_ptr_q = 6 !! incorrect
            // this case handle Depth that's not power of 2
            if (wr_ptr_q == (Depth-1)) 
            begin
                nxt_wr_ptr = 1'b0;    
                nxt_wrapped_wr_ptr = ~wrapped_wr_ptr_q; //extra
            end
            else
                begin
                    nxt_wr_ptr = wr_ptr_q + 1'b1;
                end
        end
        ST_POP: 
        begin
            //READ the FIFO location Pointed by rd_pointer
            pop_data = fifo_data_q[rd_ptr_q[PTR_W-1:0]];
            // Manipulate as the pervious 
            if (rd_ptr_q == (Depth-1)) 
            begin
                nxt_rd_ptr = 1'b0;    
                nxt_wrapped_rd_ptr <= ~wrapped_rd_ptr_q; //extra
            end
            else
                begin
                    nxt_rd_ptr = rd_ptr_q + 1'b1;
                end
        end
        ST_BOTH:
        begin
            nxt_fifo_data = data_in;
            //manipulate the write pointer , Depth = 6 , wr_ptr_q = 5 , wr_ptr_q = 6 !! incorrect
            // this case handle Depth that's not power of 2
            if (wr_ptr_q == (Depth-1)) 
            begin
                nxt_wr_ptr = 1'b0;    
                nxt_wrapped_wr_ptr = ~wrapped_wr_ptr_q; //extra
            end
            else
                begin
                    nxt_wr_ptr = wr_ptr_q + 1'b1;
                end
                //READ the FIFO location Pointed by rd_pointer
            pop_data = fifo_data_q[rd_ptr_q[PTR_W-1:0]];
            // Manipulate as the pervious 
            if (rd_ptr_q == (Depth-1)) 
            begin
                nxt_rd_ptr = 1'b0;    
                nxt_wrapped_rd_ptr <= ~wrapped_rd_ptr_q; //extra
            end
            else
                begin
                    nxt_rd_ptr = rd_ptr_q +1'b1;
                end
        end 
        default: 
        begin
        nxt_fifo_data = fifo_data_q[wr_ptr_q[PTR_W-1:0]];
        nxt_rd_ptr = rd_ptr_q;
        nxt_wr_ptr = wr_ptr_q;
        end
    endcase   
 end

assign empty = (rd_ptr_q == wr_ptr_q) & (wrapped_rd_ptr_q == wrapped_wr_ptr_q);
assign full  = (rd_ptr_q == wr_ptr_q) & (wrapped_rd_ptr_q != wrapped_wr_ptr_q);

 always @(posedge clk)
  begin
    fifo_data_q[wr_ptr_q[PTR_W-1:0]] <= nxt_fifo_data;  
  end

  assign data_out = pop_data;
  //extra
  assign full_o  = full ;   
  assign empty_o = empty;
    
endmodule