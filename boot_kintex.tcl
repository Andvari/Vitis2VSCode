connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Platform Cable USB II 13724327082d01" && level==0 && jtag_device_ctx=="jsn-DLC10-13724327082d01-43651093-0"}
fpga -file /home/nemo/workspace/FPGA/Kintex/Microblaze/sw/microblaze/_ide/bitstream/download.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow /home/nemo/workspace/FPGA/Kintex/Microblaze/sw/microblaze/Debug/microblaze.elf
con
