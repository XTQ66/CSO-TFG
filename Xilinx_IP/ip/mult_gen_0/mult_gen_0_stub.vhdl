-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
-- Date        : Wed Mar 26 15:01:07 2025
-- Host        : DESKTOP-1G03M0T running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top mult_gen_0 -prefix
--               mult_gen_0_ mult_gen_0_stub.vhdl
-- Design      : mult_gen_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z100ffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mult_gen_0 is
  Port ( 
    CLK : in STD_LOGIC;
    A : in STD_LOGIC_VECTOR ( 61 downto 0 );
    B : in STD_LOGIC_VECTOR ( 61 downto 0 );
    P : out STD_LOGIC_VECTOR ( 123 downto 0 )
  );

end mult_gen_0;

architecture stub of mult_gen_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "CLK,A[61:0],B[61:0],P[123:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "mult_gen_v12_0_15,Vivado 2019.1";
begin
end;
