// ------------------------------------------------------------------------- --
// Title         : DCF77-Decoder
// Project       : Praktikum FPGA-Entwurfstechnik
// ------------------------------------------------------------------------- --
// File          : timeAndDateClock.v
// Author        : Tim Stadtmann
// Company       : IDS RWTH Aachen 
// Created       : 2018/09/20
// ------------------------------------------------------------------------- --
// Description   : Decodes the dcf77 signal
// ------------------------------------------------------------------------- --
// Revisions     :
// Date        Version  Author  Description
// 2018/09/20  1.0      TS      Created
// ------------------------------------------------------------------------- --

module dcf77_decoder(clk,             // Global 10MHz clock 
                     clk_en_1hz,      // Indicates start of second
                     nReset,          // Global reset
                     minute_start_in, // New minute trigger
                     dcf_Signal_in,   // DFC Signal
                     timeAndDate_out,
                     data_valid,      // Control signal, High if data is valid
                     dcf_value);      // Decoded value of dcf input signal
                     
input clk, 
      clk_en_1hz,     
      nReset,  
      minute_start_in,
      dcf_Signal_in;  
      
output reg[43:0]  timeAndDate_out;
output reg        data_valid;
output            dcf_value;
   
// ---------- YOUR CODE HERE ---------- 
reg [59:0] data_dcf;
reg [5:0] index_clken;      // This is the index for clk_en_1hz
reg [5:0] counter_decoder;    // This is for counting the clk_en_1hz. In a minute, there are 59 valid seconds with falling edge

always @(negedge nReset or posedge clk_en_1hz or posedge minute_start_in) begin
      if (!nReset || minute_start_in) begin
            counter_decoder <= 6'b0;
            index_clken <= 6'b0;
      end else if (minute_start_in && clk_en_1hz) begin
            index_clken <= index_clken + 1;
            if (index_clken == 2) begin
                  counter_decoder <= counter_decoder + 1; // zeroed one second after the minute start signal
            end
      end
end




endmodule              
              

