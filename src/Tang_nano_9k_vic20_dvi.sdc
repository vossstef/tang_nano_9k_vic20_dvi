//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.11 Education
//Created Time: 2023-07-24 20:12:15
create_clock -name I_CLK_REF -period 37 -waveform {0 18} [get_ports {I_CLK_REF}]
//create_clock -name clock_35MHz -period 30.864 -waveform {0 14.286} [get_nets {clock_35MHz}]

