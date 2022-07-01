`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/03 15:13:21
// Design Name: 
// Module Name: stateGetFP100
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


module stateGetFP100(
    input clk,sys_rst,
    input wire [2:0]state_upper,
    output reg state_done, 
    input wire rx,
    output reg right
);

wire done_receive;
wire [7:0]rmessage;
reg start = 0;
integer i = 0;
reg [7:0]conf;
reg [7:0]order;


usart232_rx ur(//???��??
.sys_clk(clk),
.sys_rst(sys_rst),
.data_in_1bit(rx),
.po_data(rmessage),
.po_flag(done_receive)
);

always @(posedge done_receive or negedge sys_rst) begin
    if (!sys_rst) begin state_done = 0;right = 0; end 
    else if (state_upper == 3'b100)begin
        if (rmessage == 8'b11101111) begin i = 1; start = 1;end
        else if (i == 9 && start) begin conf = rmessage; i = i + 1;end
        else if (i == 10 && start) begin order = rmessage; i = i + 1;end
        else if (i == 13 && start) begin i = 0;end
        else i = i + 1;
        if (order == 8'h6)
            begin
                if (conf == 8'h0)
                    right = 1;
                else
                    right = 0;
                state_done = 1;
            end
    end
end

endmodule