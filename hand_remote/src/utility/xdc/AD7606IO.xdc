set_property IOSTANDARD LVCMOS33 [get_ports {data[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[0]}]
set_property PACKAGE_PIN N1 [get_ports {data[14]}]
set_property PACKAGE_PIN P4 [get_ports {data[12]}]
set_property PACKAGE_PIN M5 [get_ports {data[10]}]
set_property PACKAGE_PIN R2 [get_ports {data[8]}]
set_property PACKAGE_PIN R3 [get_ports {data[6]}]
set_property PACKAGE_PIN T4 [get_ports {data[4]}]
set_property PACKAGE_PIN L5 [get_ports {data[2]}]
set_property PACKAGE_PIN L13 [get_ports {data[0]}]
set_property PACKAGE_PIN P1 [get_ports {data[15]}]
set_property PACKAGE_PIN P3 [get_ports {data[13]}]
set_property PACKAGE_PIN N4 [get_ports {data[11]}]
set_property PACKAGE_PIN R1 [get_ports {data[9]}]
set_property PACKAGE_PIN T2 [get_ports {data[7]}]
set_property PACKAGE_PIN T3 [get_ports {data[5]}]
set_property PACKAGE_PIN P5 [get_ports {data[3]}]
set_property PACKAGE_PIN N12 [get_ports {data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {os[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {os[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {os[0]}]
set_property PACKAGE_PIN M12 [get_ports {os[2]}]
set_property PACKAGE_PIN N13 [get_ports {os[1]}]
set_property PACKAGE_PIN N14 [get_ports {os[0]}]
set_property PACKAGE_PIN N16 [get_ports areg]
set_property PACKAGE_PIN P16 [get_ports cvb]
set_property PACKAGE_PIN R16 [get_ports rd_n]
set_property PACKAGE_PIN R12 [get_ports busy]
set_property PACKAGE_PIN T12 [get_ports cs_n]
set_property PACKAGE_PIN P15 [get_ports cva]
set_property PACKAGE_PIN R15 [get_ports rst_ad7606]
set_property PACKAGE_PIN P13 [get_ports tx]
set_property PACKAGE_PIN K15 [get_ports rst_n]
set_property PACKAGE_PIN N11 [get_ports clk_50]

set_property PACKAGE_PIN R6  [get_ports led_kai]
set_property PACKAGE_PIN T5 [get_ports led_guan]
set_property PACKAGE_PIN B7  [get_ports key_kai]
set_property PACKAGE_PIN M6  [get_ports key_guan]

set_property IOSTANDARD LVCMOS33 [get_ports led_kai]
set_property IOSTANDARD LVCMOS33 [get_ports led_guan]
set_property IOSTANDARD LVCMOS33 [get_ports key_kai]
set_property IOSTANDARD LVCMOS33 [get_ports key_guan]

set_property IOSTANDARD LVCMOS33 [get_ports areg]
set_property IOSTANDARD LVCMOS33 [get_ports busy]
set_property IOSTANDARD LVCMOS33 [get_ports cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports clk_50]
set_property IOSTANDARD LVCMOS33 [get_ports cva]
set_property IOSTANDARD LVCMOS33 [get_ports cvb]
set_property IOSTANDARD LVCMOS33 [get_ports rd_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_ad7606]
set_property IOSTANDARD LVCMOS33 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_50_IBUF_BUFG]
