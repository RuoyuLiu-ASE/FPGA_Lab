/*********************************************
*文件名：led.v
*功能：实现开发板上LED灯闪烁（闪烁频率为1s）
*平台： quartus ii 64bit
*连接：CLK -- 12
        RST_n -- 44
        LED0 -- 21
*********************************************/

module led(
        enable,RST_n,
        LED0
);


input enable;
input RST_n;
output LED0;
reg LED0;
//************************************
//因为板子晶振为50M，0.5秒也就是要
//0.5*50*1000_000 = 25_000_000次计数
//parameter half_sec = 25'd25_000_000;
//************************************

//************************************
//reg [24:0]count;

always @(enable or RST_n) begin
	if(!RST_n) begin
		LED0 <= 1'b0;
	end else if (enable) begin
		LED0 <= 1'b1;
	end else if (!enable) begin
		LED0 <= 1'b0;
	end	
end


endmodule