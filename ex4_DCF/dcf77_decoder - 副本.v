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
reg dcf_value;
reg [58:0] data_dcf;
reg [5:0] counter_decoder;    // This is for counting the clk_en_1hz. In a minute, there are 59 valid seconds with falling edge

reg p1,p2,p3,result;           //For parity check
reg flag;   //This is the flag for receiving 59 values in order to generate a data_valid signal

always @(negedge nReset or posedge clk_en_1hz or posedge minute_start_in) begin
      if (!nReset || minute_start_in) begin
            counter_decoder <= 6'b0;
      end else if (clk_en_1hz) begin
            counter_decoder <= counter_decoder + 1; // zeroed one second after the minute start signal
            dcf_value <= ~dcf_Signal_in;
      end 
end


always @(counter_decoder) begin
      data_dcf[counter_decoder] = dcf_value;          // Put the last value in data_dcf
      if (counter_decoder == 6'b0) begin
            data_dcf = 59'b0;
            p1 = 1'b0;
            p2 = 1'b0;
            p3 = 1'b0;
      
            flag = 1'b0;     
            
		end else if (counter_decoder == 6'd10) begin
				timeAndDate_out = 44'd0;	// when it is the 11th seconds, zeroed timeAndDate_out signal.
      end else if (counter_decoder == 6'd58) begin

            timeAndDate_out[10:7] = data_dcf[24:21];      //   minute
            timeAndDate_out[13:11] = data_dcf[27:25];
            p1 = ^data_dcf[27:21];
            
            timeAndDate_out[17:14] = data_dcf[32:29];     //    hour
            timeAndDate_out[19:18] = data_dcf[34:33];
            p2 = ^data_dcf[34:29];
            
            timeAndDate_out[23:20] = data_dcf[39:36];     // day
            timeAndDate_out[25:24] = data_dcf[41:40];
            
            timeAndDate_out[41:39] = data_dcf[44:42];     // Weekday
            
            timeAndDate_out[29:26] = data_dcf[48:45];     //month
            timeAndDate_out[30] = data_dcf[49];
            
            timeAndDate_out[34:31] = data_dcf[53:50];     //year
            timeAndDate_out[38:35] = data_dcf[57:54];
            p3 = ^data_dcf[57:36];

            flag = 1'b1;     // Receive 59 values
      end else begin
            data_dcf[counter_decoder] = dcf_value;
      end
end


always @(p1 or p2 or p3) begin
      if ((p1 != data_dcf[28]) || (p2 != data_dcf[35]) || (p3 != data_dcf[58])) begin
            result = 1'b1;
      end else begin
            result = 1'b0;
      end
end

always @(negedge nReset or posedge clk_en_1hz) begin
      if (!nReset) begin
            data_valid <= 1'b0;     // assume the value '1' for one second in the second zero
      end else if((flag == 1'b1) && (result == 1'b0)) begin
            data_valid <= 1'b1;
      end else begin
		data_valid <= 1'b0;
	end
end

endmodule          
              

