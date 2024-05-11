`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/28 18:28:20
// Design Name: 
// Module Name: list
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module HC595_Driver(
    Clk,
    Reset_n,
    SEG,
    SEL,
    DIO,
    SRCLK,
    RCLK
    );
input Reset_n;
input Clk;
input [7:0] SEG;
input [7:0] SEL;
output reg DIO;
output reg SRCLK;
output reg RCLK;
reg[29:0] cnt;
parameter CLOCK_FREQ = 50_000_000;
parameter SRCLK_FREQ = 12_500_000;//SRCLK频率选择12.5MHz 40ns 
parameter MCNT = CLOCK_FREQ / (2 * SRCLK_FREQ)  - 1; //
always @(posedge Clk or negedge Reset_n) begin
    if (!Reset_n) begin
        cnt <= 0;
    end else begin
        if (cnt == MCNT) 
        cnt <= 0;
        else
        cnt <= cnt + 1;
    end
end  

reg[4:0] R_cnt; 
always@(posedge Clk or negedge Reset_n)
    if (!Reset_n) 
        R_cnt <= 0;
    else 
        if (cnt == MCNT) 
            R_cnt <= R_cnt + 1;

always@(posedge Clk or negedge Reset_n)//传16位一存储
    if (!Reset_n) begin
        DIO <= 0;
        SRCLK <= 0;
        RCLK<=0;
    end
    else begin
        case (R_cnt)
            0:begin DIO <= SEG[7]; SRCLK <= 0;RCLK<=1;end//锁存器存储
            1:begin SRCLK <= 1;RCLK<=0; end               //锁存器结束读取
            2:begin DIO <= SEG[6]; SRCLK <= 0;end
            3:SRCLK <= 1;
            4:begin DIO <= SEG[5]; SRCLK <= 0;end
            5:SRCLK <= 1;
            6:begin DIO <= SEG[4]; SRCLK <= 0;end
            7:SRCLK <= 1;
            8:begin DIO <= SEG[3]; SRCLK <= 0;end
            9:SRCLK <= 1;
            10:begin DIO <= SEG[2]; SRCLK <= 0;end
            11:SRCLK <= 1;
            12:begin DIO <= SEG[1]; SRCLK <= 0;end
            13:SRCLK <= 1;
            14:begin DIO <= SEG[0]; SRCLK <= 0;end
            15:SRCLK <= 1;
            16:begin DIO <= SEL[7]; SRCLK <= 0;end
            17:SRCLK <= 1;
            18:begin DIO <= SEL[6]; SRCLK <= 0;end
            19:SRCLK <= 1;
            20:begin DIO <= SEL[5]; SRCLK <= 0;end
            21:SRCLK <= 1;
            22:begin DIO <= SEL[4]; SRCLK <= 0;end
            23:SRCLK <= 1;
            24:begin DIO <= SEL[3]; SRCLK <= 0;end
            25:SRCLK <= 1;
            26:begin DIO <= SEL[2]; SRCLK <= 0;end
            27:SRCLK <= 1;
            28:begin DIO <= SEL[1]; SRCLK <= 0;end
            29:SRCLK <= 1;
            30:begin DIO <= SEL[0]; SRCLK <= 0;end
            31:SRCLK <= 1;
        endcase
    end



endmodule
