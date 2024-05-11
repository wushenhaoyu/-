//////////////////////////////////////////////////////////////////////////////////
// Company: �人о·��Ƽ����޹�˾
// Engineer: С÷���Ŷ�
// Web: www.corecourse.cn
// 
// Create Date: 2020/07/20 00:00:00
// Design Name: uart_tx
// Module Name: uart_byte_tx
// Project Name: uart_tx
// Target Devices: XC7A35T-2FGG484I
// Tool Versions: Vivado 2018.3
// Description: ���ڷ���ģ��
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_byte_tx(
	Clk,
	Rst_n,
  
	data_byte,
	send_en,   
	Baud_Set,  
	
	uart_tx,  
	Tx_Done,   
	uart_state 
);

	input Clk ;    //ģ��ȫ��ʱ�����룬50M
	input Rst_n;    //��λ�ź����룬����Ч
	input [7:0]data_byte;  //������8bit����
	input send_en;    //����ʹ��
	input [2:0]Baud_Set;   //����������
	
	output reg uart_tx;    //��������ź�
	output reg Tx_Done;    //1byte���ݷ�����ɱ�־
	output reg uart_state; //��������״̬

	localparam START_BIT = 1'b0;
	localparam STOP_BIT = 1'b1; 
	
	reg bps_clk;	     //������ʱ��	
	reg [15:0]div_cnt;      //��Ƶ������	
	reg [15:0]bps_DR;       //��Ƶ�������ֵ	
	reg [3:0]bps_cnt;      //������ʱ�Ӽ�����	
	reg [7:0]data_byte_reg;//data_byte�Ĵ������
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		uart_state <= 1'b0;
	else if(send_en)
		uart_state <= 1'b1;
	else if(bps_cnt == 4'd11)
		uart_state <= 1'b0;
	else
		uart_state <= uart_state;
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		data_byte_reg <= 8'd0;
	else if(send_en)
		data_byte_reg <= data_byte;
	else
		data_byte_reg <= data_byte_reg;
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		bps_DR <= 16'd5207;
	else begin
		case(Baud_Set)
			0:bps_DR <= 16'd5207;
			1:bps_DR <= 16'd2603;
			2:bps_DR <= 16'd1301;
			3:bps_DR <= 16'd867;
			4:bps_DR <= 16'd433;
			default:bps_DR <= 16'd5207;			
		endcase
	end	
	
	//counter
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		div_cnt <= 16'd0;
	else if(uart_state)begin
		if(div_cnt == bps_DR)
			div_cnt <= 16'd0;
		else
			div_cnt <= div_cnt + 1'b1;
	end
	else
		div_cnt <= 16'd0;
	
	// bps_clk gen
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		bps_clk <= 1'b0;
	else if(div_cnt == 16'd1)
		bps_clk <= 1'b1;
	else
		bps_clk <= 1'b0;
	
	//bps counter
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)	
		bps_cnt <= 4'd0;
	else if(bps_cnt == 4'd11)
		bps_cnt <= 4'd0;
	else if(bps_clk)
		bps_cnt <= bps_cnt + 1'b1;
	else
		bps_cnt <= bps_cnt;
		
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		Tx_Done <= 1'b0;
	else if(bps_cnt == 4'd11)
		Tx_Done <= 1'b1;
	else
		Tx_Done <= 1'b0;
		
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		uart_tx <= 1'b1;
	else begin
		case(bps_cnt)
			0:uart_tx <= 1'b1;
			1:uart_tx <= START_BIT;
			2:uart_tx <= data_byte_reg[0];
			3:uart_tx <= data_byte_reg[1];
			4:uart_tx <= data_byte_reg[2];
			5:uart_tx <= data_byte_reg[3];
			6:uart_tx <= data_byte_reg[4];
			7:uart_tx <= data_byte_reg[5];
			8:uart_tx <= data_byte_reg[6];
			9:uart_tx <= data_byte_reg[7];
			10:uart_tx <= STOP_BIT;
			default:uart_tx <= 1'b1;
		endcase
	end	

endmodule