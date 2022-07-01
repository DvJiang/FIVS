`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Peking University
// Engineer: HovenChan
//
// Create Date: 2022/05/17 22:36:34
// Design Name: USB 2.0 HID Keyboard
// Module Name: usb_hid_top
// Project Name: Fingerprint Identification and Verification System
// Target Devices: Aritx-7
// Tool Versions: Vivado 2018.3
// Description: A USB Full Speed (12Mbps) device, act as a USB HID keyboard
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments: USB HID Keyboard's top
//
//////////////////////////////////////////////////////////////////////////////////

module usb_hid_top (input wire rstn,             // active-low reset, reset when rstn = 0 (USB will unplug when reset), normally set to 1
                    input wire clk,              // 60MHz is required
                    output wire usb_dp_pull,     // connect to USB D+ by an 1.5k resistor
                    inout usb_dp,                // USB D+
                    inout usb_dn,                // USB D-
                    input wire [15:0] key_value, // Indicates which key to press, NOT ASCII code! see https://www.usb.org/sites/default/files/hut1_21_0.pdf section 10.
                    input wire key_request);     // when key_request = 1 pulses, a key is pressed.
    
    
    //-------------------------------------------------------------------------------------------------------------------------------------
    // descriptor ROM and ROM-read logic
    //-------------------------------------------------------------------------------------------------------------------------------------
    wire [9:0] desc_addr;
    wire [7:0] desc_data;
    blk_mem_gen_0 parameter_rom(
    .clka(clk),
    .addra(desc_addr),
    .douta(desc_data)
    );

    //-------------------------------------------------------------------------------------------------------------------------------------
    // HID keyboard's parameter. 
    // Now use vivado's ROM ip, data is stored in data.coe. 
    // keep these comments for easy debugging and modify.
    //-------------------------------------------------------------------------------------------------------------------------------------
    // wire [7:0] descriptor_rom [0:1023] = {
    //     // device descriptor                                                        offset = 0x000(should fixed)  available-space = 0x020
    //     8'h12, // bLength:该描述符的长度为18字节
    //     8'h01, // bDescriptorType:本描述符的类型是设备描述符
    //     8'h10, //bcdUSB: USB版本协议，低字节在前，高字节在后，这里是USB1.1
    //     8'h01,
    //     8'h00, //bDeviceClass: 设备类型
    //     8'h00, //bDeviceSubClass: 子类型
    //     8'h00, //bDeviceProtocol: 设备使用的协议
    //     8'h20, //bMaxPackeSize0: 端点0最大传输字节数，这里是32字节
    //     8'h9a, //idVendor(VID): 厂商ID
    //     8'hfb,
    //     8'h9a, //idProduct(PID): 产品ID
    //     8'hfb,
    //     8'h72, //bcdDevice: 产品版本号
    //     8'h00,
    //     8'h01, //IManufacturer: 厂商字符串索引
    //     8'h02, //iProduct: 产品字符串索引
    //     8'h00, //iSerialNumber：产品序列号字符串索引
    //     8'h01, //bNumConfigurations: 标识设备支持的配置数量
    //     8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, //空余
    
    //     // string descriptor 0 (supported languages)                                offset = 0x020(should fixed)  available-space = 0x020
    //     8'h04,  8'h03, 8'h09, 8'h04,
    //     8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
    
    //     // string descriptor 1 (manufacturer, if any)                               offset = 0x040(should fixed)  available-space = 0x040
    //     8'h0A, 8'h03, "F"  , 8'h00, "I"  , 8'h00, "V"  , 8'h00, "S"  ,
    //     8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00 , 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,  8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
    
    //     // string descriptor 2 (product, if any)                                    offset = 0x080(should fixed)  available-space = 0x040
    //     8'h1A, 8'h03, "F"  , 8'h00, "P"  , 8'h00, "G"  , 8'h00, "A"  , 8'h00, " "  , 8'h00, "U"  , 8'h00, "S"  , 8'h00, "B"  , 8'h00, "-"  , 8'h00, "H"  , 8'h00, "I"  , 8'h00, "D"  , 8'h00,
    //     8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
    
    //     // string descriptor 3 (serial-number, if any)                              offset = 0x0C0(should fixed)  available-space = 0x040
    //     8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
    
    //     // configuration descriptor set                                             offset = 0x100(should fixed)  available-space = 0x200
    //     // 1)configuration descriptor（配置描述符）
    //     8'h09, //bLength: 配置描述符长度
    //     8'h02, //bDescriptorType：配置描述符类型
    //     8'h22, //wTotalLength: 配置描述符集合总长度（34字节）重要！！！
    //     8'h00,
    //     8'h01, //bNumInterfaces:接口描述符个数
    //     8'h01, //bConfigurationValue：当前配置的标识，是SetConfiguration命令需要的参数值
    //     8'h00, //iConfiguration： 描述该配置的字符串的索引值
    //     8'hC0, //bmAttributes:配置特征，供电模式的选择，这里是11000000，表示自供电模式
    //     8'h64, //MaxPower: 在这个配置下，设备需要的电流（200mA）
    
    //     // 2)interface descriptor
    //     8'h09, //bLength: 接口描述符长度
    //     8'h04, //bDescriptorType: 接口描述符类型
    //     8'h00, //bInterfaceNumber: 接口编号
    //     8'h00, //bAlternateSetting: 接口备用号
    //     8'h01, //bNumEndpoints：端点个数
    //     8'h03, //bInterfaceClass：接口类型，这里03表示HID设备
    //     8'h01, //bInterfaceSubClass：接口子类，1表示支持引导，表示在BIOS界面就可以使用了
    //     8'h01, //bInterfaceProtocol：接口协议，1表示键盘协议
    //     8'h00, //iInterface:接口字符串索引值
    
    //      // 3)HID descriptor
    //     8'h09, //bLength: 接口描述符长度
    //     8'h21, //bDescriptorType: 接口描述符类型
    //     8'h11, //bcdHID: HID版本号1.11（低字节在前，高字节在后）
    //     8'h01,
    //     8'h00, //bCountryCode:HID国家/地区代码，美式键盘是33，即0x21，00表示不支持
    //     8'h01, //bNumberDescriptor:包含一个下级描述符
    //     8'h22, //bDescriptorType: 下级描述符的类型，夏季描述符第一个必须是报告描述符（0x22）
    //     8'h3f, //wDescriptorLength: 下级描述符的长度，每种HID设备的报告描述符长度是不一样的，这里是63字节
    //     8'h00,
    
    //      // 4)endpoint descriptor (IN)
    //     8'h07, //bLength: 端点描述符长度
    //     8'h05, //bDescriptorType: 端点描述符类型
    //     8'h81, //bEndpointAddress: 端点地址（bit3-0：端点编号；bit6-4：保留，默认为1；bit7：数据传输方向，1表示输入，0表示输出），这里传输方向为输入（从主机看）
    //     8'h03, //bmAttributes: 端点属性（设置为中断传输）
    //     8'h08, //wMaxPackeSize: 最大包长度
    //     8'h00,
    //     8'h64, //bInterval: 端点查询时间（主机多久给设备发送一次数据请求）这里设置为100ms （全速设备1-255ms）
    
    //     8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,//空余填充
    
    //     // HID descriptor (if any)  键盘的报告描述符                                   offset = 0x300(should fixed)  available-space = 0x100
    //     8'h05, 8'h01,   // USAGE_PAGE (Generic Desktop)
    //     8'h09, 8'h06,   // USAGE (Keyboard)
    //     8'ha1, 8'h01,   // COLLECTION (Application)
    //     8'h05, 8'h07,   // USAGE_PAGE (Keyboard)
    
    //     //(1)键盘的八个控制键，每个控制键对应1个bit，共1个字节(Right Win, Right Alt, Right Shift, Right Control, Left Win, Left Alt, Left Shift, Left Control)
    //     8'h19, 8'he0,   // USAGE_MINIMUM (Keyboard LeftControl)
    //     8'h29, 8'he7,   // USAGE_MAXIMUM (Keyboard Right GUI)
    //     8'h15, 8'h00,   // LOGICAL_MINIMUM (0)
    //     8'h25, 8'h01,   // LOGICAL_MAXIMUM (1)
    //     8'h75, 8'h01,   // REPORT_SIZE (1)
    //     8'h95, 8'h08,   // REPORT_COUNT (8)
    //     8'h81, 8'h02,   // INPUT (Data,Var,Abs)
    
    //     //(2)键盘数据的第二个字节是保留的，且为常量
    //     8'h95, 8'h01,   // REPORT_COUNT (1)
    //     8'h75, 8'h08,   // REPORT_SIZE (8)
    //     8'h81, 8'h03,   // INPUT (Cnst,Var,Abs)
    
    //     //(3)键盘的LED输出，例如键盘上的大小写字母灯，数字锁定灯等等，用了5个bit
    //     8'h95, 8'h05,   // REPORT_COUNT (5)
    //     8'h75, 8'h01,   // REPORT_SIZE (1)
    //     8'h05, 8'h08,   // USAGE_PAGE (LEDs)
    //     8'h19, 8'h01,   // USAGE_MINIMUM (Num Lock)
    //     8'h29, 8'h05,   // USAGE_MAXIMUM (Kana)
    //     8'h91, 8'h02,   // OUTPUT(Data,Var,Abs)
    
    //     //(4)没有实际意义的3个填充常量bit
    //     8'h95, 8'h01,   // REPORT_COUNT (1)
    //     8'h75, 8'h03,   // REPORT_SIZE (3)
    //     8'h91, 8'h03,   // OUTPUT (Cnst,Var,Abs)
    
    //     //(5)六个字节的键盘键值（一个字节一个键），没有固定位置
    //     8'h95, 8'h06,   // REPORT_COUNT (6)
    //     8'h75, 8'h08,   // REPORT_SIZE (8)
    //     8'h15, 8'h00,   // LOGICAL_MINIMUM (0)
    //     8'h25, 8'hff,   // LOGICAL_MAXIMUM (25)
    //     8'h05, 8'h07,   // USAGE_PAGE (Keyboard)
    //     8'h19, 8'h00,   // USAGE_MINIMUM (Reserved (no event indicated))
    //     8'h29, 8'h65,   // USAGE_MAXIMUM (Keyboard Application)
    //     8'h81, 8'h00,   // INPUT (Data,Ary,Abs)
    //     8'hc0,//键盘描述符到此结束
    
    //     8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
    // };
    
    // wire [9:0] desc_addr;
    // reg  [7:0] desc_data = 0;
    // always @ (posedge clk) desc_data <= descriptor_rom[desc_addr];
    
    
    //-------------------------------------------------------------------------------------------------------------------------------------
    // HID keyboard IN data packet process
    //-------------------------------------------------------------------------------------------------------------------------------------
    wire        usb_rstn;
    reg  [23:0] in_data  = 0;
    reg         in_valid = 0;
    reg  [4:0] in_cnt    = 0;
    wire        in_ready;
    
    always @ (posedge clk)
        if (~usb_rstn) begin
            in_data  <= 0;
            in_valid <= 1'b0;
            in_cnt   <= 0;   // in_data 输出计数器，最多16字节
        end
        else if (in_cnt == 5'd0) begin
            in_data <= {key_value[7:0], 8'h0, key_value[15:8]};
            if (key_request) begin
                in_valid <= 1'b1;
                in_cnt   <= 5'd1;
            end
        end
        else if (in_cnt < 5'd17) begin
            if (in_ready) begin
                in_data <= {8'h0, in_data[23:8]}; //串行移位寄存器，低位先输出
                in_cnt  <= in_cnt + 5'd1;
            end
        end
        else begin
            in_valid <= 1'b0;
            in_cnt   <= 0;
        end
    
    
    //-------------------------------------------------------------------------------------------------------------------------------------
    // USB full-speed core
    //-------------------------------------------------------------------------------------------------------------------------------------
    usbfs_core_top #(
    .ENDP_81_MAXPKTSIZE (10'd8)
    ) usbfs_core_i (
    .rstn            (rstn),
    .clk             (clk),
    .usb_dp_pull     (usb_dp_pull),
    .usb_dp          (usb_dp),
    .usb_dn          (usb_dn),
    .usb_rstn        (usb_rstn),
    .desc_addr       (desc_addr),
    .desc_data       (desc_data),
    .out_data        (),
    .out_valid       (),
    .in_data         (in_data[7:0]),
    .in_valid        (in_valid),
    .in_ready        (in_ready)
    );
    
endmodule
