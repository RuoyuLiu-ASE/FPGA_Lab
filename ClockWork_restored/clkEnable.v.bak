// created 17.07.2018 by Cecilia Hoeffler
// template for experiment 2
//you should be able to reduce the frequency of the clock with this module


module clkEnable(
			clock_5,
			reset,
			enable_out
			);
							
	input clock_5;
	input reset;
	output enable_out;
	
	
	reg[23:0] count;
	parameter freq_divider = 10_000_000; //The frequency of enable_out is 5Hz. So the light will blink at 0.2s period.
	reg enable_out;
always @(posedge clock_5) begin
	if (!reset) begin
		count <=24'b00000000000000000000000000000000;
		enable_out <= 1'b0;
	end else begin	
		//count <= count+1;
		if (count == freq_divider-1) begin
			count <= 24'b00000000000000000000000000000000;
			enable_out <= 1'b1;
		end else begin
			count <= count+1;
			enable_out <= 1'b0;
		end
	end
end						
endmodule