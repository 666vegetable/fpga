module Top_Frequency( 
	input	   		clk,
    output			wire [7:0] sm_seg,
    output			wire [3:0] sm_bit,
     //cymometer interface
    input        	clk_fx   ,    // 被测时钟
    output   		uart_txd ,
    output          clk_24MHZ,
    output          clk_200MHZ
);

//parameter define
parameter    	CLK_FS_24MHZ 	= 26'd24_000_000	;  	// 基准时钟频率值
parameter    	CLK_FS_200MHZ 	= 28'd200_000_000	;  	// 基准时钟频率值

parameter  		UART_BPS 		= 460800			;  	//定义串口波特率
parameter		UART_FRE 		= 18'd200_000		;   
//wire define   
wire [25:0]     data_fx		;         					// 被测信号测量值
wire 			rst_n_w		;

wire 			extlock		;

//reg define
wire  [87:0]	data_uart	;
wire			txd_fre_clk ;
wire  [14:0]	data_k;

data_deal u_data_deal(
	.clk			(clk_200MHZ),
	.rst_n			(rst_n_w),
	.data_fx		(data_fx),
	.txd_fre_clk	(txd_fre_clk),	
	.data_uart		(data_uart),
	.data_k			(data_k)
	);

rst_n ux_rst
(
	.clk	(clk	),
	.rst_n	(rst_n_w)
);	

pll_clk u_pll_clk(
		.refclk		(clk),	
		.reset		(!rst_n_w),
		.extlock	(extlock),
		.clk0_out	(clk_24MHZ),
		.clk1_out	(clk_200MHZ)
		);

//例化等精度频率计模块
cymometer #(.CLK_FS(CLK_FS_200MHZ)          // 基准时钟频率值
) u_cymometer(
    //system clock
    .clk_fs      (clk_200MHZ),       // 基准时钟信号
    .rst_n       (rst_n_w),          // 复位信号
    //cymometer interface
    .clk_fx      (clk_fx   ),        // 被测时钟信号
    .data_fx     (data_fx  )         // 被测时钟频率输出
);


SegLed u_SegLed
( 
	.clk_24m            (clk),
	.rst_n				(rst_n_w),
    .sm_seg				(sm_seg),
    .sm_bit				(sm_bit),
    .data				(data_k)
);



uart_transfer u_uart_transfer
(
	.sys_clk			(clk),
	.sys_rst_n			(rst_n_w),
	
	.txd				(uart_txd),
	
	.txd_en				(txd_fre_clk),
	.txd_data			(data_uart)

);
    

endmodule
