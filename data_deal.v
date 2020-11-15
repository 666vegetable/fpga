module data_deal(
	input					clk,
	input					rst_n,
	input	[25:0]			data_fx,
	output	reg  			txd_fre_clk,	
	output	reg  [87:0]		data_uart,
	output	reg  [14:0]		data_k
	);

reg	 [18:0]		uart_fre_cnt;
reg  [14:0]		period_time	;

parameter		UART_FRE 		= 18'd200_000; 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		uart_fre_cnt <= 19'd0;
	end
	else begin
		if(uart_fre_cnt < UART_FRE/2 - 1'd1) begin
			uart_fre_cnt <= uart_fre_cnt + 1'd1;
		end
		else begin
			uart_fre_cnt <= 19'd0;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		txd_fre_clk <= 1'd0;
	end
	else begin
		if(uart_fre_cnt == UART_FRE/2 - 1'd1)begin
			txd_fre_clk <= ~txd_fre_clk;
		end
		else begin
			txd_fre_clk <= txd_fre_clk;
		end
	end	
end

always @(posedge txd_fre_clk or negedge rst_n)
begin
	if(!rst_n)begin
		period_time <= 15'd0;
	end
	else begin
		if(period_time < 15'd9999)begin
			period_time <= period_time + 1'd1;
		end
		else begin
			period_time <= 15'd0;
		end
	end	
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		data_uart <= 88'd0;
		data_k	<=  15'd0;
	end
	else begin
		data_k	<=  data_fx/1000;
		data_uart[ 7: 0] <=  8'd65;
  		data_uart[15: 8] <=  data_k/1000+8'd48;
  		data_uart[23:16] <=  data_k/100%10+8'd48;
  		data_uart[31:24] <=  data_k/10%10+8'd48	;
  		data_uart[39:32] <=  data_k%10+8'd48;
  		data_uart[47:40] <=  8'd66;
  		data_uart[55:48] <=  period_time/1000+8'd48;
  		data_uart[63:56] <=  period_time/100%10+8'd48;
  		data_uart[71:64] <=  period_time/10%10+8'd48	;
  		data_uart[79:72] <=  period_time%10+8'd48;
  		data_uart[87:80] <=  8'd67;
	end
end

endmodule
