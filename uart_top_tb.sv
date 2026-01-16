module uart_top_tb#(DATA_WIDTH = 8);
  reg t_clk,r_clk;
  reg t_rst,r_rst;
  reg tx_valid;
  reg[DATA_WIDTH-1 : 0]tx_data_in;
  wire[DATA_WIDTH-1 : 0]rx_data_out;

   uart_top dut(.t_clk(t_clk),
		.r_clk(r_clk),
		.t_rst(t_rst),
		.r_rst(r_rst),
		.tx_valid(tx_valid),
		.tx_data_in(tx_data_in),
		.rx_data_out(rx_data_out));


  initial begin
     t_clk = 1'b0;
     t_rst = 1'b0;
#10  t_rst = 1'b1;
  end 

  initial begin
    r_clk = 1'b0;
    r_rst = 1'b0;
#16 r_rst = 1'b1;
  end 

  always #10 t_clk = ~t_clk;
  always #13.33 r_clk = ~r_clk;

  initial begin
     tx_valid = 1'b1;
     tx_data_in = 8'hdd;
  end 

  initial begin
     $dumpfile("wave_top.vcd");
     $dumpvars(0,uart_top_tb);
  end 


initial #10500 $finish;

endmodule 
