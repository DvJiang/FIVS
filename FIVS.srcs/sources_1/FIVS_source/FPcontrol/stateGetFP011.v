`timescale 1ns / 1ps

module stateGetFP011(
    input clk,sys_rst,
    input [2:0]state_upper,
    output reg state_done, 
    output wire tx,
    input wire [15:0]FP_num
);

reg start_send;
reg [4:0]state = 0;
wire done_send;
reg [7:0]message;
reg [15:0]fp_num;
reg [15:0]sum;
reg rst;

initial begin
    state = 0;
    state_done = 0;
    message = 0;
end

always @(posedge clk ) begin
    fp_num = FP_num + 1;
    sum = fp_num + 16'b00000001 + 16'b00001000 + 16'b00000011 + 16'b00010111;
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
    if (!sys_rst) state_done = 0;
    else if (state_upper == 3'b011)begin
        case (state)
        5'b00001://包头1
            begin
              rst = 1;
              message = 8'b11101111;
              start_send = 1;
              if (done_send) begin state = 5'b0010; start_send = 0; rst = 0; end
              else state = 5'b0001;
            end
        5'b00010://包头2
            begin
              rst = 1;
              message = 8'b00000001;
              start_send = 1;
              if (done_send) begin state = 5'b0011; start_send = 0; rst = 0;end
              else state = 5'b0010;
            end
        5'b00011://地址1
            begin
              rst = 1;
              message = 8'b11111111;
              start_send = 1;
              if (done_send) begin state = 5'b0100; start_send = 0;  rst = 0; end
              else state = 5'b0011;
            end
        5'b00100://地址2
            begin
              rst = 1;
              message = 8'b11111111;
              start_send = 1;
              if (done_send) begin state = 5'b0101; start_send = 0;  rst = 0; end
              else state = 5'b0100;
            end
        5'b0101://地址3
            begin
              rst = 1;
              message = 8'b11111111;
              start_send = 1;
              if (done_send) begin state = 5'b0110; start_send = 0;  rst = 0; end
              else state = 5'b0101;
            end
        5'b0110://地址4
            begin
              rst = 1;
              message = 8'b11111111;
              start_send = 1;
              if (done_send) begin state = 5'b0111; start_send = 0;  rst = 0; end
              else state = 5'b0110;
            end
        5'b0111://标识
            begin
              rst = 1;
              message = 8'b00000001;
              start_send = 1;
              if (done_send) begin state = 5'b1000; start_send = 0;  rst = 0; end
              else state = 5'b0111;
            end
        5'b1000://包长1
            begin
              rst = 1;
              message = 8'b00000000;
              start_send = 1;
              if (done_send) begin state = 5'b1001; start_send = 0;  rst = 0; end
              else state = 5'b1000;
            end
        5'b1001://包长2
            begin
              rst = 1;
                message = 8'b00001000;
                start_send = 1;
                if (done_send) begin state = 5'b1010; start_send = 0;  rst = 0; end
                else state = 5'b1001;
                end
        5'b1010://ID1
            begin
              rst = 1;
              message = fp_num[15:8];
              start_send = 1;
              if (done_send) begin state = 5'b1011; start_send = 0;  rst = 0; end
              else state = 5'b1010;
            end
        5'b1011://ID2
            begin
              rst = 1;
              message = fp_num[7:0];
              start_send = 1;
              if (done_send) begin state = 5'b1100; start_send = 0;  rst = 0; end
              else state = 5'b1011;
            end
        5'b1100://次数
            begin
              rst = 1;
              message = 8'b00000011;
              start_send = 1;
              if (done_send) begin state = 5'b1101; start_send = 0;  rst = 0; end
              else state = 5'b1100;
            end
        5'b1101://参数1
            begin
              rst = 1;
              message = 8'b00000000;
              start_send = 1;
              if (done_send) begin state = 5'b1110; start_send = 0;  rst = 0; end
              else state = 5'b1101;
            end
        5'b1110://参数2
            begin
              rst = 1;
              message = 8'b00010111;
              start_send = 1;
              if (done_send) begin state = 5'b1111; start_send = 0;  rst = 0; end
              else state = 5'b1110;
            end
        5'b1111://校验�?1
            begin
              rst = 1;
              message = sum[15:8];
              start_send = 1;
              if (done_send) begin state = 5'b10000; start_send = 0;  rst = 0; end
              else state = 5'b1111;
            end
        5'b10000://校验�?2
            begin
              rst = 1;
              message = sum[7:0];
              start_send = 1;
              if (done_send) begin state = 5'b10001; start_send = 0;  rst = 0; end
              else state = 5'b10000;
            end
        5'b10001://结束
            begin
              rst = 1;
              state_done = 1;
              state = 5'b0000;
            end
        default:
            begin 
              rst = 1;
              if (state_upper == 3'b011) begin state = 5'b0001; start_send = 0; end
              else state = 5'b0000;
            end
    endcase
    end
end

endmodule