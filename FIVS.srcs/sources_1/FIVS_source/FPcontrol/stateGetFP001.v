`timescale 1ns / 1ps

module stateGetFP001(
    input clk,sys_rst,
    input [2:0]state_upper,
    output reg state_done, 
    output wire tx
);

reg start_send;
reg [3:0]state = 0;
wire done_send;
reg [7:0]message;
reg rst;

initial begin
    state = 0;
    state_done = 0;
    message = 0;
end

usart232_tx ut(//内有分频
.sys_clk(clk),
.sys_rst(rst),
.pi_data(message),
.done_flag(done_send),
.pi_flag(start_send),
.tx(tx)
);

always @(posedge clk or negedge sys_rst) begin
    if(!sys_rst) state_done = 0;
    else if (state_upper == 3'b001)begin
        case (state)
        4'b0001://包头1
            begin
              rst = 1;
              message = 8'b11101111;
              start_send = 1;
              if (done_send) begin state = 4'b0010; start_send = 0; rst = 0; end
              else state = 4'b0001;
            end
        4'b0010://包头2
            begin
              rst = 1;
              message = 8'b00000001;
              start_send = 1;
              if (done_send) begin state = 4'b0011; start_send = 0; rst = 0;end
              else state = 4'b0010;
            end
        4'b0011://地址1
            begin
              rst = 1;
              message = 8'b11111111;
              start_send = 1;
              if (done_send) begin state = 4'b0100; start_send = 0;  rst = 0; end
              else state = 4'b0011;
            end
        4'b0100://地址2
            begin
              rst = 1;
              message = 8'b11111111;
              start_send = 1;
              if (done_send) begin state = 4'b0101; start_send = 0;  rst = 0; end
              else state = 4'b0100;
            end
        4'b0101://地址3
            begin
              rst = 1;
              message = 8'b11111111;
              start_send = 1;
              if (done_send) begin state = 4'b0110; start_send = 0;  rst = 0; end
              else state = 4'b0101;
            end
        4'b0110://地址4
            begin
              rst = 1;
              message = 8'b11111111;
              start_send = 1;
              if (done_send) begin state = 4'b0111; start_send = 0;  rst = 0; end
              else state = 4'b0110;
            end
        4'b0111://标识
            begin
              rst = 1;
              message = 8'b00000001;
              start_send = 1;
              if (done_send) begin state = 4'b1000; start_send = 0;  rst = 0; end
              else state = 4'b0111;
            end
        4'b1000://包长1
            begin
              rst = 1;
              message = 8'b00000000;
              start_send = 1;
              if (done_send) begin state = 4'b1001; start_send = 0;  rst = 0; end
              else state = 4'b1000;
            end
        4'b1001://包长2
            begin
              rst = 1;
                message = 8'b00000011;
                start_send = 1;
                if (done_send) begin state = 4'b1010; start_send = 0;  rst = 0; end
                else state = 4'b1001;
                end
        4'b1010://指令
            begin
              rst = 1;
              message = 8'b00011101;
              start_send = 1;
              if (done_send) begin state = 4'b1011; start_send = 0;  rst = 0; end
              else state = 4'b1010;
            end
        4'b1011://校验1
            begin
              rst = 1;
              message = 8'b00000000;
              start_send = 1;
              if (done_send) begin state = 4'b1100; start_send = 0;  rst = 0; end
              else state = 4'b1011;
            end
        4'b1100://校验2
            begin
              rst = 1;
              message = 8'b00100001;
              start_send = 1;
              if (done_send) begin state = 4'b1101; start_send = 0;  rst = 0; end
              else state = 4'b1100;
            end
        4'b1101://结束
            begin
              rst = 1;
              state_done = 1;
              state = 4'b0000;
            end
        default:
            begin 
              rst = 1;
              if (state_upper == 3'b001) begin state = 4'b0001; start_send = 0; end
              else state = 4'b0000;
            end
    endcase
    end
end

endmodule