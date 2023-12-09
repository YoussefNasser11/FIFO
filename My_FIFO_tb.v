`define CLK @(posedge clk) 

module My_FIFO_tb();

  // Parameters
 localparam  Data_Width = 16;
 localparam  Depth = 2 ;
 localparam  T=5;

  //Ports
  reg  clk;
  reg  reset;
  reg  w;
  reg  r;
  reg  [Data_Width-1:0] data_in;
  wire [Data_Width-1:0] data_out;
  wire full_o;
  wire empty_o;

  My_FIFO 
  #(
    .Data_Width(Data_Width),
    .Depth(Depth)
)
My_FIFO_inst  (
    .clk(clk),
    .reset(reset),
    .w(w),
    .r(r),
    .data_in(data_in),
    .data_out(data_out),
    .full_o(full_o),
    .empty_o(empty_o)
);

// Generate Clock
always
begin
  clk = 1'b1;
      #T;
  clk = 1'b0;
      #T;
end

// Drive inputs

initial 
begin
  reset  = 1'b1;
  w      = 1'b0;
  r      = 1'b0;
  repeat(2) @(posedge clk);
  reset       = 1'b0;
  `CLK;
  w       = 1'b1;
  data_in = 16'hABAB;
  `CLK;
  data_in = 16'h32EF;
  `CLK;
  w      = 1'b0;
  `CLK;
  w      = 1'b0;
  data_in = 16'hDDDD;
  r       = 1'b1;
  `CLK;
  r       = 1'b0;
  repeat(2) `CLK;
  $finish();
end

endmodule
