module simple_counter(
    CLOCK,
    counter_out,
);
input CLOCK;
output [31:0] counter_out;   //This is the 4-bit counter
reg [31:0] counter_out;

always @(posedge CLOCK) begin   // on positive clock edge
    counter_out <= counter_out + 1;     //increment counter
    
end
endmodule // simple_counter