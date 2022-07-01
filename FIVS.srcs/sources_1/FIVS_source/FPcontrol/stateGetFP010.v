`timescale 1ns / 1ps

module stateGetFP010(
    input clk,sys_rst,
    input wire [2:0]state_upper,
    output reg state_done, 
    input wire rx,
    output reg [15:0]FP_num
);

wire done_receive;
wire [7:0]rmessage;
reg start = 0;
integer i = 0;


usart232_rx ur(//���з�Ƶ
.sys_clk(clk),
.sys_rst(sys_rst),
.data_in_1bit(rx),
.po_data(rmessage),
.po_flag(done_receive)
);

always @(posedge done_receive or negedge sys_rst) begin
    if (!sys_rst) state_done = 0;
    else if (state_upper == 3'b010)begin
        if (rmessage == 8'b11101111) begin i = 1; start = 1;end
        else if (i == 10 && start) begin FP_num[15:8] = rmessage; i = i + 1;end
        else if (i == 11 && start) begin FP_num[7:0] = rmessage; i = i + 1;end
        else if (i == 13 && start) begin state_done = 1;end
        else i = i + 1;
    end
end

endmodule