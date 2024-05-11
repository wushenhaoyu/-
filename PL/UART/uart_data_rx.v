/*���ߣ�С÷�� �人о·��Ƽ����޹�˾*/
/*=====================================
��ģ��ʵ��1~16�ֽڣ�8~256��λ���ݵĽ��ա�ʵ�ֽ�����ֽڵ����ݽ��ղ�ƴ��Ϊָ����λ�����ݺ������
�������������λ������������ģ��ʱʹ��DATA_WIDTH���޸ģ���ҪӦ�ó���Ϊ����λ����8λ���ݣ�ϣ
��ͨ�����ڷ��ͳ�ȥ�ĳ���������12λADC�������ͨ�����ڷ��͡�
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

module uart_data_rx(
	Clk,
	Rst_n,
  	uart_rx,
	
	data,
	Rx_Done,
	timeout_flag,
	
	Baud_Set
);
	
	parameter DATA_WIDTH = 16;
	parameter MSB_FIRST = 1;

	input Clk;
	input Rst_n;
	input uart_rx;
	
	output reg [DATA_WIDTH - 1 : 0]data;
	input [2:0]Baud_Set;

	output reg Rx_Done;
	output reg timeout_flag;
	
	reg [DATA_WIDTH - 1 : 0]data_r;

	wire [7:0] data_byte;
	wire byte_rx_done;
	wire [19:0] TIMEOUT;
	
	uart_byte_rx uart_byte_rx(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.baud_set(Baud_Set),
		.uart_rx(uart_rx),
		.data_byte(data_byte),
		.Rx_Done(byte_rx_done)
	);
	
	//���ݲ������Զ����ó�ʱʱ��
    assign TIMEOUT = (Baud_Set == 3'd0) ? 20'd182291:
                     (Baud_Set == 3'd1) ? 20'd91145:
                     (Baud_Set == 3'd2) ? 20'd45572:
                     (Baud_Set == 3'd3) ? 20'd30381:
                                          20'd15190;
	
	reg [8:0]cnt;
	reg [1:0]state;
	
	localparam S0 = 0;	//�ȴ����ֽڽ�������ź�
	localparam S1 = 1;	//�жϽ����Ƿ�ʱ
	localparam S2 = 2;	//������������Ƿ�������

	reg [31:0]timeout_cnt;
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		timeout_flag <= 1'd0;
    else if(timeout_cnt >= TIMEOUT)
		timeout_flag <= 1'd1;
	else if(state == S0)
	    timeout_flag <= 1'd0;
		
	reg to_state;
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
	   	to_state <= 0;
	else if(!uart_rx)
	   to_state <= 1;
    else if(byte_rx_done)
        to_state <= 0; 
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		timeout_cnt <= 32'd0;
	else if(to_state)begin
        if(byte_rx_done)
            timeout_cnt <= 32'd0;
        else if(timeout_cnt >= TIMEOUT)
            timeout_cnt <= TIMEOUT;
        else
            timeout_cnt <= timeout_cnt + 1'd1;
    end
    
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)begin
		data_r <= 0;
		state <= S0;
		cnt <= 0;
		data <= 0;
	end
	else begin
		case(state)
			S0: 
				begin
					Rx_Done <= 0;
					data_r <= 0;
					if(DATA_WIDTH == 8)begin
						data <= data_byte;
						Rx_Done <= byte_rx_done;
					end
					else if(byte_rx_done)begin
						state <= S1;
						cnt <= cnt + 9'd8;
						if(MSB_FIRST == 1)
							data_r <= {data_r[DATA_WIDTH - 1 - 8 : 0], data_byte};
						else
							data_r <= {data_byte, data_r[DATA_WIDTH - 1 : 8]};
					end
				end
			
			S1:
				if(timeout_flag)begin
					state <= S0;
					Rx_Done <= 1;	
				end
				else if(byte_rx_done)begin
					state <= S2;
					cnt <= cnt + 9'd8;
					if(MSB_FIRST == 1)
						data_r <= {data_r[DATA_WIDTH - 1 - 8 : 0], data_byte};
					else
						data_r <= {data_byte, data_r[DATA_WIDTH - 1 : 8]};
				end
				
			S2:
				if(cnt >= DATA_WIDTH)begin
					state <= S0;
					cnt <= 0;
					data <= data_r;
					Rx_Done <= 1;
				end
				else begin
					state <= S1;
					Rx_Done <= 0;
				end
			default:state <= S0;
		endcase	
	end

endmodule
