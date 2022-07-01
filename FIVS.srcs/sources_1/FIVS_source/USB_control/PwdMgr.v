`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Peking University
// Engineer: HovenChan
//
// Create Date: 2022/05/30 21:52:30
// Design Name: Password Manager Module
// Module Name: PwdMgr
// Project Name: Fingerprint Identification and Verification System
// Target Devices: Aritx-7
// Tool Versions: Vivado 2018.3
// Description: Password Manager of the project
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Manage the passwords. pwd_code is the select signal,
//                      password is output password.
//
//////////////////////////////////////////////////////////////////////////////////


module PwdMgr #(parameter PASSWORD_MAXLEN = 16)
               (input [3:0] pwd_code,
                output reg [PASSWORD_MAXLEN * 8 - 1:0] password);
    
    localparam password0 = "MYID1900013355";
    localparam password1 = "mypwd123456";
    localparam password2 = "3456789012ghi";
    localparam password3 = "4567890123jkl";
    localparam password4 = "5678901234mno";
    localparam password5 = "6789012345pqr";
    localparam password6 = "7890123456stu123";
    localparam password7 = "";
    localparam password8 = "";
    localparam password9 = "";
    
    
    always @(pwd_code) begin
        case(pwd_code)
            4'd1: password   <= password0;
            4'd2: password   <= password1;
            4'd3: password   <= password2;
            4'd4: password   <= password3;
            4'd5: password   <= password4;
            4'd6: password   <= password5;
            4'd7: password   <= password6;
            4'd8: password   <= password7;
            4'd9: password   <= password8;
            4'd10: password   <= password9;
            default:password <= "stackoverflow";
        endcase
    end
    
endmodule
