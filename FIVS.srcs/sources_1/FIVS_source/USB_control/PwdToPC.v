`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Peking University
// Engineer: HovenChan
//
// Create Date: 2022/05/17 22:56:34
// Design Name: USB 2.0 HID Keyboard
// Module Name: PwdToPC
// Project Name: Fingerprint Identification and Verification System
// Target Devices: Aritx-7
// Tool Versions: Vivado 2018.3
// Description: A module act as a USB 2.0 HID keyboard at Full Speed (12Mbps)
//
// Dependencies:
//
// Revision:
// Revision 0.10 - File Created
// Additional Comments: Receive the send_request from State Machine Module and 
//                      imitate a USB HID keyboard to send the password to the PC.
//                      send_done outputs a clock cycle pulses at the end of each transmission.
//
//////////////////////////////////////////////////////////////////////////////////


module PwdToPC #(parameter SIZE = 7)
                (input clk60mhz,            // connect to a 60MHz oscillator
                 input clk_locked,          // 1 when the clock is stable
                 input wire rstn_button,    // connect to a reset_n button, 0 is pressed, 1 is normal working
                 output wire usb_dp_pull,   // connect to USB D+ by an 1.5k resistor
                 inout usb_dp,              // connect to USB D+
                 inout usb_dn,              // connect to USB D-
                 input send_request,        // send_enable signal
                 input [3:0]pwd_code,       // password code
                 output reg send_done = 0  // send done signal to state machine
                 );
    
    //-------------------------------------------------------------------------------------------------------------------------------------
    // Password Manager
    //-------------------------------------------------------------------------------------------------------------------------------------
    parameter PWD_MAXLEN = 16, BYTE_LEN = 8;
    wire [6:0] password;
    integer pointer = PWD_MAXLEN;
    wire [8 * PWD_MAXLEN - 1:0] password_string;
    
    PwdMgr PwdMgr_0(
    .pwd_code(pwd_code),
    .password(password_string)
    );
    
    assign password[0] = password_string[(pointer - 1) * BYTE_LEN];
    assign password[1] = password_string[(pointer - 1) * BYTE_LEN + 1];
    assign password[2] = password_string[(pointer - 1) * BYTE_LEN + 2];
    assign password[3] = password_string[(pointer - 1) * BYTE_LEN + 3];
    assign password[4] = password_string[(pointer - 1) * BYTE_LEN + 4];
    assign password[5] = password_string[(pointer - 1) * BYTE_LEN + 5];
    assign password[6] = password_string[(pointer - 1) * BYTE_LEN + 6];
    
    //-------------------------------------------------------------------------------------------------------------------------------------
    // use USB-HID device to implement a keyboard
    //-------------------------------------------------------------------------------------------------------------------------------------
    localparam INPUT_INTERVAL = 6_000_000;    // 0.1s, the interval time of each word.(time = INPUT_INTERVAL / f_clk)
    reg [31:0] count          = 0;             // count is a clock counter that runs from 0 to INPUT_INTERVAL, each period takes 0.2 seconds
    reg        key_request    = 0;              // 1 when is time to send a word
    reg [15:0] key_value      = 16'h0000;
    
    always @ (posedge clk60mhz)
        if (send_request && ~send_done)begin
            if (pointer > 0) begin
                if (count < INPUT_INTERVAL) begin
                    count       <= count + 1;
                    key_request <= 1'b0;
                end
                else begin
                    count       <= 0;
                    key_request <= 1'b1;
                    case (password) // ASCII to USB2.0 HID UsageID
                        10'd10 : key_value <= 16'h0058;

                        //1-9、0
                        10'd49 : key_value <= 16'h001e;
                        10'd50 : key_value <= 16'h001f;
                        10'd51 : key_value <= 16'h0020;
                        10'd52 : key_value <= 16'h0021;
                        10'd53 : key_value <= 16'h0022;
                        10'd54 : key_value <= 16'h0023;
                        10'd55 : key_value <= 16'h0024;
                        10'd56 : key_value <= 16'h0025;
                        10'd57 : key_value <= 16'h0026;
                        10'd48 : key_value <= 16'h0027;
                        
                        //A-Z
                        10'd65 : key_value <= 16'h0204;
                        10'd66 : key_value <= 16'h0205;
                        10'd67 : key_value <= 16'h0206;
                        10'd68 : key_value <= 16'h0207;
                        10'd69 : key_value <= 16'h0208;
                        10'd70 : key_value <= 16'h0209;
                        10'd71 : key_value <= 16'h020a;
                        10'd72 : key_value <= 16'h020b;
                        10'd73 : key_value <= 16'h020c;
                        10'd74 : key_value <= 16'h020d;
                        10'd75 : key_value <= 16'h020e;
                        10'd76 : key_value <= 16'h020f;
                        10'd77 : key_value <= 16'h0210;
                        10'd78 : key_value <= 16'h0211;
                        10'd79 : key_value <= 16'h0212;
                        10'd80 : key_value <= 16'h0213;
                        10'd81 : key_value <= 16'h0214;
                        10'd82 : key_value <= 16'h0215;
                        10'd83 : key_value <= 16'h0216;
                        10'd84 : key_value <= 16'h0217;
                        10'd85 : key_value <= 16'h0218;
                        10'd86 : key_value <= 16'h0219;
                        10'd87 : key_value <= 16'h021a;
                        10'd88 : key_value <= 16'h021b;
                        10'd89 : key_value <= 16'h021c;
                        10'd90 : key_value <= 16'h021d;
                        
                        //a-z
                        10'd97 : key_value  <= 16'h0004;
                        10'd98 : key_value  <= 16'h0005;
                        10'd99 : key_value  <= 16'h0006;
                        10'd100 : key_value <= 16'h0007;
                        10'd101 : key_value <= 16'h0008;
                        10'd102 : key_value <= 16'h0009;
                        10'd103 : key_value <= 16'h000a;
                        10'd104 : key_value <= 16'h000b;
                        10'd105 : key_value <= 16'h000c;
                        10'd106 : key_value <= 16'h000d;
                        10'd107 : key_value <= 16'h000e;
                        10'd108 : key_value <= 16'h000f;
                        10'd109 : key_value <= 16'h0010;
                        10'd110 : key_value <= 16'h0011;
                        10'd111 : key_value <= 16'h0012;
                        10'd112 : key_value <= 16'h0013;
                        10'd113 : key_value <= 16'h0014;
                        10'd114 : key_value <= 16'h0015;
                        10'd115 : key_value <= 16'h0016;
                        10'd116 : key_value <= 16'h0017;
                        10'd117 : key_value <= 16'h0018;
                        10'd118 : key_value <= 16'h0019;
                        10'd119 : key_value <= 16'h001a;
                        10'd120 : key_value <= 16'h001b;
                        10'd121 : key_value <= 16'h001c;
                        10'd122 : key_value <= 16'h001d;
                        
                        default key_value <= 16'h0000;    // ignore the key if not in range 0-9、a-z、A-Z
                    endcase
                    pointer <= pointer - 1;
                end
            end
            else begin
                send_done <= 1;
            end
        end
        else begin
            pointer   <= PWD_MAXLEN;
            send_done <= 0;
        end
    
    usb_hid_top usb_hid_keyboard_0 (
    .rstn            (clk_locked & rstn_button),
    .clk             (clk60mhz),
    
    // USB signals
    .usb_dp_pull     (usb_dp_pull),
    .usb_dp          (usb_dp),
    .usb_dn          (usb_dn),
    
    // HID keyboard press signal
    .key_value       (key_value),     // key_value is the USB UsageID of the key
    .key_request     (key_request)    // key_request = 1 pulse every 0.2 seconds. It means the keyboard will press a key every 0.2 seconds.
    );
    
endmodule
