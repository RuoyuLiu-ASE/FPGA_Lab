// created 17.07.2018 by Cecilia Hoeffler
// template for experiment 2
//Up-Down- Counter, you should be able to control the LEDs via the key[0] and key[1]

module updown_counter(
up_down, // if up_down is ‘1’ then it counts up , else if ‘0’ it counts down

clk,

enable,
reset,

count_out

);
input up_down; // if up_down is ‘1’ then it counts up , else if ‘0’ it counts down

input clk,enable,reset;

output [7:0]count_out;
reg [7:0]count_out;

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        if(!up_down)begin
            count_out <= 8'b11111111;
        end else begin
            count_out <= 8'b00000000;
        end
    end else begin
        if(up_down) begin        // counts up until 2^8 = 256
            if(enable == 1) begin
                if (count_out < 256) begin
                    count_out <= count_out+1;
                end else begin
                    count_out <= 8'b00000000;
                end
            end
        end
           else begin          //counts down from 256
                if(enable == 1) begin
                    if (count_out == 0) begin   // When it is 0, start from 256 again
                        count_out <= 8'b11111111;
                    end else begin
                        count_out <= count_out-1;    // count down. subtract 1.
                    end
                end
            end
        end
end
endmodule
