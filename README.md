# CSO-TFG
Note: This project is protected by a patent ( ZL 2024 1 1958937.X ) and can NOT be used for any commercial purpose.\\
(1) Software running environment is Python 3.8, anaconda with Pycharm 2022.\\
(2) The hardware environment is Vivado 2019.\\
(3) Note: The .v file in /RTL_SOURCE contains the free IP from Xilinx, so to run it you need to add the . /Xilinx_IP/ip folder into Vivado 2019.1 along with the .v file.\\
(4) Note: This design is n=16 and LAT=8,if you want to replace the multiplier ip,you must make sure that the total LAT of the multiplier and MR is equal to 8,otherwise it will lead to wrong results.\\
(5) This design has been verified with Python Reference for a preliminary functional verification.\\
(6) Note: The design used to be named as FFO-TFG. so some of the source files are named this.\\
(7) The Result_Case./Output.txt is the hardware generated TFs of (N = 65536, q = 2305843009221820417, phi = 2(for simplify) , n =16).\\
(8) The involved Xilinx IPs are not used in any commercial scenarios.\\
