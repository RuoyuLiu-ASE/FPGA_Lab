// ------------------------------------------------------------------------- --
// Title         : Clockwork
// Project       : Praktikum FPGA-Entwurfstechnik
// ------------------------------------------------------------------------- --
// File          : timeAndDateClock.v
// Author        : Shutao Zhang
// Company       : IDS RWTH Aachen 
// Created       : 2018/08/16
// ------------------------------------------------------------------------- --
// Description   : Clockwork for a DCF77 radio-controlled clock
// ------------------------------------------------------------------------- --
// Revisions     :
// Date        Version  Author  Description
// 2018/08/16  1.0      SH      Created
// 2018/09/20  1.1      TS      Clean up, comments
// ------------------------------------------------------------------------- --

module timeAndDateClock(input clk,                // global 10Mhz clock
                        input clkEn1Hz,           // 1Hz clock
                        input nReset,             // asynchronous reset (active low)  
                        input setTimeAndDate_in,  
                        input[43:0] timeAndDate_In,     
                        output reg[43:0] timeAndDate_Out);   

// ---------- YOUR CODE HERE ---------- 
  always @(posedge clk or negedge nReset) begin
     if (!nReset) begin
        timeAndDate_Out <= 43'b0;
      end 
  end



  always @(posedge clkEn1Hz or posedge setTimeAndDate_in) begin
    if (setTimeAndDate_in == 1) begin
      timeAndDate_Out <= timeAndDate_In;
    end else begin // implementation of the seconds
      if (timeAndDate_Out[3:0] == 4'h9) begin
        timeAndDate_Out[3:0] <= 4'h0;   // when the lower digit of second reach 10, let the number be 0 again.
        timeAndDate_Out[6:4] <= timeAndDate_Out[6:4] + 1; // And the higher digit of second + 1
      end else begin
        timeAndDate_Out[3:0] <= timeAndDate_Out[3:0]+1;   // lower digit of second 
      end
    end
  end

endmodule

