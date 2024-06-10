#####################################
# Design Parameters
#####################################
set num_qdma      1
set num_phys_func 2
set num_queue     2048
set min_pkt_len   64
set max_pkt_len   1518

#####################################
# Project Structure & IP Build
#####################################
if {[string match $board_name "au280"]} {
	set_property verilog_define { {__synthesis__} {__au280__}} [current_fileset]
} elseif {[string match $board_name "au250"]} {
	set_property verilog_define { {__synthesis__} {__au250__}} [current_fileset]
} elseif {[string match $board_name "au200"]} {
	set_property verilog_define { {__synthesis__} {__au200__}} [current_fileset]
} elseif {[string match $board_name "vcu1525"]} {
	set_property verilog_define { {__synthesis__} {__au200__}} [current_fileset]
} else {
	puts "Error: ${board_name} is not found."
	exit -1
}

if {[string match $board_name "au280"]} {
	source "${XILINX_SHELL_PATH}/open-nic-shell/src/cmac_subsystem/vivado_ip/cmac_usplus_0_au280.tcl"
} elseif {[string match $board_name "au250"]} {
	source "${XILINX_SHELL_PATH}/vivado_ip/cmac_usplus_0_au250.tcl"
} elseif {[string match $board_name "au200"]} {
	source "${XILINX_SHELL_PATH}/vivado_ip/cmac_usplus_0_au250.tcl"
} elseif {[string match $board_name "vcu1525"]} {
	source "${XILINX_SHELL_PATH}/vivado_ip/cmac_usplus_0_vcu1525.tcl"
}

if {[string match $board_name "au280"]} {
	source "${XILINX_SHELL_PATH}/open-nic-shell/src/cmac_subsystem/vivado_ip/cmac_usplus_1_au280.tcl"
} elseif {[string match $board_name "au250"]} {
	source "${XILINX_SHELL_PATH}/vivado_ip/cmac_usplus_1_au250.tcl"
} elseif {[string match $board_name "au200"]} {
	source "${XILINX_SHELL_PATH}/vivado_ip/cmac_usplus_1_au250.tcl"
} elseif {[string match $board_name "vcu1525"]} {
	source "${XILINX_SHELL_PATH}/vivado_ip/cmac_usplus_1_vcu1525.tcl"
}

if {[string match $board_name "au280"]} {
	source "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/vivado_ip/qdma_no_sriov_au280.tcl"
} elseif {[string match $board_name "au250"]} {
	source "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/vivado_ip/qdma_no_sriov_au250.tcl"
} elseif {[string match $board_name "au200"]} {
	source "${XILINX_SHELL_PATH}/vivado_ip/qdma_no_sriov_au200.tcl"
} elseif {[string match $board_name "vcu1525"]} {
	source "${XILINX_SHELL_PATH}/vivado_ip/qdma_no_sriov_vcu1525.tcl"
}

source "${XILINX_SHELL_PATH}/open-nic-shell/src/cmac_subsystem/vivado_ip/cmac_subsystem_axi_crossbar.tcl"
source "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/vivado_ip/qdma_subsystem_axi_cdc.tcl"
source "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/vivado_ip/qdma_subsystem_axi_crossbar.tcl"
source "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/vivado_ip/qdma_subsystem_clk_div.tcl"
source "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/vivado_ip/qdma_subsystem_c2h_ecc.tcl"
source "${XILINX_SHELL_PATH}/open-nic-shell/src/system_config/vivado_ip/system_config_axi_crossbar.tcl"
source "${XILINX_SHELL_PATH}/open-nic-shell/src/system_config/vivado_ip/system_management_wiz.tcl"
source "${XILINX_SHELL_PATH}/open-nic-shell/src/system_config/vivado_ip/clk_wiz_50Mhz.tcl"
source "${XILINX_SHELL_PATH}/open-nic-shell/src/system_config/vivado_ip/axi_quad_spi_0.tcl"
source "${XILINX_SHELL_PATH}/open-nic-shell/src/system_config/vivado_ip/cms_subsystem_0.tcl"
source "${XILINX_SHELL_PATH}/open-nic-shell/src/utility/vivado_ip/axi_lite_clock_converter.tcl"

upgrade_ip [get_ips]
generate_target synthesis [get_ips]

read_verilog -sv "${XILINX_SHELL_PATH}/hdl/open_nic_shell.sv"

read_verilog     "${XILINX_SHELL_PATH}/open-nic-shell/src/open_nic_shell_macros.vh"
read_verilog     "${XILINX_SHELL_PATH}/open-nic-shell/src/cmac_subsystem/cmac_subsystem_address_map.v"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/cmac_subsystem/cmac_subsystem_cmac_wrapper.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/cmac_subsystem/cmac_subsystem.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/qdma_subsystem_address_map.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/qdma_subsystem_c2h.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/qdma_subsystem_function_register.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/qdma_subsystem_function.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/qdma_subsystem_h2c.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/qdma_subsystem_hash.sv"
read_verilog     "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/qdma_subsystem_qdma_wrapper.v"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/qdma_subsystem_register.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/qdma_subsystem/qdma_subsystem.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/system_config/cms_subsystem.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/system_config/system_config_address_map.sv"
read_verilog     "${XILINX_SHELL_PATH}/open-nic-shell/src/system_config/system_config_register.v"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/system_config/system_config.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/utility/axi_lite_register.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/utility/axi_lite_slave.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/utility/axi_stream_register_slice.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/utility/axi_stream_size_counter.sv"
read_verilog     "${XILINX_SHELL_PATH}/open-nic-shell/src/utility/crc32.v"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/utility/generic_reset.sv"
read_verilog -sv "${XILINX_SHELL_PATH}/open-nic-shell/src/utility/rr_arbiter.sv"



