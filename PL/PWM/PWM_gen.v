//////////////////////////////////////////////////////////////////////////////////
// Company: �人о·��Ƽ����޹�˾
// Engineer: www.corecourse.cn
// 
// Create Date: 2021/09/20 00:00:00
// Design Name: pwm_gen
// Module Name: pwm_gen
// Project Name: pwm_gen
// Target Devices: xc7z020clg400-2
// Tool Versions: Vivado 2018.3
// Description: PWM������ģ��
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module PWM_gen(
	clk,   
	reset_n,
	pwm_gen_en,
	counter_arr,
	counter_ccr,
	pwm_out
);
    wire reset;
	assign reset=~reset_n;
	input clk;	     //ϵͳʱ�����룬50M
	input reset_n;	   //��λ�ź����룬����Ч
	input  pwm_gen_en;	 //pwm����ʹ���ź�
	input [31:0]counter_arr; //����32λԤ��װֵ
	input [31:0]counter_ccr; //����32λ����Ƚ�ֵ
	output pwm_out;	   //pwm����ź�
    
	reg  pwm_out;
	reg [31:0]pwm_gen_cnt;   //����32λ����pwm�ļ�����

	always@(posedge clk or posedge reset)
	if(reset)
		pwm_gen_cnt <= 32'd1;
	else if(pwm_gen_en)
	begin
		if(pwm_gen_cnt <= 32'd1)
			pwm_gen_cnt <= counter_arr;       //��������1������Ԥ��װ�Ĵ���ֵ
		else
			pwm_gen_cnt <= pwm_gen_cnt - 1'b1;//�������Լ�1
	end
	else
		pwm_gen_cnt <= counter_arr;	        //δʹ��ʱ��������ֵ����Ԥ��װ�Ĵ���ֵ

	always@(posedge clk or posedge reset)
	if(reset)                          //��λʱ��PWM����͵�ƽ
		pwm_out <= 1'b0;
	else if(pwm_gen_cnt <= counter_ccr)   //����ֵС�ڱȽ�ֵ��PWM����ߵ�ƽ
		pwm_out <= 1'b1;
	else
		pwm_out <= 1'b0;                    //����ֵ���ڱȽ�ֵ��PWM����͵�ƽ
		
endmodule