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

reg sec_carry_L,min_carry_L,hour_carry_L,day_carry_L,mon_carry_L,year_carry_L; //this is the carry for low digit 
reg min_carry,hour_carry,day_carry,mon_carry,year_carry;         // this is the carry for high digit 
reg[4:0] date; // 5'b1_1111=31 This is the number of days in each month
wire year_4;

// This is for the judgement of leap year. Because there are only two digits of years which means there are only 100 years.
assign year_4=(timeAndDate_Out[32:31]==2'b0); //This is the first two bits of the year. If year_4 == 1, then it is a leap.


always@(posedge setTimeAndDate_in or posedge clkEn1Hz or negedge nReset ) //sec: Low digit
   begin
       if(!nReset)
             begin    
               timeAndDate_Out[43:0] <= 43'b0;
               //timeAndDate_Out[6:0] <= 7'b0;      // if trigger an reset, then set registers to 0.
             end
       else if(setTimeAndDate_in)  
             begin
               timeAndDate_Out[3:0] <= timeAndDate_In[3:0]; // If the "setTimeAndDate_in==1", then registers should accept values.
               sec_carry_L <= 1'b0;
             end
       else if((timeAndDate_Out[3:0] == 4'd9))     //When the low digit of second is 9, then set second to 0 and second_carry low to 1.
             begin
               timeAndDate_Out[3:0] <= 4'd0;
               sec_carry_L <= 1'b1;
             end
       else
             begin
                timeAndDate_Out[3:0] <= timeAndDate_Out[3:0] + 1;
                sec_carry_L <= 1'b0;
             end
   end

always@(posedge setTimeAndDate_in or posedge sec_carry_L or negedge nReset ) //sec: High digit
   begin
       if(!nReset)
             begin    
               timeAndDate_Out[43:0] <= 43'b0;
               //timeAndDate_Out[6:0] <= 7'b0;      // if trigger an reset, then set registers to 0.
             end
       else if(setTimeAndDate_in)  
             begin
               timeAndDate_Out[6:4] <= timeAndDate_In[6:4]; // If the "setTimeAndDate_in==1", then registers should accept values.
               min_carry <= 1'b0;
             end
       else if((timeAndDate_Out[6:4] == 3'd5) && (timeAndDate_Out[3:0] == 4'd9))     //When seconds is 59s, then set second to 0 and minute_carry to 1.
             begin
               timeAndDate_Out[6:4] <= 3'd0;
               min_carry <= 1'b1;
             end
       else
             begin
                timeAndDate_Out[6:4] <= timeAndDate_Out[6:4] + 1;
                min_carry <= 1'b0;
             end
   end

   always@(posedge min_carry or posedge setTimeAndDate_in or negedge nReset) //min: Low digit
     begin
        if(!nReset)
              begin    
               timeAndDate_Out[43:0] <= 43'b0;
               //timeAndDate_Out[13:7] <= 7'b0;      // if trigger an reset, then set registers to 0.
              end
        else if(setTimeAndDate_in)  
              begin
                timeAndDate_Out[10:7] <= timeAndDate_In[10:7]; // If the "setTimeAndDate_in==1", then registers should accept values.
                min_carry_L <= 1'b0;
              end
        else if((timeAndDate_Out[10:7] == 4'd9))     //When the low digit of minutes is 9, then set minutes to 0 and min_carry_L to 1.
              begin
                timeAndDate_Out[10:7] <= 4'd0;
                min_carry_L <= 1'b1;
              end
        else
              begin
                 timeAndDate_Out[10:7] <= timeAndDate_Out[10:7] + 1;
                 min_carry_L <= 1'b0;
              end
     end

   always@(posedge min_carry_L or posedge setTimeAndDate_in or negedge nReset) //min: High digit
     begin
        if(!nReset)
              begin    
               timeAndDate_Out[43:0] <= 43'b0;
               //timeAndDate_Out[13:7] <= 7'b0;      // if trigger an reset, then set registers to 0.
              end
        else if(setTimeAndDate_in)  
              begin
                timeAndDate_Out[13:11] <= timeAndDate_In[13:11]; // If the "setTimeAndDate_in==1", then registers should accept values.
                hour_carry <= 1'b0;
              end   //When minutes is 59min:59s, then set minutes to 0 and hour_carry to 1.
        else if((timeAndDate_Out[13:11] == 3'd5) && (timeAndDate_Out[10:7] == 4'd9) &&  (timeAndDate_Out[6:4] == 3'd5) && (timeAndDate_Out[3:0] == 4'd9))     
              begin
                timeAndDate_Out[13:11] <= 3'd0;
                hour_carry <= 1'b1;
              end
        else
              begin
                 timeAndDate_Out[13:11] <= timeAndDate_Out[13:11] + 1;
                 hour_carry <= 1'b0;
              end
     end

     always@(posedge hour_carry or posedge setTimeAndDate_in or negedge nReset) //hour: Low digit
         begin
            if(!nReset)
                  begin    
                    timeAndDate_Out[43:0] <= 43'b0;
                    //timeAndDate_Out[19:14] <= 6'b0;      // if trigger an reset, then set registers to 0.
                  end
            else if(setTimeAndDate_in)  
                  begin
                    timeAndDate_Out[17:14] <= timeAndDate_In[17:14]; // If the "setTimeAndDate_in==1", then registers should accept values.
                    hour_carry_L <= 1'b0;
                  end
            else if((timeAndDate_Out[17:14] == 4'd9))     //When the low digit of hour is 9, then set low digit to 0 and hour_carry_L to 1.
                  begin
                    timeAndDate_Out[17:14] <= 6'd0;
                    hour_carry_L <= 1'b1;
                  end
            else
                  begin
                     timeAndDate_Out[17:14] <= timeAndDate_Out[17:14] + 1;
                     hour_carry_L <= 1'b0;
						end
         end    

     always@(posedge hour_carry_L or posedge setTimeAndDate_in or negedge nReset) //hour: High digit
         begin
            if(!nReset)
                  begin    
                    timeAndDate_Out[43:0] <= 43'b0;
                    //timeAndDate_Out[19:14] <= 6'b0;      // if trigger an reset, then set registers to 0.
                  end
            else if(setTimeAndDate_in)  
                  begin
                    timeAndDate_Out[19:18] <= timeAndDate_In[19:18]; // If the "setTimeAndDate_in==1", then registers should accept values.
                    day_carry <= 1'b0;
                  end     //When time is 23:59:59, then set hour to 0 and day_carry to 1.
            else if((timeAndDate_Out[19:18] == 2'd2) && (timeAndDate_Out[17:14] == 4'd3) && (timeAndDate_Out[13:11] == 3'd5) && (timeAndDate_Out[10:7] == 4'd9) &&  (timeAndDate_Out[6:4] == 3'd5) && (timeAndDate_Out[3:0] == 4'd9))    
                  begin
                    timeAndDate_Out[19:18] <= 6'd0;
                    day_carry <= 1'b1;
                  end
            else
                  begin
                     timeAndDate_Out[19:18] <= timeAndDate_Out[19:18] + 1;
                     day_carry <= 1'b0;
						end
         end    

      always@(posedge day_carry or posedge setTimeAndDate_in or negedge nReset)   //day
         begin
            if(!nReset)
                  begin    
                    timeAndDate_Out[43:0] <= 43'b0;
                    //timeAndDate_Out[25:20] <= 6'b0;      // if trigger an reset, then set registers to 0.
                  end
            else if(setTimeAndDate_in)  
                  begin
                    timeAndDate_Out[25:20] <= timeAndDate_In[25:20]; // If the "setTimeAndDate_in==1", then registers should accept values.
                    mon_carry <= 1'b0;
                  end
            else if((timeAndDate_Out[25:20] == date))     //When days is equal to "date", then set day to 0 and mon_carry to 1.
                  begin
                    timeAndDate_Out[25:20] <= 6'd0;
                    mon_carry <= 1'b1;
                  end
            else
                  begin
                     timeAndDate_Out[25:20] <= timeAndDate_Out[25:20] + 1;
                     mon_carry <= 1'b0;
						end
         end

     always@(posedge day_carry or posedge setTimeAndDate_in or negedge nReset) //The day of the week: Monday, Tuesday...
         begin
              if(!nReset)
                 begin
                   timeAndDate_Out[43:0] <= 43'b0;
                   //timeAndDate_Out[41:39]<=3'd0;  //Reset -> set all registers to 0.
                 end
              else if(setTimeAndDate_in)
                 begin
                   timeAndDate_Out[41:39]<=timeAndDate_In[41:39];
                 end
              else if(timeAndDate_Out[41:39]==7) // 7 means sunday. 1 means Monday.
                 begin
                   timeAndDate_Out[41:39]<=1;
                 end
              else
                  begin
                   timeAndDate_Out[41:39]<=timeAndDate_Out[41:39]+1;
                  end  
         end        

     always@(posedge mon_carry or posedge setTimeAndDate_in or negedge nReset) //month
         begin
            if(!nReset)
                  begin    
                   timeAndDate_Out[43:0] <= 43'b0;
                   // timeAndDate_Out[30:26] <= 5'b0;      // if trigger an reset, then set registers to 0.
                  end
            else if(setTimeAndDate_in)  
                  begin
                    timeAndDate_Out[30:26] <= timeAndDate_In[30:26]; // If the "setTimeAndDate_in==1", then registers should accept values.
                    year_carry <= 1'b0;
                  end
            else if((timeAndDate_Out[30:26] == 5'd12))     //When month is equal to 12, then set month to 1 and year_carry to 1.
                  begin
                    timeAndDate_Out[30:26] <= 5'd1;
                    year_carry <= 1'b1;
                  end
            else
                  begin
                     timeAndDate_Out[30:26] <= timeAndDate_Out[30:26] + 1;
                     year_carry <= 1'b0;
						end
         end

      always@(posedge year_carry or posedge setTimeAndDate_in or negedge nReset)//year
          begin
           if(!nReset)
                begin
                   timeAndDate_Out[43:0] <= 43'b0;
                  //timeAndDate_Out[38:31] <= 8'b0;      // if trigger an reset, then set registers to 0.
                end
           else if(setTimeAndDate_in)
                begin
                  timeAndDate_Out[38:31] <= timeAndDate_In[38:31]; // If the "setTimeAndDate_in==1", then registers should accept values.
                end
           else if(timeAndDate_Out[38:31] == 8'd99)    // When the year is 99, then set the year to 0.           
              begin
                  timeAndDate_Out[38:31] <= 8'd0;        
              end
           else 
              begin
                  timeAndDate_Out[38:31] <= timeAndDate_Out[38:31]+1;               
              end
			  end

   always@(*)
        begin 
          case(timeAndDate_Out[30:26]) 
           5'd1:date=31; 
           5'd2: 
              begin 
                if(year_4)
                  date=29;
                else
                  date=28;
                end
           5'd3:date=31;
           5'd4:date=30;
           5'd5:date=31; 
           5'd6:date=30;
           5'd7:date=31;
           5'd8:date=31; 
           5'd9:date=30;
           5'd10:date=31;
           5'd11:date=30; 
           5'd12:date=31;
           default:date=30; 
         endcase 
       end     
endmodule
