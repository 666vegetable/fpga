module uart_transfer
(
	input			sys_clk,
	input			sys_rst_n,
	
	output  reg 	txd,
	
	input	 		txd_en,
	input [87:0]	txd_data

);
parameter    	CLK_FS	 	= 26'd24000000;  // 基准时钟频率值
parameter  		UART_BPS 	= 460800;      //定义串口波特率
parameter 		BPS_CNT 	= CLK_FS/UART_BPS;

reg 			txd_data_0;
reg 			txd_data_1;
reg	[15:0]		clk_cnt;
reg [ 3:0]		txd_cnt;
reg 			tx_flag;
reg	[ 7:0]		txd_data_check;
reg [ 3:0]		txd_state;

wire  en_flag;

assign en_flag = (~txd_data_1) & txd_data_0;

always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        txd_data_0 <= 1'b0;                                  
        txd_data_1 <= 1'b0;
    end                                                      
    else begin                                               
        txd_data_0 <= txd_en;                               
        txd_data_1 <= txd_data_0;                            
    end
end

always @(posedge sys_clk or negedge sys_rst_n)
begin
	if(!sys_rst_n)begin
		tx_flag <= 1'd0;
		txd_state <= 4'd0;
	end
	else if(en_flag == 1'd1)begin
		tx_flag <= 1'd1;
	end
	else if (tx_flag)begin
		if((txd_cnt == 4'd9)&&(clk_cnt == BPS_CNT/2))begin	
			if(txd_state < 4'd10)begin
				txd_state <= txd_state + 1'd1;
			end			
			else begin
				tx_flag <= 1'd0;
				txd_state <= 4'd0;		
			end	
		end
	end
	else begin
		tx_flag <= tx_flag;
	end
end

always @(posedge sys_clk or negedge sys_rst_n)
begin
	if(!sys_rst_n) begin
		txd_data_check <= 8'd0;
	end
	else if(tx_flag)begin
		case(txd_state)
			4'd0: txd_data_check <= txd_data[ 7:0];
			4'd1: txd_data_check <= txd_data[15:8];
			4'd2: txd_data_check <= txd_data[23:16];
			4'd3: txd_data_check <= txd_data[31:24];
			4'd4: txd_data_check <= txd_data[39:32];
			4'd5: txd_data_check <= txd_data[47:40];
			4'd6: txd_data_check <= txd_data[55:48];
			4'd7: txd_data_check <= txd_data[63:56];
			4'd8: txd_data_check <= txd_data[71:64];
			4'd9: txd_data_check <= txd_data[79:72];
			4'd10:txd_data_check <= txd_data[87:80];
			default:;
		endcase
	end
	else begin
		txd_data_check <= 8'd0;
	end
end
		

always @(posedge sys_clk or negedge sys_rst_n)
begin
	if(!sys_rst_n) begin
		clk_cnt <= 16'd0;
		txd_cnt  <= 4'd0;
	end
	else if(tx_flag) begin
		if(clk_cnt < BPS_CNT -1'd1) begin
			clk_cnt <= clk_cnt + 1'd1;
			txd_cnt 	<= txd_cnt;
		end
		else begin
			clk_cnt <= 16'd0;
			txd_cnt <= txd_cnt + 1'd1;
		end
	end
	else begin
		clk_cnt <= 16'd0;
		txd_cnt  <= 4'd0;
	end	
end

always @(posedge sys_clk or negedge sys_rst_n)
begin
	if(!sys_rst_n)
		txd <= 1'b1;
	else if(tx_flag)
		begin
			case(txd_cnt)
				4'd0:  txd <= 1'b0;
				4'd1:  txd <= txd_data_check[0];
				4'd2:  txd <= txd_data_check[1];
				4'd3:  txd <= txd_data_check[2];
				4'd4:  txd <= txd_data_check[3];
				4'd5:  txd <= txd_data_check[4];
				4'd6:  txd <= txd_data_check[5];
				4'd7:  txd <= txd_data_check[6];
				4'd8:  txd <= txd_data_check[7];
				4'd9:  txd <= 1'b1;
				default:;	
			endcase		
		end
	else
		txd <= 1'b1;	
end

endmodule