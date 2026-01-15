// Txclock = 50Mhz Tperiod = 20ns & data_width = 8bits & baud_rate is 1156000
// we calculate the error missmatch it is of +0.59% for Tx 
// we calculate the Rx error missmatch to both combined have to be less than 2%
// so we choose 16x oversampling at Rx and clock Rx is 75Mhz Tperiod = 13.3ns
// the error missmatch at Rx side is -0.78% so, |+0.59%| + |-0.78%| = 1.37% < 2%{sweet_stop} ...// 

module receiver#(parameter int BAUD_RATE = 1156000,
			       OVER_SAMPLE_RATE = 16,
		               CLOCK_FREQ = 75000000,
		               DATA_WIDTH = 8)(
  input wire r_clk,
  input wire r_rst,
  input wire rx_in,
  output reg[DATA_WIDTH-1:0]rx_data_out
);
  localparam SAMPLE_RATE = OVER_SAMPLE_RATE * BAUD_RATE;
  localparam int BAUD_DIV = (CLOCK_FREQ + (SAMPLE_RATE/2))/SAMPLE_RATE; // baud_div is 4
  localparam DIV_WIDTH = $clog2(BAUD_DIV); //div_width is 2
  localparam BIT_COUNT = $clog2(DATA_WIDTH) + 1; // bit_count_width is 4;
  localparam SAMPLE_BIT1 = ((OVER_SAMPLE_RATE/2)-3); // we are sampling the bit at sample_count = 8;
  localparam SAMPLE_BIT2 = ((OVER_SAMPLE_RATE/2)+4);
 
  reg [DIV_WIDTH-1 : 0]baud_count; // the oversampled baud count
  reg [BIT_COUNT-1 : 0]bit_count; // to count the no of bits sampled, it should be 8
  reg [OVER_SAMPLE_RATE-1 : 0]sample_count; // to count how many baud_ticks, have to be 16 in our case
  reg baud_tick;
  reg sample_tick;
  reg [DATA_WIDTH-1:0]rx_shift_reg;

  reg sample_tick_d;
  wire sample_tick_edge;

  typedef enum logic[2:0]{IDLE,
			  START,
			  DATA,
		          STOP}rx_states;

  rx_states state;


///////////////// baud_rate_generator ////////////////////////////
  always@(posedge r_clk, negedge r_rst) begin
     if(!r_rst) begin
	baud_tick <= 1'b0;
        sample_count <= {OVER_SAMPLE_RATE{1'b0}};
	baud_count <= {DIV_WIDTH{1'b0}};
	sample_tick = 1'b0; 
     end else begin
        if(baud_count == BAUD_DIV-1) begin
	   baud_tick <= 1'b1;
	   baud_count <= {BIT_COUNT{1'b0}};
	end else begin
	   baud_count <= baud_count + 1'b1;
	   baud_tick <= 1'b0;
        end 
     end 
     
     if(baud_tick) begin
        if(sample_count == OVER_SAMPLE_RATE) begin
	   sample_count <= {OVER_SAMPLE_RATE{1'b0}}; 
	end else begin
           sample_count <= sample_count + 1'b1;
           if(sample_count == SAMPLE_BIT1 || sample_count == SAMPLE_BIT2) sample_tick <= 1'b1;
	   else sample_tick = 1'b0;
        end 
     end
  end 



always@(posedge r_clk, negedge r_rst) begin
   if(!r_rst) begin
      state <= IDLE;
      bit_count <= {BIT_COUNT{1'b0}};
      rx_shift_reg <= {DATA_WIDTH{1'b0}};
      rx_data_out <= {DATA_WIDTH{1'b0}}; 
   end else begin
      case(state) 
	  IDLE : begin
	     bit_count <= {BIT_COUNT{1'b0}};
	     if(rx_in == 1'b0) state <= START;
	     else state <= IDLE;
	  end //idle

	  START : begin
             if(sample_count == (SAMPLE_BIT1-2) && rx_in == 1'b1) begin
	        state <= IDLE; 
             end else begin
		if(sample_tick_edge) state <= DATA;
		else state <= START;
	     end 
          end //start;
	
	  DATA : begin
	     if(sample_tick_edge) begin
	        if(bit_count == DATA_WIDTH) begin
 		   rx_data_out <= rx_shift_reg;
		   state <= STOP;
		   bit_count <= {BIT_COUNT{1'b0}};
		end else begin
		   rx_shift_reg <= {rx_in,rx_shift_reg[DATA_WIDTH-1 : 1]};
		   bit_count <= bit_count + 1'b1;
		end 
	     end
	  end //data

	 STOP : begin
	    if(rx_in == 1'b1 && sample_count == OVER_SAMPLE_RATE) state <= IDLE;
	    else state <= STOP;
	 end  
      endcase
   end 
end 

//////  edge_dectector  //////////////////
// to avoid the dublicate increment of bit_count //
 always@(posedge r_clk, negedge r_rst) begin
    if(!r_rst) sample_tick_d <= 1'b0;
    else sample_tick_d <= sample_tick;
 end 
 
assign sample_tick_edge = sample_tick_d & ~sample_tick;

endmodule 
