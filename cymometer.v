module cymometer
   #(parameter    CLK_FS = 30'd200_000_000) // ��׼ʱ��Ƶ��ֵ
    (   //system clock
        input                 clk_fs ,     // ��׼ʱ���ź�
        input                 rst_n  ,     // ��λ�ź�

        //cymometer interface
        input                 clk_fx ,     // ����ʱ���ź�
        output   reg [25:0]   data_fx      // ����ʱ��Ƶ�����
);

//parameter define
localparam   GATE_TIME = 18'd100_000;      // �ſ�ʱ������

//reg define
reg             gate_pre    ;              // Ԥ��բ���ź�
reg             gate        ;              // �ſ��ź�
reg             gate_fx_r   ;
reg             gate_fs_d0  ;              // ���ڲɼ���׼ʱ����gate�½���
reg             gate_fs_d1  ;              // ���ڲɼ���׼ʱ����gate�½���
reg             gate_fx_d0  ;              // ���ڲɼ�����ʱ����gate�½���
reg             gate_fx_d1  ;              // ���ڲɼ�����ʱ����gate�½���
reg    [25:0]   gate_cnt    ;              // �ſؼ���
reg    [31:0]   fs_cnt      ;              // �ſ�ʱ���ڻ�׼ʱ�ӵļ���ֵ
reg    [31:0]   fs_cnt_tmp  ;              // fs_cnt ��ʱֵ
reg    [31:0]   fx_cnt      ;              // �ſ�ʱ���ڱ���ʱ�ӵļ���ֵ
reg    [31:0]   fx_cnt_tmp  ;              // fx_cnt ��ʱֵ
reg    [63:0]   data_fx_tmp ;
//wire define
wire            neg_gate_fs;               // ��׼ʱ�����ſ��ź��½���
wire            neg_gate_fx;               // ����ʱ�����ſ��ź��½���

//*****************************************************
//**                    main code
//*****************************************************

//���ؼ�⣬�����ź��½���
assign neg_gate_fs = gate_fs_d1 & (~gate_fs_d0);
assign neg_gate_fx = gate_fx_d0 & (~gate);

/***********************************************************/
//ʹ�û�׼ʱ�Ӳ���Ԥ��բ���ź�gate_preȻ��ͬ��������ʱ������
//���ſ��ź�gate,�˴� gate_pre = GATE_TIME/CLK_FS = 1s
//Ȼ��ת��Ҳ����˵Լÿ2s��һ�ν����gate_preƵ��Ϊ1/2Hz,ռ
//�ձ�Ϊ50%��������ΧΪ 1Hz~CLK_FS
//ע�⣺gate_pre��Ƶ�ʺ�ռ�ձȻ�Ӱ�����������ɸ���ʵ�����
//���������޸���������always��������������ɺ��ʵ�gate_pre
/***********************************************************/

//Ԥ��բ���źż�������ʹ�û�׼ʱ�Ӽ���
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n)
        gate_cnt <= 26'd0;
    else if(gate_cnt == GATE_TIME - 1)
        gate_cnt <= 26'd0;
    else
        gate_cnt <= gate_cnt + 1'b1;
end

//Ԥ��բ���ź�
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n)
        gate_pre <= 1'b0;
    else if(gate_cnt == GATE_TIME - 1)
        gate_pre <= ~gate_pre;
end

//��Ԥ��բ���ź�ͬ��������ʱ���������ſ��ź�
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

//���Ĳ��ſ��źŵ��½��أ���׼ʱ���£�
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

//���Ĳ��ſ��źŵ��½��أ�����ʱ���£�
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

//�ſ�ʱ���ڶԱ���ʱ�Ӽ���
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

//�ſ�ʱ���ڶԻ�׼ʱ�Ӽ���
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

//���㱻���ź�Ƶ��
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