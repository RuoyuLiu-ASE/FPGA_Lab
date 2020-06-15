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

module timeAndDateClock(clk,                // global 10Mhz clock
                        clkEn1Hz,           // 1Hz clock
                        nReset,             // asynchronous reset (active low)  
                        setTimeAndDate_in,  
                        timeAndDate_In,     
                        timeAndDate_Out);   

// ---------- YOUR CODE HERE ---------- 
input clk;               // global 10Mhz clock
input clkEn1Hz;           // 1Hz clock
input nReset;             // asynchronous reset (active low)  
input setTimeAndDate_in;  
input[43:0] timeAndDate_In;     
output [43:0] timeAndDate_Out;
reg [43:0] timeAndDate_Out;
 

reg [6:0] sec_count,min_count;
reg [5:0] hour_count,day_count;
reg [4:0] mon_count;
reg [7:0] year_count;
reg [2:0] weekday_count;  

reg min_carry,hour_carry,day_carry,mon_carry,year_carry;         

reg[4:0] date; // 5'b1_1111=31 This is the number of days in each month

wire year_4;  //Flag of leap year

// This is for the judgement of leap year. Because there are only two digits of years which means there are only 100 years.
assign year_4=(timeAndDate_Out[32:31]==2'b0); //This is the first two bits of the year. If year_4 == 1, then it is a leap.

//  always block's signal list: reset, setTime, clkEn1Hz. 
always@(posedge setTimeAndDate_in or posedge clkEn1Hz or negedge nReset) //sec
   begin
       if(!nReset)
             begin    
               timeAndDate_Out[43:0] <= 44'b0;	// if trigger an reset, then set registers to 0.    
             end
       else if(setTimeAndDate_in)  
             begin
               timeAndDate_Out[43:0] <= timeAndDate_In[43:0]; // If the "setTimeAndDate_in==1", then registers should accept values.
             end
        else
          begin
            timeAndDate_Out[6:0] <= sec_count[6:0];
            timeAndDate_Out[13:7] <= min_count[6:0];
            timeAndDate_Out[19:14] <= hour_count[5:0];
            timeAndDate_Out[25:20] <= day_count[5:0];
            timeAndDate_Out[30:26] <= mon_count[4:0];
            timeAndDate_Out[38:31] <= year_count[7:0];
            timeAndDate_Out[41:39] <= weekday_count[2:0];
          end
   end

   always @(posedge clkEn1Hz or negedge nReset or posedge setTimeAndDate_in) begin   // seconds
         if (!nReset) 
           begin
             sec_count <= 7'b0;
             min_carry <= 1'b0;
           end 
         else if (setTimeAndDate_in) 
                begin
                  sec_count <= timeAndDate_In[6:0];
                  min_carry <= 1'b0;
                end
         else if ((sec_count[6:4] != 3'd5) && (sec_count[3:0] == 4'd9)) //If low digit is 9, next clock, set low to 0,and add 1 to high digit
                 begin
                   sec_count[3:0] <= 4'd0;
                   sec_count[6:4] <= sec_count[6:4] + 1;
                   min_carry <= 0;
                 end
           else if((sec_count[6:4] == 3'd5) && (sec_count[3:0] == 4'd9))     //When seconds is 59s, then set second to 0 and minute_carry to 1.
                 begin
                   sec_count[6:0] <= 7'd0;
                   min_carry <= 1'b1;
                 end
           else
                 begin
                    sec_count[3:0] <= sec_count[3:0] + 1;
                    min_carry <= 1'b0;
                 end    
   end

   always@(posedge min_carry or negedge nReset or posedge setTimeAndDate_in) //min
     begin
        if (!nReset) 
           begin
             min_count <= 7'b0;
             hour_carry <= 1'b0;
           end 
        else if (setTimeAndDate_in) 
                begin
                  min_count <= timeAndDate_In[13:7];
                  hour_carry <= 1'b0;
                end			  
        else if ((min_count[6:4] != 3'd5) && (min_count[3:0] == 4'd9)) //When the low digit is 9
              begin
                min_count[3:0] <= 4'd0;
                min_count[6:4] <= min_count[6:4] + 1;
                hour_carry <= 0;
              end
        else if((min_count[6:4] == 3'd5) && (min_count[3:0] == 4'd9)) //When minutes is 59 min, then set minutes to 0 and hour_carry to 1.
              begin
                min_count[6:0] <= 7'd0;
                hour_carry <= 1'b1;
              end
        else
              begin
                 min_count[3:0] <= min_count[3:0] + 1;
                 hour_carry <= 1'b0;
              end
     end

    always@(posedge hour_carry or negedge nReset or posedge setTimeAndDate_in) //hour 
      begin
        if (!nReset) 
           begin
             hour_count <= 6'b0;
             day_carry <= 1'b0;
           end 
        else if (setTimeAndDate_in) 
                begin
                  hour_count <= timeAndDate_In[19:14];
                  day_carry <= 1'b0;
                end			  
        else if ((hour_count[5:4] != 2'd2) && (hour_count[3:0] == 4'd9)) //When low digit is 9
                  begin
                    hour_count[3:0] <= 4'd0;
                    hour_count[5:4] <= hour_count[5:4] + 1;
                    day_carry <= 0;
                  end
            else if((hour_count[5:4] == 2'd2) && (hour_count[3:0] == 4'd3))     //When time is 23:59, then set hour to 0 and day_carry to 1.
                  begin
                    hour_count[5:0] <= 6'd0;
                    day_carry <= 1'b1;
                  end
            else
                  begin
                     hour_count[3:0] <= hour_count[3:0] + 1;
                     day_carry <= 1'b0;
						end
         end    

    always@(posedge day_carry or negedge nReset or posedge setTimeAndDate_in)   //day
      begin
        if (!nReset) 
           begin
             day_count <= 6'b0;
             mon_carry <= 1'b0;
           end 
        else if (setTimeAndDate_in) 
                begin
                  day_count <= timeAndDate_In[25:20];
                  mon_carry <= 1'b0;
                end			  
        else if (((day_count[5:4]*10 + day_count[3:0]) != date) && (day_count[3:0] == 4'd9)) 
                  begin
                    day_count[3:0] <= 4'd0;
                    day_count[5:4] <= day_count[5:4] + 1;
                    mon_carry <= 0;
                  end
            else if((day_count[5:4]*10 + day_count[3:0]) == date)     //When days is equal to "date", then set day to 0 and mon_carry to 1.
                  begin
                    day_count[5:0] <= 6'd1;   // start from 1st day
                    mon_carry <= 1'b1;
                  end
            else
                  begin
                     day_count[3:0] <= day_count[3:0] + 1;
                     mon_carry <= 1'b0;
						end
      end

    always@(posedge day_carry or negedge nReset or posedge setTimeAndDate_in) //The day of the week: Monday, Tuesday...
      begin
        if (!nReset) 
           begin
             weekday_count <= 3'b1;
           end 
        else if (setTimeAndDate_in) 
                begin
                  weekday_count <= timeAndDate_In[41:39];
                end			  
        else if(weekday_count[2:0]==3'd7) // 7 means sunday. 1 means Monday.
                 begin
                   weekday_count[2:0]<=3'd1;
                 end
              else
                  begin
                   weekday_count[2:0]<=weekday_count[2:0]+1;
                  end  
      end        

    always@(posedge mon_carry or negedge nReset or posedge setTimeAndDate_in) //month
      begin
	     if (!nReset) 
           begin
             mon_count <= 5'b0;
             year_carry <= 1'b0;
           end
        else if (setTimeAndDate_in) 
                begin
                  mon_count <= timeAndDate_In[30:26];
                  year_carry <= 1'b0;
                end			  
        else if (mon_count[3:0] == 4'd9) 
                  begin
                    mon_count[3:0] <= 4'd0;
                    mon_count[4] <= mon_count[4] + 1;
                    year_carry <= 1'b0;
                  end
            else if((mon_count[4] == 1'd1) && mon_count[3:0] == 4'd2)     //When month is equal to 12, then set month to 1 and year_carry to 1.
                  begin
                    mon_count[4:0] <= 5'd1;
                    year_carry <= 1'b1;
                  end
            else
                  begin
                     mon_count[3:0] <= mon_count[3:0] + 1;
                     year_carry <= 1'b0;
						end
      end

    always@(posedge year_carry or negedge nReset or posedge setTimeAndDate_in)//year
      begin
        if (!nReset) 
           begin
             year_count <= 8'b0;
           end 
        else if (setTimeAndDate_in) 
                begin
                  year_count <= timeAndDate_In[38:31];
                end			  
        else if ((year_count[7:4] != 4'd9) && (year_count[3:0] == 4'd9))
                begin
                  year_count[3:0] <= 4'd0;
                  year_count[7:4] <= year_count[7:4] + 1;
                end
           else if((year_count[7:4] == 4'd9) && (year_count[3:0] == 4'd9))    // When the year is 99, then set the year to 0.           
              begin
                  year_count[7:0] <= 8'd0;        
              end
           else 
              begin
                  year_count[3:0] <= year_count[3:0]+1;               
              end
  	  end

   always@(posedge clk)
        begin 
          case(mon_count[4]*10 + mon_count[3:0]) 
           4'd1:date <= 5'd31; 
           4'd2: 
             begin 
               if(year_4)
                 date <= 5'd29;
               else
                 date <= 5'd28;
               end
           4'd3:date <= 5'd31;
           4'd4:date <= 5'd30;
           4'd5:date <= 5'd31; 
           4'd6:date <= 5'd30;
           4'd7:date <= 5'd31;
           4'd8:date <= 5'd31; 
           4'd9:date <= 5'd30;
           4'd10:date <= 5'd31;
           4'd11:date <= 5'd30; 
           4'd12:date <= 5'd31;
           default:date <= 5'd30; 
         endcase 
       end     
endmodule
