`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/02 20:24:09
// Design Name: 
// Module Name: stateGetFP
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


/* stateClear
???????????
????clk,start(start=1????????)
?????done(done=1?????),FP_num(??????????????????)
*/

module stateClear(
    input clk,clk_sys,begin_sign,rx,rstn,//����Ч��??
    output reg done,
    output wire tx,
    output wire right
);

reg start;
reg [2:0]state;
wire [4:0]state_done;
reg rst = 0;

initial begin
    start = 0;
    state = 0;
    done = 0;
end

stateClear001 scl001(clk,rst,state,state_done[0],tx);
stateClear010 scl010(clk,rst,state,state_done[1],rx,right);

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
        3'b001://???? ????????
            if (state_done[0]) state = 3'b010;
            else state = 3'b001;
        3'b010://???? ?????
            if (state_done[3]) state = 3'b101;
            else state = 3'b010;
        3'b101://????
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
