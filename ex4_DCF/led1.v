/*********************************************
*文件名：led.v
*功能：实现开发板上LED灯闪烁（闪烁频率为1s）
*平台： quartus ii 64bit
*连接：CLK -- 12
        RST_n -- 44
        LED0 -- 21
*********************************************/

module led1(
        CLOCK_50,RST_n,
        LED0
);


input CLOCK_50;
input RST_n;
output LED0;
reg LED0;
//************************************
//因为板子晶振为50M，0.5秒也就是要
//0.5*50*1000_000 = 25_000_000次计数
parameter half_sec = 25'd25_000_000;
//************************************

//************************************
reg [24:0]count;

always @(posedge CLOCK_50 or negedge RST_n) begin
	if(!RST_n) begin
		count <= 25'd0;
	end else if(count == half_sec) begin
		count <= 25'd0;
		LED0 <= ~LED0;
	end else begin
		count <= count + 1'b1;
	end
end

endmodule