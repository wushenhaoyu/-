/*���ߣ�С÷�� �人о·��Ƽ����޹�˾*/
/*=====================================
��ģ��ʵ��1~16�ֽڣ�8~256��λ���ݵķ��͡���Ҫ���͵�����λ������������ģ��ʱʹ��DATA_WIDTH���޸�
��ҪӦ�ó���Ϊ����λ����8λ���ݣ�ϣ��ͨ�����ڷ��ͳ�ȥ�ĳ���������12λADC�������ͨ�����ڷ��͡�

Ҫ��DATA_WIDTH��ֵΪ8��������������󲻳���256������ʵ������λ��ﲻ��8�����������������Ҫ������
��λ��0���Եõ�8������λ�������֮���ٷ��ͣ��������12λADC�������wire [11:0]ADC_DATA;ʹ��ʱ����
��������д��
assign data = {4'd0,ADC_DATA},
����dataλ��Ϊ16�����ӵ�uart_data_tx��data�˿�����Ϊ����������

**/

/*
����ģ��
---------------------------------------
uart_data_tx
#(
	.DATA_WIDTH(DATA_WIDTH),
	.MSB_FIRST(MSB_FIRST)
)
uart_data_tx(
	.Clk(Clk),
	.Rst_n(Rst_n),
	.data(data),
	.send_en(send_en),   
	.Baud_Set(3'd4),  
	.uart_tx(uart_tx),  
	.Tx_Done(Tx_Done),   
	.uart_state(uart_state)
);
---------------------------------------
����ʱ
1��ͨ���޸�DATA_WIDTH��ֵ��ָ��ÿ�η��͵�����λ��
2��ͨ���޸�MSB_FIRST��ֵ��ȷ���ȷ����ֽڻ����ȷ����ֽڡ�Ϊ1���ȷ����ֽڣ�Ϊ0���ȷ����ֽ�
3��send_enΪ���崥���źţ�����ʱ�ṩһ��ʱ�����ڵĸ����弴�ɴ���һ�δ���
4��Baud_SetΪ����������ֵ��0��9600����1��19200����2��38400����3��57600����4��115200��
5��ÿ�δ�����ɣ�ָ��λ������ݴ�����ɣ���TX-Done����һ��ʱ�����ڵĸ�����
======================================*/


module uart_data_tx(
	Clk,
	Rst_n,
  
	data,
	send_en,   
	Baud_Set,  
	
	uart_tx,  
	Tx_Done,   
	uart_state
);
	
	parameter DATA_WIDTH = 8;
	parameter MSB_FIRST = 1;

	input Clk;
	input Rst_n;
	
	input [DATA_WIDTH - 1 : 0]data;
	input send_en;
	input [2:0]Baud_Set;
	output uart_tx;
	output reg Tx_Done;
	output uart_state;
	
	reg [DATA_WIDTH - 1 : 0]data_r;

	reg [7:0] data_byte;
	reg byte_send_en;
	wire byte_tx_done;
	
	uart_byte_tx uart_byte_tx(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.data_byte(data_byte),
		.send_en(byte_send_en),   
		.Baud_Set(Baud_Set),  
		.uart_tx(uart_tx),  
		.Tx_Done(byte_tx_done),   
		.uart_state(uart_state) 
	);
	
	reg [8:0]cnt;
	reg [1:0]state;
	
	localparam S0 = 0;	//�ȴ���������
	localparam S1 = 1;	//�����ֽ����ݷ���
	localparam S2 = 2;	//�ȴ����ֽ����ݷ������
	localparam S3 = 3;	//������������Ƿ������
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)begin
		data_byte <= 0;
		byte_send_en <= 0;
		state <= S0;
		cnt <= 0;
	end
	else begin
		case(state)
			S0: 
				begin
					data_byte <= 0;
					cnt <= 0;
					Tx_Done <= 0;
					if(send_en)begin
						state <= S1;
						data_r <= data;
					end
					else begin
						state <= S0;
						data_r <= data_r;
					end
				end
			
			S1:
				begin
					byte_send_en <= 1;
					if(MSB_FIRST == 1)begin
						data_byte <= data_r[DATA_WIDTH-1:DATA_WIDTH - 8];
						data_r <= data_r << 8;
					end
					else begin
						data_byte <= data_r[7:0];
						data_r <= data_r >> 8;					
					end
					state <= S2;
				end
				
			S2:
				begin
					byte_send_en <= 0;
					if(byte_tx_done)begin
						state <= S3;
						cnt <= cnt + 9'd8;
					end
					else
						state <= S2;
				end
			
			S3:
				if(cnt >= DATA_WIDTH)begin
					state <= S0;
					cnt <= 0;
					Tx_Done <= 1;
				end
				else begin
					state <= S1;
					Tx_Done <= 0;
				end
			default:state <= S0;
		endcase	
	end

endmodule
