`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/02 19:40:56
// Design Name: 
// Module Name: usart232_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module usart232_rx(
input wire sys_clk,
input wire sys_rst,//低有效
input wire data_in_1bit,
output reg [7:0] po_data = 0,
output reg po_flag
);
parameter BOUND_CNT_MAX = 13'd1736;//波特率9600*6，时钟频率100MHz
reg  reg1;
reg  reg2;
reg  reg3;
reg [7:0]data_out = 0;
reg [12:0] bound_cnt;//波特率计数器
reg start_flag;//开始标志（下降沿标志）
reg enable;//使能信号
reg bit_flag;//读取数据标志
reg [3:0] bit_cnt = 0;//用于计数该时刻接收的数据是第几个比特的计数器
reg data_out_flag;//串并转换完成标志
//时钟同步数据
always@(posedge sys_clk or negedge sys_rst)
if (sys_rst==0)
reg1<=1;
else
reg1<=data_in_1bit;
//打一拍，减少出现亚稳态的概率
always@(posedge sys_clk or negedge sys_rst)
if (sys_rst==0)
reg2<=1;
else
reg2<=reg1;
//再打一拍，再次减少出现亚稳态的概率
always@(posedge sys_clk or negedge sys_rst)
if (sys_rst==0)
reg3<=1;
else
reg3<=reg2;

//时钟计数
always@(posedge sys_clk or negedge sys_rst)
if (sys_rst==0)
bound_cnt<=0;
else if (bound_cnt==BOUND_CNT_MAX-1'b1||enable==0)
bound_cnt<=0;
else if(enable ==1)
bound_cnt<=bound_cnt+1'b1;
else 
bound_cnt<=0;

//开始标志，提取下降沿
always@(posedge sys_clk or negedge sys_rst)
if (sys_rst==0)
start_flag<=0;
else if(reg3==1&&reg2==0)
start_flag<=1;
else
start_flag<=0;


//串行数据采集
always@(posedge sys_clk or negedge sys_rst)
if (sys_rst==0)
bit_flag<=0;
else if(bound_cnt==(BOUND_CNT_MAX/2-1'b1))
bit_flag<=1;
else
bit_flag<=0;

//采样计数
always@(posedge sys_clk or negedge sys_rst)
if (sys_rst==0)
bit_cnt<=0;
else if(bit_flag==1&&bit_cnt==4'd8)
bit_cnt<=0;
else if (bit_flag==1)
bit_cnt<=bit_cnt+1'b1;


//使能信号
always@(posedge sys_clk or negedge sys_rst)
if (sys_rst==0)
enable<=0;
else if(start_flag==1)
enable<=1;
else if(bit_cnt==4'd8&&bit_flag==1)
enable<=0;

//串并转换
always@(posedge sys_clk or negedge sys_rst)
if (sys_rst==0)
data_out<=0;
else if(bit_cnt>=4'b1&&bit_cnt<=4'd8&&bit_flag==1'b1)
data_out<={data_out[6:0],reg3};

//数据转换完成标志
always@(posedge sys_clk or negedge sys_rst)
if (sys_rst==0)
data_out_flag<=0;
else if(bit_cnt==4'd8&&bit_flag==1'b1)
data_out_flag<=1;
else 
data_out_flag<=0;

//输出数据
always@(posedge sys_clk or negedge sys_rst)
if (sys_rst==0)
po_data<=0;
else if(data_out_flag==1)
po_data<=data_out;

//输出数据有效标志
always@(posedge sys_clk or negedge sys_rst)
if (sys_rst==0)
po_flag<=0;
else if(data_out_flag==1 && po_flag == 0)
po_flag<=1;
else
po_flag<=0;

endmodule
