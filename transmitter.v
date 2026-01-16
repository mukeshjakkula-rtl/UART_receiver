// Txclock = 50Mhz Tperiod = 20ns & data_width = 8bits & baud_rate is 1156000
// we calculate the error missmatch it is of +0.59% for Tx 
// we calculate the Rx error missmatch to both combined have to be less than 2%
// so we choose 16x oversampling at Rx and clock Rx is 75Mhz Tperiod = 13.3ns
// the error missmatch at Rx side is -0.78% so, |+0.59%| + |-0.78%| = 1.37% < 2% {sweet_spot}...// 

module transmitter#(parameter int  BAUD_RATE = 1156000,
			           CLOCK_FREQ = 50000000,
				   DATA_WIDTH = 8)( 

   input wire t_clk,
   input wire t_rst,
   input wire [DATA_WIDTH -1 : 0]data,
   input wire tx_valid, // assuming tx_valid is high for the entire transmission 
   output reg tx_out
);

   localparam int BAUD_DIV = (CLOCK_FREQ + (BAUD_RATE/2))/BAUD_RATE;  // 43 clock cycles bit time
   localparam DIV_WIDTH = $clog2(BAUD_DIV);
   localparam BIT_COUNT = $clog2(DATA_WIDTH) + 1; // we are initializing bit_count = 0 so, count starts from 1 ends at 8.

   reg baud_tick; 
   reg[DIV_WIDTH-1 : 0]baud_count;
   reg[DATA_WIDTH-1 : 0]tx_shift_reg;
   reg[BIT_COUNT -1 : 0]bit_count;

   typedef enum logic[3:0]{IDLE  = 4'b00001,
			   START = 4'b0010,
                           DATA  = 4'b0100,
			   STOP  = 4'b1000}tx_states;
   tx_states state;

/////////// baud_rate_generator /////////////////////
  always@(posedge t_clk, negedge t_rst) begin
     if(!t_rst) begin
	baud_count <= {DIV_WIDTH{1'b0}};
	baud_tick <= 1'b0;
     end else begin
        if(tx_valid) begin
	   if(baud_count == BAUD_DIV) begin
	       baud_tick <= 1'b1;
	       baud_count <= {DIV_WIDTH{1'b0}};
  	   end else begin
	       baud_count <= baud_count + 1'b1;
	       baud_tick <= 1'b0;
           end 
        end
     end 
  end 


  always@(posedge t_clk, negedge t_rst) begin
     if(!t_rst) begin
	tx_out <= 1'b1;
	bit_count <= {BIT_COUNT{1'b0}};
        tx_shift_reg <= {DATA_WIDTH{1'b0}};
        state <= IDLE;
     end else begin
	case(state) 
	   IDLE : begin
	      tx_out <= 1'b1;
	      tx_shift_reg <= {DATA_WIDTH{1'b0}};
	      if(tx_valid) state <= START;
              else state <= IDLE;
	   end // idle 

	   START : begin
	      tx_out <= 1'b0;
	      tx_shift_reg <= data;
	      if(baud_count == BAUD_DIV) state <= DATA; 
              else state <= START;
           end // start

	   DATA : begin
	      if(baud_tick) begin
		 if(bit_count == DATA_WIDTH) begin  
                    state <= STOP;
		    bit_count <= {BIT_COUNT{1'b0}};
                 end else begin
		    state <= DATA;
		    tx_out <= tx_shift_reg[0]; // each data bit time is 43 clock cycles 
                    tx_shift_reg <= tx_shift_reg >> 1;
		    bit_count <= bit_count + 1'b1;
		 end
	      end 	
 	   end // data

	   STOP : begin
	      tx_out <= 1'b1;
	      if(baud_count == BAUD_DIV) state <= IDLE;
              else state <= STOP;	
           end // stop
	  default : state <= IDLE;
	endcase
     end 
  end 
endmodule 
