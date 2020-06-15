`timescale 10ns/10ns    //100ms=10000*10ns

module tb_Clock;

reg clk_10mhz;
reg clk_1hz;
reg reset;
reg setFixTime;
reg [43:0] time_in;
wire [43:0] time_out;
wire min_carry,hour_carry,day_carry,mon_carry,year_carry;
reg [24:0] cnt;// For generate 1Hz clock

initial begin
    clk_10mhz = 1'b0;
    clk_1hz = 1'b0;         //Even though the enable signal should always have value 1. But for the test, creat a 1hz enable signal
    cnt = 25'b0;
/*    
    time_in [3:0] = 4'b0101;   // lower digit of second is 5
    time_in [6:4] = 3'b100;    // higher digit of second is 4
    time_in [10:7] = 4'b1001;   // lower digit of minute is 9
    time_in [13:11] = 3'b101;    // higher digit of minute is 5
    time_in [17:14] = 4'b0011;   // lower digit of hour is 3
    time_in [19:18] = 2'b10;     // higher digit of hour is 2
    time_in [23:20] = 4'b0001;   // lower digit of day is 1
    time_in [25:24] = 2'b11;     // higher digit of day is 3
    time_in [29:26] = 4'b0010;   // lower digit of month is 2
    time_in [30]    = 1'b1;      // higher digit of month is 1   To test years without Leap Feb
    time_in [34:31] = 4'b1001;   // lower digit of year is 9
    time_in [38:35] = 4'b0001;   // higher digit of year is 1
    time_in [41:39] = 3'b010;    // weekday is Tuesday
    time_in [43:42] = 2'b00;     // timezone is 0
*/    
    
    time_in [3:0] = 4'b0101;   // lower digit of second is 5
    time_in [6:4] = 3'b100;    // higher digit of second is 4
    time_in [10:7] = 4'b1001;   // lower digit of minute is 9
    time_in [13:11] = 3'b101;    // higher digit of minute is 5
    time_in [17:14] = 4'b0011;   // lower digit of hour is 3
    time_in [19:18] = 2'b10;     // higher digit of hour is 2
    time_in [23:20] = 4'b0001;   // lower digit of day is 1
    time_in [25:24] = 2'b11;     // higher digit of day is 3
    time_in [29:26] = 4'b0001;   // lower digit of month is 1
    time_in [30]    = 1'b0;      // higher digit of month is 1   To test Leap Feb
    time_in [34:31] = 4'b0000;   // lower digit of year is 0
    time_in [38:35] = 4'b0010;   // higher digit of year is 2
    time_in [41:39] = 3'b010;    // weekday is Tuesday
    time_in [43:42] = 2'b00;     // timezone is 0
    
    reset = 1'b1;
    setFixTime = 1'b0;
    #10 reset = 1'b0;
    #20 reset = 1'b1;
    #10 setFixTime = 1'b1; //When the setTimeAndDate equals '1', then all register will change to corresponding value
    #20 setFixTime = 1'b0;
end


always begin
   #5 clk_10mhz = ~clk_10mhz;
   if (!clk_10mhz) begin
       if(cnt == 25'd100_000 || reset == 1'b0)begin   // When the timestep is 10ns, cnt = 10000_000, will generate 1hz
           cnt = 0;
       end else begin
           cnt = cnt + 1;
       end
   end
   clk_1hz = (cnt > 25'd50000)?1'b1:1'b0;       // This is related to cnt = 10000_000
end

// Instance
timeAndDateClock clock(.clk(clk_10mhz),.clkEn1Hz(clk_1hz),.nReset(reset),.setTimeAndDate_in(setFixTime),.timeAndDate_In(time_in),.timeAndDate_Out(time_out));
/*
  //input
reg clk;
reg time_set;
reg rst;             //time_clear--rst; time_set_en--time_set;  
reg[11:0] year_set;  // 12'b1000_0011_0100=2100
reg[3:0] mon_set;  // 4'b1100=12
reg[2:0] week_set; // 3'b111=7
reg[4:0] day_set;  // 5'b1_1111=31
reg[4:0] hour_set;  // 5'b1_1000=24
reg[5:0] min_set;  // 6'b11_1100=60
reg[5:0] sec_set;  // 6'b11_1100=60
  //output
  wire[11:0] year;  // 12'b1000_0011_0100=2100
  wire[3:0] mon;  // 4'b1100=12
  wire[2:0] week; // 3'b111=7
  wire[4:0] day;  // 5'b1_1111=31
  wire[4:0] hour;   // 5'b1_1000=24
  wire[5:0] min;  // 6'b11_1100=60
  wire[5:0] sec;  // 6'b11_1100=60

   initial
     begin // January
         year_set=2000;  // 12'b1000_0011_0100=2100
         mon_set=1;  // 4'b1100=12
         week_set=1; // 3'b111=7
         day_set=1;  // 5'b1_1111=31
         hour_set=0;    // 5'b1_1000=24
         min_set=0;  // 6'b11_1100=60
         sec_set=0;
        #1000; //February
            year_set=1996;  // 12'b1000_0011_0100=2100
            mon_set=2;  // 4'b1100=12
            week_set=6; // 3'b111=7
            day_set=28;  // 5'b1_1111=31
            hour_set=23;    // 5'b1_1000=24
            min_set=59;  // 6'b11_1100=60
            sec_set=0; 
       #1000; // February
         year_set=2000;  // 12'b1000_0011_0100=2100
         mon_set=2;  // 4'b1100=12
         week_set=1; // 3'b111=7
         day_set=28;  // 5'b1_1111=31
         hour_set=23;   // 5'b1_1000=24
         min_set=59;  // 6'b11_1100=60
         sec_set=0;

       #1000; //February
         year_set=2000;  // 12'b1000_0011_0100=2100
         mon_set=2;  // 4'b1100=12
         week_set=6; // 3'b111=7
         day_set=29;  // 5'b1_1111=31
         hour_set=23;   // 5'b1_1000=24
         min_set=59;  // 6'b11_1100=60
         sec_set=0;
        #1000; //February
          year_set=2004;  // 12'b1000_0011_0100=2100
          mon_set=2;  // 4'b1100=12
          week_set=6; // 3'b111=7
          day_set=28;  // 5'b1_1111=31
          hour_set=23;  // 5'b1_1000=24
          min_set=59;  // 6'b11_1100=60
          sec_set=0; 
         #1000; //February
           year_set=2100;  // 12'b1000_0011_0100=2100
           mon_set=2;  // 4'b1100=12
           week_set=6; // 3'b111=7
           day_set=28;  // 5'b1_1111=31
           hour_set=23; // 5'b1_1000=24
           min_set=59;  // 6'b11_1100=60
           sec_set=0;
         #1000; // February
           year_set=2015;  // 12'b1000_0011_0100=2100
           mon_set=2;  // 4'b1100=12
           week_set=6; // 3'b111=7
           day_set=28;  // 5'b1_1111=31
           hour_set=23; // 5'b1_1000=24
           min_set=59;  // 6'b11_1100=60
           sec_set=0;
       #1000; //March
         year_set=2015;  // 12'b1000_0011_0100=2100
         mon_set=3;  // 4'b1100=12
         week_set=7; // 3'b111=7
         day_set=29;  // 5'b1_1111=31
         hour_set=23;   // 5'b1_1000=24
         min_set=59;  // 6'b11_1100=60
         sec_set=0;
        #1000;  //March
          year_set=2015;  // 12'b1000_0011_0100=2100
          mon_set=3;  // 4'b1100=12
          week_set=1; // 3'b111=7
          day_set=30;  // 5'b1_1111=31
          hour_set=23;  // 5'b1_1000=24
          min_set=59;  // 6'b11_1100=60
          sec_set=0;
         #1000;  //April
           year_set=2015;  // 12'b1000_0011_0100=2100
           mon_set=4;  // 4'b1100=12
           week_set=4; // 3'b111=7
           day_set=30;  // 5'b1_1111=31
           hour_set=23; // 5'b1_1000=24
           min_set=59;  // 6'b11_1100=60
           sec_set=0; 
          #1000;  //May
            year_set=2015;  // 12'b1000_0011_0100=2100
            mon_set=5;  // 4'b1100=12
            week_set=2; // 3'b111=7
            day_set=30;  // 5'b1_1111=31
            hour_set=23;    // 5'b1_1000=24
            min_set=59;  // 6'b11_1100=60
            sec_set=0;
           #1000;  //june
             year_set=2015;  // 12'b1000_0011_0100=2100
             mon_set=6;  // 4'b1100=12
             week_set=2; // 3'b111=7
             day_set=30;  // 5'b1_1111=31
             hour_set=23;   // 5'b1_1000=24
             min_set=59;  // 6'b11_1100=60
             sec_set=0;
            #1000;  //july
              year_set=2015;  // 12'b1000_0011_0100=2100
              mon_set=7;  // 4'b1100=12
              week_set=4; // 3'b111=7
              day_set=30;  // 5'b1_1111=31
              hour_set=23;  // 5'b1_1000=24
              min_set=59;  // 6'b11_1100=60
              sec_set=0;  
           #1000;  //August
             year_set=2015;  // 12'b1000_0011_0100=2100
             mon_set=8;  // 4'b1100=12
             week_set=7; // 3'b111=7
             day_set=30;  // 5'b1_1111=31
             hour_set=23;   // 5'b1_1000=24
             min_set=59;  // 6'b11_1100=60
             sec_set=0;  
            #1000;  //september
              year_set=2015;  // 12'b1000_0011_0100=2100
              mon_set=9;  // 4'b1100=12
              week_set=7; // 3'b111=7
              day_set=30;  // 5'b1_1111=31
              hour_set=23;  // 5'b1_1000=24
              min_set=59;  // 6'b11_1100=60
              sec_set=0; 
            #1000;  //october
              year_set=2015;  // 12'b1000_0011_0100=2100
              mon_set=10;  // 4'b1100=12
              week_set=5; // 3'b111=7
              day_set=30;  // 5'b1_1111=31
              hour_set=21;  // 5'b1_1000=24
              min_set=59;  // 6'b11_1100=60
              sec_set=0; 
             #1000;  //november
               year_set=2015;  // 12'b1000_0011_0100=2100
               mon_set=11;  // 4'b1100=12
               week_set=1; // 3'b111=7
               day_set=30;  // 5'b1_1111=31
               hour_set=23; // 5'b1_1000=24
               min_set=59;  // 6'b11_1100=60
               sec_set=0;
              #1000;  //december
                year_set=2015;  // 12'b1000_0011_0100=2100
                mon_set=12;  // 4'b1100=12
                week_set=4; // 3'b111=7
                day_set=31;  // 5'b1_1111=31
                hour_set=23;    // 5'b1_1000=24
                min_set=59;  // 6'b11_1100=60
                sec_set=0; 
              #1000;  //december
                year_set=2199;  // 12'b1000_0011_0100=2100
                mon_set=12;  // 4'b1100=12
                week_set=6; // 3'b111=7
                day_set=31;  // 5'b1_1111=31
                hour_set=23;    // 5'b1_1000=24
                min_set=59;  // 6'b11_1100=60
                sec_set=0;        
       #1000;
       $stop;
    end
*/
 endmodule
