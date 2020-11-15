module cymometer
   #(parameter    CLK_FS = 30'd200_000_000) // 基准时钟频率值
    (   //system clock
        input                 clk_fs ,     // 基准时钟信号
        input                 rst_n  ,     // 复位信号

        //cymometer interface
        input                 clk_fx ,     // 被测时钟信号
        output   reg [25:0]   data_fx      // 被测时钟频率输出
);

//parameter define
localparam   GATE_TIME = 18'd100_000;      // 门控时间设置

//reg define
reg             gate_pre    ;              // 预置闸门信号
reg             gate        ;              // 门控信号
reg             gate_fx_r   ;
reg             gate_fs_d0  ;              // 用于采集基准时钟下gate下降沿
reg             gate_fs_d1  ;              // 用于采集基准时钟下gate下降沿
reg             gate_fx_d0  ;              // 用于采集被测时钟下gate下降沿
reg             gate_fx_d1  ;              // 用于采集被测时钟下gate下降沿
reg    [25:0]   gate_cnt    ;              // 门控计数
reg    [31:0]   fs_cnt      ;              // 门控时间内基准时钟的计数值
reg    [31:0]   fs_cnt_tmp  ;              // fs_cnt 临时值
reg    [31:0]   fx_cnt      ;              // 门控时间内被测时钟的计数值
reg    [31:0]   fx_cnt_tmp  ;              // fx_cnt 临时值
reg    [63:0]   data_fx_tmp ;
//wire define
wire            neg_gate_fs;               // 基准时钟下门控信号下降沿
wire            neg_gate_fx;               // 被测时钟下门控信号下降沿

//*****************************************************
//**                    main code
//*****************************************************

//边沿检测，捕获信号下降沿
assign neg_gate_fs = gate_fs_d1 & (~gate_fs_d0);
assign neg_gate_fx = gate_fx_d0 & (~gate);

/***********************************************************/
//使用基准时钟产生预置闸门信号gate_pre然后同步到被测时钟下用
//做门控信号gate,此处 gate_pre = GATE_TIME/CLK_FS = 1s
//然后翻转，也就是说约每2s出一次结果；gate_pre频率为1/2Hz,占
//空比为50%。测量范围为 1Hz~CLK_FS
//注意：gate_pre的频率和占空比会影响测量结果，可根据实际情况
//调整，可修改下面两个always语句块的内容以生成合适的gate_pre
/***********************************************************/

//预置闸门信号计数器，使用基准时钟计数
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n)
        gate_cnt <= 26'd0;
    else if(gate_cnt == GATE_TIME - 1)
        gate_cnt <= 26'd0;
    else
        gate_cnt <= gate_cnt + 1'b1;
end

//预置闸门信号
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n)
        gate_pre <= 1'b0;
    else if(gate_cnt == GATE_TIME - 1)
        gate_pre <= ~gate_pre;
end

//将预置闸门信号同步到被测时钟下用做门控信号
always @(posedge clk_fx or negedge rst_n) begin
    if(!rst_n) begin
        gate_fx_r <= 1'b0;
        gate      <= 1'b0;
    end
    else begin
        gate_fx_r <= gate_pre;
        gate      <= gate_fx_r;
    end
end

//打拍采门控信号的下降沿（基准时钟下）
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n) begin
        gate_fs_d0 <= 1'b0;
        gate_fs_d1 <= 1'b0;
    end
    else begin
        gate_fs_d0 <= gate;
        gate_fs_d1 <= gate_fs_d0;
    end
end

//打拍采门控信号的下降沿（被测时钟下）
always @(posedge clk_fx or negedge rst_n) begin
    if(!rst_n) begin
        gate_fx_d0 <= 1'b0;
        gate_fx_d1 <= 1'b0;
    end
    else begin
        gate_fx_d0 <= gate;
        gate_fx_d1 <= gate_fx_d0;
    end
end

//门控时间内对被测时钟计数
always @(posedge clk_fx or negedge rst_n) begin
    if(!rst_n) begin
        fx_cnt_tmp <= 32'd0;
        fx_cnt     <= 32'd0;
    end
    else if(gate)
        fx_cnt_tmp <= fx_cnt_tmp + 1'b1;
    else if(neg_gate_fx) begin
        fx_cnt_tmp <= 32'd0;
        fx_cnt     <= fx_cnt_tmp;
    end
end

//门控时间内对基准时钟计数
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n) begin
        fs_cnt_tmp <= 32'd0;
        fs_cnt     <= 32'd1;
    end
    else if(gate)
        fs_cnt_tmp <= fs_cnt_tmp + 1'b1;
    else if(neg_gate_fs) begin
        fs_cnt_tmp <= 32'd0;
        fs_cnt     <= fs_cnt_tmp;
    end
end

//计算被测信号频率
always @(*) begin
    data_fx_tmp = (CLK_FS * fx_cnt ) / fs_cnt;
end

always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n)
        data_fx <= 26'd0;
    else
        data_fx <= data_fx_tmp;
end

endmodule