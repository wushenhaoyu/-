module uart_loopback(
    Clk,
    Rst_n,
    uart_rx,
    data,
    uart_tx
 );
 
    parameter DATA_WIDTH = 8; //8bit once you can 32bit once like
	parameter MSB_FIRST = 0;
	
    input Clk;
    input Rst_n;
    input uart_rx;
    input [7:0] data;
    output uart_tx;
    
    wire [DATA_WIDTH-1:0]rx_data;
    wire Rx_Done;
    wire [7:0]data_byte;


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
      
        .data(data),
        .send_en(Rx_Done),   
        .Baud_Set(3'd4),  
        
        .uart_tx(uart_tx),  
        .Tx_Done(),   
        .uart_state()
    );
    
endmodule
