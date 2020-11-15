module Top_Frequency( 
	input	   		clk,
    output			wire [7:0] sm_seg,
    output			wire [3:0] sm_bit,
     //cymometer interface
    input        	clk_fx   ,    // ����ʱ��
    output   		uart_txd ,
    output          clk_24MHZ,
    output          clk_200MHZ
);

//parameter define
parameter    	CLK_FS_24MHZ 	= 26'd24_000_000	;  	// ��׼ʱ��Ƶ��ֵ
parameter    	CLK_FS_200MHZ 	= 28'd200_000_000	;  	// ��׼ʱ��Ƶ��ֵ

parameter  		UART_BPS 		= 460800			;  	//���崮�ڲ�����
parameter		UART_FRE 		= 18'd200_000		;   
//wire define   
wire [25:0]     data_fx		;         					// �����źŲ���ֵ
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

//�����Ⱦ���Ƶ�ʼ�ģ��
cymometer #(.CLK_FS(CLK_FS_200MHZ)          // ��׼ʱ��Ƶ��ֵ
) u_cymometer(
    //system clock
    .clk_fs      (clk_200MHZ),       // ��׼ʱ���ź�
    .rst_n       (rst_n_w),          // ��λ�ź�
    //cymometer interface
    .clk_fx      (clk_fx   ),        // ����ʱ���ź�
    .data_fx     (data_fx  )         // ����ʱ��Ƶ�����
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
