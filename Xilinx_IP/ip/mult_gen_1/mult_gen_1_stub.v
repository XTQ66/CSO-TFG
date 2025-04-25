// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Tue Mar 18 21:15:47 2025
// Host        : DESKTOP-1G03M0T running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               e:/FOF_TFG/FOF_TFG_RTL/FOF_TFG_RTL.srcs/sources_1/ip/mult_gen_1/mult_gen_1_stub.v
// Design      : mult_gen_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z100ffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "mult_gen_v12_0_15,Vivado 2019.1" *)
module mult_gen_1(CLK, A, B, P)
/* synthesis syn_black_box black_box_pad_pin="CLK,A[62:0],B[62:0],P[125:0]" */;
  input CLK;
  input [62:0]A;
  input [62:0]B;
  output [125:0]P;
endmodule
