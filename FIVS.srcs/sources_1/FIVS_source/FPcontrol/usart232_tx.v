module usart232_tx(
input wire sys_clk,
input wire sys_rst,
input wire [7:0] pi_data,
input wire pi_flag,
output reg done_flag,
output reg tx
);
parameter Baund_cnt_max=13'd1736;
reg [12:0] baund_cnt;
reg enable;
reg send_flag;
reg [3:0] send_cnt;
initial begin
    baund_cnt = 0;
    send_cnt = 0;
    send_flag = 0;
    enable = 0;
    tx = 1;
end

//���ؼ���
always@(posedge sys_clk or negedge sys_rst)
if(!sys_rst)
baund_cnt<=0;
else if(baund_cnt==Baund_cnt_max-1'b1||enable==1'b0)
baund_cnt<=0;
else
baund_cnt<=baund_cnt+1'b1;
//���ͱ�־
always@(posedge sys_clk or negedge sys_rst)
if(!sys_rst)
send_flag<=0;
else if(baund_cnt==1'b1&&enable)//
send_flag<=1'b1;
else
send_flag<=0;
//�������ݼ���
always@(posedge sys_clk or negedge sys_rst)
if(!sys_rst)
send_cnt<=0;
else if(send_cnt==4'd11&&send_flag||enable==1'b0)
send_cnt<=0;
else if(send_flag)
send_cnt<=send_cnt+1'b1;
//ʹ���ź�
always@(posedge sys_clk or negedge sys_rst)
if(!sys_rst)
enable<=0;
else if(pi_flag)
enable<=1;
else if(send_cnt==4'd9&&send_flag)
enable<=0;
else enable<=0;
//��ת��+���ݷ���
always@(posedge sys_clk or negedge sys_rst)
if(!sys_rst)begin
tx<=1'b1;
done_flag = 0;
end
else if(send_flag)
begin
case (send_cnt)
0 : tx <= 1'b0;
1 : tx <= pi_data[7];
2 : tx <= pi_data[6];
3 : tx <= pi_data[5];
4 : tx <= pi_data[4];
5 : tx <= pi_data[3];
6 : tx <= pi_data[2];
7 : tx <= pi_data[1];
8 : tx <= pi_data[0];
9 : tx <= 1'b1;
10 : tx <= 1'b1;
11 : tx <= 1'b1;
default : tx <= 1'b1;
endcase
if (send_cnt == 4'd11 && sys_rst) done_flag = 1;
end
endmodule
