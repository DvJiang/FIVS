module FPcontrol(

    //clk
    input clk100M,//The UART modules need 100M clk
    input clk_sys,//The system clk can be changed

    //system control
    input [2:0]signal,//The switch of GET,CLEAR and CHECK FP.
    output right,//The signal of the result of the function CLEAR and CHECK
    output done,//It will be positive if the function get done.
    input rstn,//reset, Low Level effective

    //data
    output [15:0]FP_id,//return the check answer, ATTENTION:Only if the 'right' is positive,will this output be in effect.

    //communicate with FP
    input rx,
    output tx
);
wire tx1,tx2,tx3;
and(tx,tx1,tx2,tx3);

wire done1,done2,done3;
assign done = done1+done2+done3;

wire right1,right2,right3;
and(right,right1,right2,right3);

stateGetFP sfp(clk100M,clk_sys,signal[0],rx,rstn,done1,tx1,right1);
stateClear scl(clk100M,clk_sys,signal[1],rx,rstn,done2,tx2,right2);
stateCheck sck(clk100M,clk_sys,signal[2],rx,rstn,done3,FP_id,tx3,right3);

endmodule