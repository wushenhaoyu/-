`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/28 15:32:30
// Design Name: 
// Module Name: shuma1
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
// T = 20ns
//////////////////////////////////////////////////////////////////////////////////


module Hex8(
    Clk,
    Reset_n,
    Disp_Data,
    SEL,
    SEG
    );
    input Reset_n;
    input Clk;
    input[31:0] Disp_Data;
    output reg [7:0] SEG;
    output reg [7:0] SEL;
    reg[29:0] cnt;
    reg[2:0] which;
    parameter CLOCK_FREQ = 50_000_000;
    parameter TURN_FREQ = 1000;
    parameter MCNT = CLOCK_FREQ / TURN_FREQ - 1;

    //1ms计数器
    always@(posedge Clk or negedge Reset_n)
    begin
        if (!Reset_n)
            cnt <= 0;
        else if (cnt == MCNT)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end

    //每1ms就切换数码管这个是输出二进制
    always@(posedge Clk or negedge Reset_n)
    begin
        if (!Reset_n)
            which <= 0;
        else if (cnt == MCNT)
            which <= which + 1;
    end

    //二进制转 三八译码器 选择数码管
    always@(posedge Clk or negedge Reset_n)
    begin
        if (!Reset_n)
            SEL = 8'b00000000;
        else
            begin
                case(which)
                    3'd0:SEL = 8'b00000001;
                    3'd1:SEL = 8'b00000010;
                    3'd2:SEL = 8'b00000100;
                    3'd3:SEL = 8'b00001000;
                    3'd4:SEL = 8'b00010000;
                    3'd5:SEL = 8'b00100000;
                    3'd6:SEL = 8'b01000000;
                    3'd7:SEL = 8'b10000000;
                endcase
            end
    end

    // 显示数码管查找表
    reg [3:0] data_temp;
    always@(posedge Clk)
    begin
        case(data_temp)
            0:SEG <= 8'b1100_0000;
            1:SEG <= 8'b1111_1001;
            2:SEG <= 8'b1010_0100;
            3:SEG <= 8'b1011_0000;
            4:SEG <= 8'b1001_1001;
            5:SEG <= 8'b1001_0010;
            6:SEG <= 8'b1000_0010;
            7:SEG <= 8'b1111_1000;
            8:SEG <= 8'b1000_0000;
            9:SEG <= 8'b1001_0000;
            10:SEG <= 8'b1000_1000;
            11:SEG <= 8'b1000_0011;
            12:SEG <= 8'b1100_0110;
            13:SEG <= 8'b1010_0001;
            14:SEG <= 8'b1000_0110;
            15:SEG <= 8'b1000_1110;
        endcase
    end

    always@(*)
        case (which)
            0: data_temp <= Disp_Data[3:0];
            1: data_temp <= Disp_Data[7:4];
            2: data_temp <= Disp_Data[11:8];
            3: data_temp <= Disp_Data[15:12];
            4: data_temp <= Disp_Data[19:16];
            5: data_temp <= Disp_Data[23:20];
            6: data_temp <= Disp_Data[27:24];
            7: data_temp <= Disp_Data[31:28];
        endcase
endmodule
