// Txclock = 50Mhz Tperiod = 20ns & data_width = 8bits & baud_rate is 1156000
// we calculate the error missmatch it is of +0.59% for Tx 
// we calculate the Rx error missmatch to both combined have to be less than 2%
// so we choose 16x oversampling at Rx and clock Rx is 75Mhz Tperiod = 13.3ns
// the error missmatch at Rx side is -0.78% so, |+0.59%| + |-0.78%| = 1.37% < 2%{sweet_stop} ...// 

module uart_top#(DATA_WIDTH = 8)(
   input wire t_clk,r_clk,
   input wire t_rst,r_rst,
   input wire tx_valid,
   input wire[DATA_WIDTH-1 :0]tx_data_in,
   output reg[DATA_WIDTH-1 :0]rx_data_out
);
 
 wire rx_in_w;

 transmitter f1(.t_clk(t_clk),
		.t_rst(t_rst),
		.tx_valid(tx_valid),
		.data(tx_data_in),
		.tx_out(rx_in_w));

 receiver f2(.r_clk(r_clk),
	     .r_rst(r_rst),
 	     .rx_in(rx_in_w),
	     .rx_data_out(rx_data_out));

endmodule 
