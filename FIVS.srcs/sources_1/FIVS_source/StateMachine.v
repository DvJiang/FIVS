`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Peking University
// Engineer: HovenChan
//
// Create Date: 2022/05/30 11:16:30
// Design Name: FIVS Controller
// Module Name: StateMachine Module
// Project Name: Fingerprint Identification and Verification System
// Target Devices: Aritx-7
// Tool Versions: Vivado 2018.3
// Description: The Controller of FIVS, control the Fingerprint Module and USB 2.0 keyboard
//
// Dependencies: None
//
// Revision:
// Revision 0.02 - Use three sections coding style to design state machine.
// Additional Comments: State Machine Module
//
//////////////////////////////////////////////////////////////////////////////////


module StateMachine(input clk,                  // 60MHz clk
                    input rst_n,
                    input [1:0] SW,             // select switch of four functions(CHECK, GET, SEND, CLEAR)
                    input [7:0] admin_pwd,      // Administor password input
                    // Finger Module signals
                    input Finger_input,         // High when Fingerprint detected on Finger Module
                    input FM_done,              // Finger Module's state, 0 is working, 1 is done.
                    input Error,                // High when Fingerprint is not verified
                    output reg check,           // check command, request the Fingerprint Module to verify the fingerprint
                    output reg get,             // get command, request the Fingerprint Module to store a new fingerprint
                    output reg clear,           // clear command, request the Fingerprint Module to clear all the fingerprints
                    //PwdMgr Module signals
                    output reg send,            // send command, request the Keyboard Module to send the password to PC
                    input send_done);           // High when Keyboard Module is send done 

    localparam IDLE = 3'b000, CHECK = 3'b001, SEND = 3'b010, GET = 3'b011, CLEAR = 3'b100;  // State Machine's five valid states
    localparam CHECK_CODE = 2'b00, GET_CODE = 2'b01, SEND_CODE = 2'b10, CLEAR_CODE = 2'b11; // Four Pattern mapping four functions

    localparam ADMIN_PASSWORD = 8'b11111111; // ADMIN_PASSWORD manages the permission to add and clear fingerprints

    //----------------------------------------------------------------------------------------------
    // State Machine(Three sections coding style)
    //----------------------------------------------------------------------------------------------
    reg [2:0] present_state = IDLE, next_state = IDLE;
    
    always @(posedge clk or negedge rst_n)
    begin
        if (~rst_n)
        begin
            present_state <= IDLE;
        end
        else 
            present_state <= next_state;
    end
    
    //----------------------------------------------------------------------------------------------
    // State Machine Logic
    //----------------------------------------------------------------------------------------------
    always @(*)
    begin
        case (present_state)
            IDLE:
            if((SW == CHECK_CODE || SW == SEND_CODE) && Finger_input)
                next_state = CHECK;
            else if(SW == GET_CODE && Finger_input && admin_pwd == ADMIN_PASSWORD)
                next_state = GET;
            else if(SW == CLEAR_CODE && Finger_input && admin_pwd == ADMIN_PASSWORD)
                next_state = CLEAR;
            else
                next_state = IDLE;

            CHECK:
            if(~FM_done)
                next_state = CHECK;
            else if(Error && FM_done && SW != SEND_CODE)
                next_state = IDLE;
            else if(~Error && FM_done && SW == SEND_CODE)
                next_state = SEND;
            else
                next_state = IDLE;

            SEND:
            if(~send_done)
                next_state = SEND;
            else
                next_state = IDLE;
            
            GET:
            if(~FM_done)
                next_state = GET;
            else
                next_state = IDLE;
            
            CLEAR:
            if(~FM_done)
                next_state = CLEAR;
            else
                next_state = IDLE;
        endcase
    end

    //----------------------------------------------------------------------------------------------
    // Output Logic(Use next_state to control the output)
    //----------------------------------------------------------------------------------------------
    always @(posedge clk) begin
        if (~rst_n)
            send <= 0;
        else begin
            case(next_state)                                       
                IDLE : {check, get, clear, send} = 4'b0000;
                CHECK: {check, get, clear, send} = 4'b1000;
                GET  : {check, get, clear, send} = 4'b0100;
                SEND : {check, get, clear, send} = 4'b0001; 
                CLEAR: {check, get, clear, send} = 4'b0010;
                default: {check, get, clear, send} = 4'b0000;
            endcase
        end
    end

endmodule