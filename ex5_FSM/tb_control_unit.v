`timescale 10ns/10ns

module tb_control_unit();


//input
reg clk, clk_1hz, nReset, DCF_Enable_in, SET_in;

reg DCF_set_in;
reg [43:0] time_in;

reg [3:0] SetClock_state_in;

reg [24:0] cnt;// For generate 1Hz clock

//output
wire clock_set_out;
wire [5:0] STATE_out;
wire [43:0] LCD_timeAndDate_Out;
wire [43:0] clock_timeAndDate_Out;


 // initial blocks are sequential and start at time 
initial begin
  DCF_Enable_in = 1'b0;
  SET_in = 1'b0;
  SetClock_state_in = 4'b0;
  nReset = 1'b1;
  DCF_set_in = 1'b1;
  clk = 0;
  #10 nReset = 1'b0;
  #30 nReset = 1'b1;

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
  time_in [43:42] = 2'b00;     // timezone is 

  #5000_000 SetClock_state_in = 4'd14;
end

 //----------------------------------------------------------
 // create a clock (f=10Mhz in sim time)
 // period is 100ns
 always begin
   #5 clk = ~clk; 
   if (clk) begin
       if(cnt == 25'd100_000 || nReset == 1'b0)begin   // When the timestep is 10ns, cnt = 10000_000, will generate 1hz
           cnt = 0;
       end else begin
           cnt = cnt + 1;
       end
   end
   clk_1hz = (cnt > 25'd50000)?1'b1:1'b0;       // This is related to cnt = 10000_00
end
 //-----------------------------------------------------------
 // generate different input randomly

 always @(posedge clk_1hz) begin
     #10 DCF_Enable_in = {$random}%2;
     #10 SET_in = {$random}%2;
     #(3*50+12);
 end

 //instance
 control_unit DUT(.clk(clk), .clk_en(clk_1hz), .nReset(nReset), .DCF_Enable_in(DCF_Enable_in), .SET_in(SET_in), .STATE_out(STATE_out),
  .DCF_timeAndDate_in(time_in), .DCF_set_in(DCF_set_in), .SetClock_timeAndDate_in(time_in), .SetClock_state_in(SetClock_state_in), 
  .clock_timeAndDate_In(time_in), .LCD_timeAndDate_Out(LCD_timeAndDate_Out), .clock_timeAndDate_Out(clock_timeAndDate_Out), .clock_set_out(clock_set_out));


endmodule // tb_control_unit




