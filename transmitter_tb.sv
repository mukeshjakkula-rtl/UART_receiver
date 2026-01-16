module transmitter_tb();

  reg t_clk;
  reg t_rst;
  reg [7:0]data;
  reg tx_valid;
  wire tx_out;


transmitter dut(.t_clk(t_clk),
		.t_rst(t_rst),
		.data(data),
		.tx_valid(tx_valid),
		.tx_out(tx_out));



  initial begin
     t_clk = 1'b0;
     t_rst = 1'b0;
#10  t_rst = 1'b1;
  end 
always #10 t_clk = ~t_clk;


initial begin
   tx_valid = 1'b1;
   data = 8'hdd;
end 

initial begin
   $dumpfile("wave.vcd");
   $dumpvars(0,transmitter_tb);
end 

initial #10500 $finish;

endmodule 
