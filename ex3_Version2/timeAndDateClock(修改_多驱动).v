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

reg min_carry,hour_carry,day_carry,mon_carry,year_carry;         
reg[4:0] date; // 5'b1_1111=31 This is the number of days in each month
wire year_4;

// This is for the judgement of leap year. Because there are only two digits of years which means there are only 100 years.
assign year_4=(timeAndDate_Out[32:31]==2'b0); //This is the first two bits of the year. If year_4 == 1, then it is a leap.

always@(posedge setTimeAndDate_in or negedge nReset or posedge clkEn1Hz or posedge min_carry or posedge hour_carry or posedge day_carry or posedge mon_carry or posedge year_carry) //sec
   begin
       if(!nReset)
             begin    
               timeAndDate_Out[43:0] <= 44'b0;	// if trigger an reset, then set registers to 0.    
					     min_carry <= 0;
					     hour_carry <= 0;
					     day_carry <= 0;
					     mon_carry <= 0;
					     year_carry <= 0;
             end
       else if(setTimeAndDate_in == 1'b1)  
             begin
               timeAndDate_Out[43:0] <= timeAndDate_In[43:0]; // If the "setTimeAndDate_in==1", then registers should accept values.
					     min_carry <= 0;
					     hour_carry <= 0;
					     day_carry <= 0;
					     mon_carry <= 0;
					     year_carry <= 0;
             end
        else if (clkEn1Hz == 1'b1) begin
              if ((timeAndDate_Out[6:4] != 3'd5) && (timeAndDate_Out[3:0] == 4'd9)) //If low digit is 9, next clock, set low to 0,and add 1 to high digit
                  begin
                    timeAndDate_Out[3:0] <= 4'd0;
                    timeAndDate_Out[6:4] <= timeAndDate_Out[6:4] + 1;
                    min_carry <= 0;
                  end
            else if((timeAndDate_Out[6:4] == 3'd5) && (timeAndDate_Out[3:0] == 4'd9))     //When seconds is 59s, then set second to 0 and minute_carry to 1.
                  begin
                    timeAndDate_Out[6:0] <= 7'd0;
                    min_carry <= 1'b1;
                  end
            else
                  begin
                     timeAndDate_Out[4:0] <= timeAndDate_Out[4:0] + 1;
                     min_carry <= 1'b0;
                  end
       end else if (min_carry == 1'b1) begin
                 if ((timeAndDate_Out[13:11] != 3'd5) && (timeAndDate_Out[10:7] == 4'd9)) //When the low digit is 9
                       begin
                         timeAndDate_Out[10:7] <= 4'd0;
                         timeAndDate_Out[13:11] <= timeAndDate_Out[13:11] + 1;
                         hour_carry <= 0;
                       end
                 else if((timeAndDate_Out[13:11] == 3'd5) && (timeAndDate_Out[10:7] == 4'd9)) //When minutes is 59 min, then set minutes to 0 and hour_carry to 1.
                       begin
                         timeAndDate_Out[13:7] <= 7'd0;
                         hour_carry <= 1'b1;
                       end
                 else
                       begin
                          timeAndDate_Out[10:7] <= timeAndDate_Out[10:7] + 1;
                          hour_carry <= 1'b0;
                       end
           end else if(hour_carry == 1'b1) begin
                      if ((timeAndDate_Out[19:18] != 2'd2) && (timeAndDate_Out[17:14] == 4'd9)) //When low digit is 9
                           begin
                             timeAndDate_Out[17:14] <= 4'd0;
                             timeAndDate_Out[19:18] <= timeAndDate_Out[19:18] + 1;
                             day_carry <= 0;
                           end
                     else if((timeAndDate_Out[19:18] == 2'd2) && (timeAndDate_Out[17:14] == 4'd3))     //When time is 23:59, then set hour to 0 and day_carry to 1.
                           begin
                             timeAndDate_Out[19:14] <= 6'd0;
                             day_carry <= 1'b1;
                           end
                     else
                           begin
                              timeAndDate_Out[17:14] <= timeAndDate_Out[17:14] + 1;
                              day_carry <= 1'b0;
    		              	   end        
           end else if (day_carry == 1'b1) begin
                if (((timeAndDate_Out[25:24]*10 + timeAndDate_Out[23:20]) != date) && (timeAndDate_Out[23:20] == 4'd9)) 
                      begin
                        timeAndDate_Out[23:20] <= 4'd0;
                        timeAndDate_Out[25:24] <= timeAndDate_Out[25:24] + 1;
                        mon_carry <= 0;
                      end
                else if((timeAndDate_Out[25:24]*10 + timeAndDate_Out[23:20]) == date)     //When days is equal to "date", then set day to 0 and mon_carry to 1.
                      begin
                        timeAndDate_Out[25:20] <= 6'd1;   // start from 1st day
                        mon_carry <= 1'b1;
                      end
                else if(timeAndDate_Out[41:39] == 3'd7) // 7 means sunday. 1 means Monday.
                     begin
                       timeAndDate_Out[41:39] <= 3'd1;	//The day of the week: Monday, Tuesday
                     end														
                else
                      begin
                         timeAndDate_Out[23:20] <= timeAndDate_Out[23:20] + 1;
    							timeAndDate_Out[41:39]<= timeAndDate_Out[41:39] + 1;
                         mon_carry <= 1'b0;
    						      end
           end else if (mon_carry == 1'b1) begin
                 if (timeAndDate_Out[29:26] == 4'd9) 
                      begin
                        timeAndDate_Out[29:26] <= 4'd0;
                        timeAndDate_Out[30] <= timeAndDate_Out[30] + 1;
                        year_carry <= 1'b0;
                      end
                else if((timeAndDate_Out[30] == 1'd1) && timeAndDate_Out[29:26] == 4'd2)     //When month is equal to 12, then set month to 1 and year_carry to 1.
                      begin
                        timeAndDate_Out[30:26] <= 5'd1;
                        year_carry <= 1'b1;
                      end
                else
                      begin
                         timeAndDate_Out[29:26] <= timeAndDate_Out[29:26] + 1;
                         year_carry <= 1'b0;
    						      end        
           end else if (year_carry == 1'b1) begin
                 if ((timeAndDate_Out[38:35] != 4'd9) && (timeAndDate_Out[34:31] == 4'd9))
                    begin
                      timeAndDate_Out[34:31] <= 4'd0;
                      timeAndDate_Out[38:35] <= timeAndDate_Out[38:35] + 1;
                    end
               else if((timeAndDate_Out[38:35] == 4'd9) && (timeAndDate_Out[34:31] == 4'd9))    // When the year is 99, then set the year to 0.           
                  begin
                      timeAndDate_Out[38:31] <= 8'd0;        
                  end
               else 
                  begin
                      timeAndDate_Out[34:31] <= timeAndDate_Out[34:31]+1;               
                  end       
           end    
   end

   always@(*)
        begin 
          case(timeAndDate_Out[30]*10 + timeAndDate_Out[29:26]) 
           4'd1:date=31; 
           4'd2: 
             begin 
               if(year_4)
                 date=29;
               else
                 date=28;
               end
           4'd3:date=31;
           4'd4:date=30;
           4'd5:date=31; 
           4'd6:date=30;
           4'd7:date=31;
           4'd8:date=31; 
           4'd9:date=30;
           4'd10:date=31;
           4'd11:date=30; 
           4'd12:date=31;
           default:date=31; 
         endcase 
       end     
endmodule
