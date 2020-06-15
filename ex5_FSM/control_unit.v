module control_unit(clk, clk_en, nReset, DCF_Enable_in, SET_in, STATE_out, DCF_timeAndDate_in,
                     DCF_set_in, SetClock_timeAndDate_in, SetClock_state_in, clock_timeAndDate_In,
                     LCD_timeAndDate_Out, clock_timeAndDate_Out, clock_set_out);

   input          clk;
   input          clk_en;
   input          nReset;
   input          DCF_Enable_in;
   input          SET_in;
   output  [5:0]  STATE_out;
   // -------DATA FROM DCF DECODER
   input  [43:0]  DCF_timeAndDate_in;
   input          DCF_set_in;
   // -------DATA FROM SET CLOCK
   input  [43:0]  SetClock_timeAndDate_in;
   input   [3:0]  SetClock_state_in;
   // -------DATA FROM CLOCK
   input  [43:0]  clock_timeAndDate_In;
   // -------DATA OUTPUT LCD-Matrix-Display
   output [43:0]  LCD_timeAndDate_Out;
   // -------DATA TO CLOCK
   output [43:0]  clock_timeAndDate_Out;
   output         clock_set_out;

   reg        clock_set_out;
   reg [5:0]  STATE_out;
   reg [43:0] LCD_timeAndDate_Out;
   reg [43:0] clock_timeAndDate_Out;

//   reg        clock_set_out_reg;
//   reg [5:0]  STATE_out_reg;
//   reg [43:0] LCD_timeAndDate_Out_reg;
//   reg [43:0] clock_timeAndDate_Out_reg;
//	
//   assign clock_set_out = clock_set_out_reg;
//   assign STATE_out = STATE_out_reg;
//   assign LCD_timeAndDate_Out = LCD_timeAndDate_Out_reg;
//   assign clock_timeAndDate_Out = clock_timeAndDate_Out_reg;
      
   // ---------- YOUR CODE HERE ---------- 

reg [1:0] state,nextstate;


parameter select_Clock = 2'b01;   // select_Clock state code = 1
parameter select_dcf77 = 2'b11;   // select_dcf77 state code = 3
parameter set_Clock = 2'b10;      // set_Clock state code = 2

//------------- For every clk_en positive edge, the change of memory element ---------------
always @(posedge clk_en or negedge nReset) begin
   if (!nReset) begin
      state <= select_Clock;  // default is the select clock state which means display the clockWork
   end else begin
      state <= nextstate;
   end
end
	  
//------------- Combinationary logic for the next state ---------------
always @(state or DCF_Enable_in or SET_in or SetClock_state_in) begin
   case (state)
      select_Clock: begin
         if (DCF_Enable_in) begin
            nextstate = select_dcf77;
         end else if (SET_in == 1'b0 && DCF_Enable_in == 1'b0) begin
            nextstate = set_Clock;
         end else begin
            nextstate = select_Clock;  
         end
		end
      select_dcf77: begin
         if (DCF_Enable_in == 1'b0) begin
            nextstate = select_Clock;
         end else begin
            nextstate = select_dcf77;
         end
		end
      set_Clock: begin
         if (DCF_Enable_in) begin
            nextstate = select_dcf77;
         end else if (SetClock_state_in == 4'd14) begin
            nextstate = select_Clock;
         end else begin
            nextstate = set_Clock;
         end
		end
      default: nextstate = 2'b00; 
   endcase     
end

//------------- Combinationary logic for generating the output ---------------
always @(*) begin
   case (state)
      select_Clock: begin
         STATE_out = 6'b000000;
         LCD_timeAndDate_Out = clock_timeAndDate_In;
         clock_timeAndDate_Out = SetClock_timeAndDate_in;
         clock_set_out = 1'b0;
		end
      select_dcf77: begin
         STATE_out = 6'b110000;
         LCD_timeAndDate_Out =  clock_timeAndDate_In;
         clock_timeAndDate_Out = DCF_timeAndDate_in;
         clock_set_out = DCF_set_in;
		end
      set_Clock: begin
         STATE_out = {2'b10, SetClock_state_in};
         LCD_timeAndDate_Out = SetClock_timeAndDate_in;
         clock_timeAndDate_Out = SetClock_timeAndDate_in;
         clock_set_out = ((SetClock_state_in == 4'd14 || SetClock_state_in == 4'd13))?1'b1:1'b0;
		end
      default: begin
         STATE_out = 6'b111111;
         LCD_timeAndDate_Out = 44'b0;
         clock_timeAndDate_Out = 44'b0;
         clock_set_out = 1'b0;
      end
   endcase
   
end



endmodule