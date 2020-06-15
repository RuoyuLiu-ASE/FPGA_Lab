`timescale 10ns/1ns

module tb_clock();

reg clk_10mhz;
reg clk_1hz;
reg reset;
reg setFixTime;
reg [43:0] time_in;
wire [43:0] time_out;

reg [33:0] cnt;// For generate 1Hz clock

initial begin
    clk_10mhz = 1'b0;
    clk_1hz = 1'b0;
    cnt = 34'b0;
    reset = 1'b1;
    #10 reset = 1'b0;
    #20 reset = 1'b1;
    setFixTime = 1'b1;
    time_in [3:0] = 4'b0101;   // lower digit of second is 5
    time_in [6:4] = 3'b100;    // higher digit of second is 4
    time_in [10:7] = 4'b1001;   // lower digit of minute is 9
    time_in [13:11] = 3'b101;    // higher digit of minute is 5
    time_in [17:14] = 4'b0011;   // lower digit of hour is 3
    time_in [19:18] = 2'b10;     // higher digit of hour is 2
    time_in [23:20] = 4'b0001;   // lower digit of day is 1
    time_in [25:24] = 2'b11;     // higher digit of day is 3
    time_in [29:26] = 4'b0111;   // lower digit of month is 7
    time_in [30]    = 1'b0;      // higher digit of month is 0
    time_in [34:31] = 4'b1001;   // lower digit of year is 9
    time_in [38:35] = 4'b0001;   // higher digit of year is 1
    time_in [41:39] = 3'b010;    // weekday is Tuesday
    time_in [43:42] = 2'b00;     // timezone is 0
end

always begin
   #5 clk_10mhz = ~clk_10mhz;
   if (!clk_10mhz) begin
       if(cnt == 34'd10000_000 || reset == 1'b0)begin
           cnt = 0;
       end else begin
           cnt = cnt + 1;
       end
   end
   clk_1hz = (cnt > 34'd50000_00)?1'b1:1'b0;
end

//always begin
//   //#500000000 clk_1hz = ~clk_1hz;
//   #500000 clk_1hz = ~clk_1hz;
//end

timeAndDateClock clock(.clk(clk_10mhz),.clkEn1Hz(clk_1hz),.nReset(reset),.setTimeAndDate_in(setFixTime),.timeAndDate_In(time_in),.timeAndDate_Out(time_out));


endmodule // tb_clock