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

reg [8:0] sec_disp, min_disp, hour_disp, day_disp, mon_disp, year_disp, week_disp; //There is 366 days maximum, for convenience let all variables have 9 bits
reg min_carry,hour_carry,day_carry,mon_carry,year_carry;         
reg[4:0] date; // 5'b1_1111=31 This is the number of days in each month
wire year_4;

// This is for the judgement of leap year. Because there are only two digits of years which means there are only 100 years.
assign year_4=(timeAndDate_Out[32:31]==2'b0); //This is the first two bits of the year. If year_4 == 1, then it is a leap.

	always@(posedge clkEn1Hz or negedge nReset ) //sec
		begin
       if(!nReset)	// if trigger an reset, then set registers to 0.
             begin    
               timeAndDate_Out[43:0] <= 43'b0;
				     	 sec_disp[8:0] <= 9'd0;    
             end
       else if((sec_disp[8:0] == 9'd59))     //When seconds is 59s, then set second to 0 and minute_carry to 1.
             begin
               sec_disp[8:0] <= 9'd0;
               min_carry <= 1'b1;
             end
       else
             begin
                sec_disp[8:0] <= sec_disp[8:0] + 1;
                min_carry <= 1'b0;
             end
		end

   always@(posedge min_carry or negedge nReset) //min
     begin
       if(!nReset)	// if trigger an reset, then set registers to 0.
             begin    
               timeAndDate_Out[43:0] <= 43'b0;
					     min_disp[8:0] <= 9'd0;    
             end
       else if((min_disp[8:0] == 9'd59))     //When minutes is 59s, then set second to 0 and minute_carry to 1.
             begin
               min_disp[8:0] <= 9'd0;
               hour_carry <= 1'b1;
             end
       else
             begin
                min_disp[8:0] <= min_disp[8:0] + 1;
                hour_carry <= 1'b0;
             end
     end

   always@(posedge hour_carry or negedge nReset) //hour
     begin
       if(!nReset)	// if trigger an reset, then set registers to 0.
             begin    
               timeAndDate_Out[43:0] <= 43'b0;
					     hour_disp[8:0] <= 9'd0;    
             end
       else if((hour_disp[8:0] == 9'd23))     //When hour is 23, then set second to 0 and day_carry to 1.
             begin
               hour_disp[8:0] <= 9'd0;
               day_carry <= 1'b1;
             end
       else
             begin
                hour_disp[8:0] <= hour_disp[8:0] + 1;
                day_carry <= 1'b0;
             end
     end    

   always@(posedge day_carry or negedge nReset)   //day
     begin
       if(!nReset)	// if trigger an reset, then set registers to 0.
             begin    
               timeAndDate_Out[43:0] <= 43'b0;
					     day_disp[8:0] <= 9'd0;    
             end
       else if((day_disp[8:0] == date))     //When day is equal to the days in a month, then set disp to 1 and mon_carry to 1.
             begin
               day_disp[8:0] <= 9'd1;   // start from 1st day.
               mon_carry <= 1'b1;
             end
       else
             begin
                day_disp[8:0] <= day_disp[8:0] + 1;
                mon_carry <= 1'b0;
             end
     end

     always@(posedge day_carry or negedge nReset) //The day of the week: Monday, Tuesday...
         begin
			 if(!nReset)	// if trigger an reset, then set registers to 0.
					 begin    
						timeAndDate_Out[43:0] <= 43'b0;
						week_disp[8:0] <= 9'd1;    //start from Monday -> start from 1
					 end
			 else if((week_disp[8:0] == 9'd7))     //When seconds is 59s, then set second to 0 and minute_carry to 1.
					 begin
						week_disp[8:0] <= 9'd1;
					 end
			 else
					 begin
						 week_disp[8:0] <= week_disp[8:0] + 1;
					 end
			end        

     always@(posedge mon_carry or negedge nReset) //month
         begin
			 if(!nReset)	// if trigger an reset, then set registers to 0.
					 begin    
						timeAndDate_Out[43:0] <= 43'b0;
						mon_disp[8:0] <= 9'd1;    //start from January.
					 end
			 else if((mon_disp[8:0] == 9'd12))     //When seconds is 59s, then set second to 0 and minute_carry to 1.
					 begin
						mon_disp[8:0] <= 9'd1;
						year_carry <= 1'b1;
					 end
			 else
					 begin
						 mon_disp[8:0] <= mon_disp[8:0] + 1;
						 year_carry <= 1'b0;
					 end
         end

      always@(posedge year_carry or negedge nReset)//year
          begin
				 if(!nReset)	// if trigger an reset, then set registers to 0.
						 begin    
							timeAndDate_Out[43:0] <= 43'b0;
							year_disp[8:0] <= 9'd0;    
						 end
				 else if((year_disp[8:0] == 9'd99))     //When seconds is 59s, then set second to 0 and minute_carry to 1.
						 begin
							year_disp[8:0] <= 9'd0;
						 end
				 else
						 begin
							 year_disp[8:0] <= year_disp[8:0] + 1;
						 end
			  end

      always @(posedge setTimeAndDate_in) 
        begin //This is for set time and date
          timeAndDate_Out[43:0] <= timeAndDate_In[43:0]; // If the "setTimeAndDate_in==1", then registers should accept values.
        end

      //This is for display digits
      always @(sec_disp or min_disp or hour_disp or day_disp or mon_disp or year_disp or week_disp )
        begin
          timeAndDate_Out[3:0] <= sec_disp // 除法和取余运算遇到了问题。。。。
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
