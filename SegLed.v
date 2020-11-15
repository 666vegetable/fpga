`timescale 1ns/ 1ps

module
SegLed
( 
	input	           clk_24m,
	input              rst_n,
    output	wire [7:0] sm_seg,
    output	wire [3:0] sm_bit,
    input        [14:0]data
);

parameter CNT_10MS = 2400; //10ms      

reg [15:0]	sm_bit_num;
reg [2:0]   sm_num_bit;
//计数器，约为10ms扫描一次
reg [17:0] 	cnt_w;
//数码管位选
reg [3:0] 	sm_bit_reg;
reg [3:0] 	sm_seg_num;
reg [7:0]	sm_seg_reg;	
localparam
			S0 = 4'b0000 ,
			S1 = 4'b0001 ,
			S2 = 4'b0010 ,
			S3 = 4'b0011 ,
			S4 = 4'b0100 ,
			S5 = 4'b0101 ,
			S6 = 4'b0110 ,
			S7 = 4'b0111 ,
			S8 = 4'b1000 ,
			S9 = 4'b1001 ;		

always@(posedge clk_24m or negedge rst_n)
begin
	if(!rst_n)
		cnt_w <= 18'd0;
	else if(cnt_w == CNT_10MS)  
		cnt_w <= 18'd0;
	else
		cnt_w <= cnt_w + 1;
end

always@(posedge clk_24m or negedge rst_n)
begin
	if(!rst_n)begin
		sm_bit_num <= 16'd0;
	end	
	else begin
		sm_bit_num[ 3: 0] <= data%10;
		sm_bit_num[ 7: 4] <= data/10%10;
		sm_bit_num[11: 8] <= data/100%10;
		sm_bit_num[15:12] <= data/1000%10;
	end
end

always@(posedge clk_24m or negedge rst_n)
begin
	if(!rst_n)
		sm_num_bit <= 3'd0;
	else if(cnt_w == CNT_10MS)  
	// else if(&cnt_w)  
		begin 
			if(sm_num_bit < 2'b11)
				sm_num_bit <= sm_num_bit + 1'd1;
			else
			    sm_num_bit <= 2'b00;
		end
    else
    	sm_num_bit <= sm_num_bit;	
end


always@(posedge clk_24m or negedge rst_n)
begin
	if(!rst_n)
		sm_seg_num   <= 4'h0;
	else
	begin
		case(sm_num_bit)
		2'b000:sm_seg_num   <= sm_bit_num[ 3: 0]; 
		2'b001:sm_seg_num   <= sm_bit_num[ 7: 4]; 
		2'b010:sm_seg_num   <= sm_bit_num[11: 8]; 
		2'b011:sm_seg_num   <= sm_bit_num[15:12]; 
		endcase
	end
end

always@(posedge clk_24m or negedge rst_n)
begin
	if(!rst_n)
		sm_bit_reg <= 4'b1111;
	else
	begin
		case( sm_num_bit )
		2'b00:sm_bit_reg <= 4'b1110; 
		2'b01:sm_bit_reg <= 4'b1101; 
		2'b10:sm_bit_reg <= 4'b1011; 
		2'b11:sm_bit_reg <= 4'b0111; 
		endcase
	end
end
			
always@(*)
begin
	case ( sm_seg_num )
	S0:  
		sm_seg_reg <= 8'hc0;
	S1:             
		sm_seg_reg <= 8'hf9;
	S2:             
		sm_seg_reg <= 8'ha4;
	S3:                
		sm_seg_reg <= 8'hb0;
	S4:                
		sm_seg_reg <= 8'h99;
	S5:                
		sm_seg_reg <= 8'h92;
	S6:                 
		sm_seg_reg <= 8'h82;
	S7:                 
		sm_seg_reg <= 8'hf8;
	S8:              
		sm_seg_reg <= 8'h80;
	S9:                
		sm_seg_reg <= 8'h90;
	default:
		sm_seg_reg <= 8'hc0;		
	endcase
end	
					
assign sm_seg = sm_seg_reg;	
assign sm_bit = sm_bit_reg;	

endmodule
