# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param synth.incrementalSynthesisCache C:/Users/Administrator/Desktop/FIVS/.Xil/Vivado-14216-CDJD-01/incrSyn
set_param xicom.use_bs_reader 1
set_msg_config -id {Synth 8-256} -limit 10000
set_msg_config -id {Synth 8-638} -limit 10000
create_project -in_memory -part xc7a35tcpg236-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir C:/Users/Administrator/Desktop/FIVS/FIVS.cache/wt [current_project]
set_property parent.project_path C:/Users/Administrator/Desktop/FIVS/FIVS.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo c:/Users/Administrator/Desktop/FIVS/FIVS.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
add_files C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/USB_control/data.coe
read_verilog -library xil_defaultlib -sv {
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/ip/usbfs_core/usbfs_bitlevel.sv
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/ip/usbfs_core/usbfs_core_top.sv
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/ip/usbfs_core/usbfs_packet_rx.sv
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/ip/usbfs_core/usbfs_packet_tx.sv
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/ip/usbfs_core/usbfs_transaction.sv
}
read_verilog -library xil_defaultlib {
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/FPcontrol.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/USB_control/PwdMgr.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/USB_control/PwdToPC.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/StateMachine.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/stateCheck.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/stateCheck001.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/stateCheck010.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/stateClear.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/stateClear001.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/stateClear010.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/stateGetFP.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/stateGetFP001.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/stateGetFP010.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/stateGetFP011.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/stateGetFP100.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/usart232_rx.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FPcontrol/usart232_tx.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/USB_control/usb_hid_top.v
  C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/FIVS_source/FIVS_top.v
}
read_ip -quiet C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_ooc.xdc]

read_ip -quiet C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_board.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc]
set_property used_in_implementation false [get_files -all c:/Users/Administrator/Desktop/FIVS/FIVS.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/constrs_1/new/FIVS.xdc
set_property used_in_implementation false [get_files C:/Users/Administrator/Desktop/FIVS/FIVS.srcs/constrs_1/new/FIVS.xdc]

set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top FIVS_top -part xc7a35tcpg236-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef FIVS_top.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file FIVS_top_utilization_synth.rpt -pb FIVS_top_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
