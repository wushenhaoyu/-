module uart_loopback(
    Clk,
    Rst_n,
    uart_rx,
    uart_tx,
    DIO,
    SRCLK,
    RCLK
 );
 
    parameter DATA_WIDTH = 32; //8bit once you can 32bit once like
	parameter MSB_FIRST = 0; 
	
    input Clk;
    input Rst_n;
    input uart_rx;
    output uart_tx;
    wire [DATA_WIDTH-1:0]rx_data_r;
    wire [DATA_WIDTH-1:0]rx_data;
    wire Rx_Done;
    wire [7:0]data_byte;

    output  DIO;
    output  SRCLK;
    output  RCLK;
    genvar i;
    generate
        for (i = ((DATA_WIDTH / 8) - 1); i>=0; i= i -1) begin
            assign rx_data_r[((i+1)*8 - 1):i*8] = rx_data[((DATA_WIDTH / 8  - i)*8 -1):((DATA_WIDTH / 8  - i - 1)*8)];
        end
    endgenerate
    uart_data_rx 
    #(
		.DATA_WIDTH(DATA_WIDTH),
		.MSB_FIRST(MSB_FIRST)		
	)
	uart_data_rx(
        .Clk(Clk),
        .Rst_n(Rst_n),
        .uart_rx(uart_rx),
        
        .data(rx_data),
        .Rx_Done(Rx_Done),
        .timeout_flag(),
        
        .Baud_Set(3'd4)
     );

    uart_data_tx 
    #(
		.DATA_WIDTH(DATA_WIDTH),
		.MSB_FIRST(MSB_FIRST)
	)uart_data_tx(
        .Clk(Clk),
        .Rst_n(Rst_n),
      
        .data(rx_data),
        .send_en(Rx_Done),   
        .Baud_Set(3'd4),  
        
        .uart_tx(uart_tx),  
        .Tx_Done(),   
        .uart_state()
    );

    hex8_hc595_test hex8_hc595_test(
        .Clk(Clk),
        .Reset_n(Rst_n),
        .Disp_Data(rx_data_r),
        .DIO(DIO),
        .SRCLK(SRCLK),
        .RCLK(RCLK)
    );
    
    
endmodule
