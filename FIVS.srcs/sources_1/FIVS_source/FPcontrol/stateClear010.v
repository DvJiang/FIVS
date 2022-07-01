`timescale 1ns / 1ps

module stateClear010(
    input wire clk,sys_rst,
    input wire [2:0]state_upper,
    output reg state_done, 
    input wire rx,
    output reg right
);

wire done_receive;
wire [7:0]rmessage;
reg start = 0;
integer i = 0;
reg [7:0]ans = 8'b11111111;

usart232_rx ur(//���з�Ƶ
.sys_clk(clk),
.sys_rst(sys_rst),
.data_in_1bit(rx),
.po_data(rmessage),
.po_flag(done_receive)
);

always @(posedge done_receive) begin
    if (!sys_rst) state_done = 0;
    else if (state_upper == 3'b010)begin
        if (rmessage == 8'b11101111) begin i = 1; start = 1;end
        else if (i == 9 && start) begin ans = rmessage; i = i + 1;end
        else if (i == 11 && start) begin state_done = 1;end
        else i = i + 1;
    end
    if (ans == 8'd0) right = 1;
    else right = 0;
end

endmodule