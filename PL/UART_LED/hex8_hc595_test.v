//基于HC595和HEX8的数码管显示器扫描测试

module hex8_hc595_test(
    Clk,
    Reset_n,
    Disp_Data,
    DIO,
    SRCLK,
    RCLK
    );
input Reset_n;
input Clk;
output  DIO;
output  SRCLK;
output  RCLK;
wire [7:0] SEG,SEL;
input [31:0] Disp_Data;

HC595_Driver HC595_Driver(
    .Reset_n(Reset_n),
    .Clk(Clk),
    .SEG(SEG),
    .SEL(SEL),
    .DIO(DIO),
    .SRCLK(SRCLK),
    .RCLK(RCLK)
);

Hex8 Hex8(
    .Clk(Clk),
    .Reset_n(Reset_n),
    .Disp_Data(Disp_Data),
    .SEL(SEL),
    .SEG(SEG)
);
endmodule