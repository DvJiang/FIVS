`timescale 1ns / 1ps

module stateGetFP(
    input clk,clk_sys,begin_sign,rx,rstn,//低有效�?��??
    output reg done = 0,
    output wire tx,
    output wire right
);

reg start = 0;
reg [2:0]state = 3'b000;
wire [4:0]state_done;
reg rst = 0;
wire tx1,tx2;
wire [15:0]FP_num; 

and(tx,tx1,tx2);

stateGetFP001 sfp001(clk,rst,state,state_done[0],tx1);
stateGetFP010 sfp010(clk,rst,state,state_done[1],rx,FP_num);
stateGetFP011 sfp011(clk,rst,state,state_done[2],tx2,FP_num);
stateGetFP100 sfp100(clk,rst,state,state_done[3],rx,right);

always @(posedge clk_sys or negedge rstn) begin
    if (begin_sign && (state == 3'b000))begin 
    start = 1;
    rst = 0;
    end

    if (!rstn)begin
        start = 0;
        state = 0;
        done = 0;
    end
    else if (start) begin
        rst = 1;
        case (state)
        3'b001://���� ��ѯָ����
            if (state_done[0]) state = 3'b010;
            else state = 3'b001;
        3'b010://���� ָ����
            if (state_done[1]) state = 3'b011;
            else state = 3'b010;
        3'b011://���� ¼��ָ��
            if (state_done[2]) state = 3'b100;
            else state = 3'b011;
        3'b100://���� ��Ӧ
            if (state_done[3]) 
                if (right) state = 3'b101;
                else begin state = 3'b001; rst = 0; end
            else state = 3'b100;
        3'b101://����
            begin
                state = 3'b000;
                done = 1;
                start = 0;
            end
        default:
        begin
            if (start) state = 3'b001;
            else state = 3'b000;
            done = 0;
        end
        endcase
    end
end



endmodule
