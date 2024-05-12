`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/01 11:22:03
// Design Name: 
// Module Name: button
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


module button(
    Key,
    Clk,
    Reset_n,
    Key_State,
    Key_P_Flag, //案件按下标志信号
    Key_R_Flag//案件抬起标志信号
    );
input Key;
input Clk;
input Reset_n;
output reg Key_P_Flag;
output reg Key_R_Flag;
output reg Key_State;

localparam IDLE = 0;
localparam P_FITER = 1;
localparam WAIT_R = 2;
localparam R_FITER = 3;

parameter MCNT = 1000_000 - 1;
reg [31:0] cnt;

reg [1:0] state;


reg sync_d0_Key;
reg sync_d1_Key;
reg r_Key;

always@(posedge Clk)
    sync_d0_Key <= Key;

always@(posedge Clk)
    sync_d1_Key <= sync_d0_Key;

always@(posedge Clk)
    r_Key <= sync_d1_Key;

wire pedge_key;
wire negedge_key;
wire time_20ms_reached;

assign time_20ms_reached = (cnt == MCNT);
assign negedge_key = (sync_d1_Key == 0) && (r_Key == 1); //下降�??
assign pedge_key = (sync_d1_Key == 1) && (r_Key == 0); //上升�??

always@(posedge Clk or negedge Reset_n)
if (!Reset_n)
    cnt <= 0;
else if ((state == P_FITER ) || (state == R_FITER))
    cnt <= cnt + 1'd1;
else
    cnt <= 0;



always@(posedge Clk or negedge Reset_n)
if (!Reset_n)
begin
    state <= IDLE;
    Key_P_Flag <= 1'd0;
    Key_R_Flag <= 1'd0;
    Key_State <= 1'd1;
end
else
    begin
        case (state)
            IDLE:
                begin
                    Key_R_Flag <= 1'd0;
                if(negedge_key)
                    state <= P_FITER;
                end
            P_FITER:
            begin
                if(time_20ms_reached)
                begin
                    Key_P_Flag <= 1'd1;
                    state <= WAIT_R;
                    Key_State <= 1'd0;
                end
                    
                else if (pedge_key)
                    state <= IDLE;
                else
                    state <= state;
            end
            WAIT_R:
                begin
                Key_P_Flag <= 1'd0;
                if(pedge_key)
                    state <= R_FITER;
                end
            R_FITER:
                begin
                if(time_20ms_reached)
                begin
                    state <= IDLE;
                    Key_R_Flag <= 1'd1;
                    Key_State <= 1'd1;
                end
                else if (negedge_key)
                    state <= WAIT_R;
                else
                    state <= state;
                end
        endcase
    end


endmodule
