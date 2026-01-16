**UART_receiver**

Designed uart receiver which can capture the data at a speed of (16 x 1156000) symbols per seconds (baud_rate = 18496000) i.e 16x is the oversample rate for receiver.
Rxclock = 75Mhz Tperiod = 13.33ns & data_width = 8bits we calculate the error missmatch it is of -0.78% for Rx.

so according to the 75Mhz clock 75Mhz/16x1156000 = ~4 so we have a sample_tick for 4 clock cycles 
and we have 16 sample_ticks we only capture at one sample tick we choose the 8th sample_tick to capture the data.

so the actual baudrate is 75Mhz/40 = 18750000.

so the error between the intended baudrate and the generated baudrate is:

                 (18750000 - 18496000)/18496000 = -0.78% (good < 1%)


