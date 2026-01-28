# UART Receiver
- This project implements a UART receiver using 16× oversampling to reliably capture incoming serial data.
- The receiver is designed for a target baud rate of 1,156,000 symbols/second, resulting in an effective oversampled rate of:
-                                16 × 1,156,000 = 18,496,000 samples/second

## Design Parameters

* RX clock frequency: 75 MHz
* Clock period: 13.33 ns
* Data width: 8 bits
* Oversampling rate: 16×

### Sampling Logic
- With a 75 MHz RX clock, the sample tick frequency is derived as:
-                                              75 MHz / (16 × 1,156,000) ≈ 4


- This means a sample tick is generated every 4 clock cycles.
- A total of 16 sample ticks are produced per bit period, and the data is sampled at the 8th sample tick, which corresponds to the center of the bit for maximum noise immunity.
### Actual Generated Baud Rate
- Since the sample tick occurs every 4 clock cycles:
- Actual baud rate = 75 MHz / 4 = 18,750,000

### Baud Rate Error Analysis
The percentage error between the intended and generated baud rates is:

-                               (18,750,000 − 18,496,000) / 18,496,000 = −0.78%


- An error of −0.78% is well within acceptable UART tolerance (typically < 1%), ensuring reliable data reception.

- Note : both transmitter and receiver (.v) files are not lint free.
