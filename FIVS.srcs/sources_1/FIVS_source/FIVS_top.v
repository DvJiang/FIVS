`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Peking University
// Engineer: HovenChan
//
// Create Date: 2022/06/05 23:22:45
// Design Name: FIVS_top
// Module Name: FIVS_top
// Project Name: Fingerprint Identification and Verification System
// Target Devices: Aritx-7
// Tool Versions: Vivado 2018.3
// Description: The top Module of the project
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Fingerprint Identification and Verification System,
//                      use the fingerprint to manage your passwords.
//
//////////////////////////////////////////////////////////////////////////////////


module FIVS_top(input clk100mhz,           // connect to 100MHz clock
                input rst_n,               // low-effective reset signal
                input [1:0] SW,            // function selector
                input [7:0] admin_pwd,     // 8 bits's administor password,  
                // Fingerprint Module signals
                input rx,                  // connect to UART rx
                output tx,                 // connect to UART tx
                input Finger_input,        // connect to WAK
                // USB Module signals
                output usb_dp_pull,        // connect to USB D+ by an 1.5k resistor
                inout usb_dp,              // connect to USB D+
                inout usb_dn,              // connect to USB D-
                
                //Light control
                output reg [7:0]admin_light,
                output reg [1:0]SW_light,
                output reg FP_light,
                output wire right
                );

    //-------------------------------------------------------------------------------------------------------------------------------------
    // The state machine's 60MHz clock
    // Use clock IP on Vivado 2018.3 to create a 60MHz clock
    //-------------------------------------------------------------------------------------------------------------------------------------
    wire       clk60mhz;
    wire       clk_locked;                 // 1 when the clock is stable
    
    clk_wiz_0 clk_wiz_0_i(
    .clk_100mhz      (clk100mhz),
    .clk_60mhz       (clk60mhz),
    .locked         (clk_locked)
    );

    //-------------------------------------------------------------------------------------------------------------------------------------
    // StateMachine Module signals
    //-------------------------------------------------------------------------------------------------------------------------------------
    wire [1:0] SW;
    wire [7:0] admin_pwd;
    wire Finger_input;
    wire FM_done;
    wire Error;
    wire check;
    wire get;
    wire clear;
    wire send;
    wire send_done;
    
    //-------------------------------------------------------------------------------------------------------------------------------------
    // FM_control Module signals
    //-------------------------------------------------------------------------------------------------------------------------------------
    wire check, clear, get;
    wire right;
    wire FM_done;
    wire pwd_code;
    wire rx;
    wire tx;

    //-------------------------------------------------------------------------------------------------------------------------------------
    // USB Module signals
    //-------------------------------------------------------------------------------------------------------------------------------------
    wire usb_dp_pull;
    wire usb_dp;
    wire usb_dn;
    wire send;
    wire pwd_code;
    wire send_done;
    
    StateMachine state_machine_0(
    .clk(clk60mhz),
    .rst_n(rst_n),
    .SW(SW),
    .admin_pwd(admin_pwd),
    .Finger_input(Finger_input),
    .FM_done(FM_done),
    .Error(Error),
    .check(check),
    .get(get),
    .clear(clear),
    .send(send),
    .send_done(send_done)
    );
    
    FPcontrol FP_controller_0(
    .clk100M(clk100mhz),
    .clk_sys(clk60mhz),
    .signal({check,clear,get}),
    .right(right),
    .done(FM_done),
    .rstn(rst_n),
    .FP_id(pwd_code),
    .rx(rx),
    .tx(tx)
    );

    not(Error, right);
    
    PwdToPC usb_keyboard_0(
    .clk60mhz(clk60mhz),      
    .clk_locked(clk_locked),
    .rstn_button(rst_n),
    .usb_dp_pull(usb_dp_pull),
    .usb_dp(usb_dp),
    .usb_dn(usb_dn),
    .send_request(send),
    .pwd_code(pwd_code), 
    .send_done(send_done)
    );
    //-------------------------------------------------------------------------------------------------------------------------------------
    //Light control
    //-------------------------------------------------------------------------------------------------------------------------------------
    always@(clk100mhz)begin
        SW_light <= SW;
        admin_light <= admin_pwd;
        FP_light <= Finger_input;
    end
    
endmodule
