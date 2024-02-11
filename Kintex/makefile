
family=Kintex
kernel=microblaze
APP_NAME=microblaze
build=Release
ws=proj
plat_name=design_1_wrapper
xsa=/home/nemo/workspace/FPGA/$(family)/$(APP_NAME)/hw/design_1_wrapper.xsa
domain_name_apu=standalone_$(kernel)_0
sys_name=$(APP_NAME)_system

init:
	if [ -d "$(ws)/$(APP_NAME)/src" ]; then tar cf src.tar "$(ws)/$(APP_NAME)/src"; fi
	if [ -d "$(ws)" ]; then rm -f -d -r $(ws); fi
	if [ -d ".Xil" ]; then rm -f -d -r ".Xil"; fi
	xsct -eval "setws $(ws); \
	platform create -name $(plat_name) -hw $(xsa); \
	domain create -name $(domain_name_apu) -os standalone -proc $(kernel)_0; \
	app create -name $(APP_NAME) -platform $(plat_name) -domain $(domain_name_apu) -sysproj $(sys_name) -template {Hello World}; \
	platform active $(plat_name); \
	platform generate; \
	app config -name $(APP_NAME) build-config $(build); "
#	app build -all; "

	rm -f -d -r .Xil
	rm -f -d -r $(ws)/$(sys_name)

	if [ -e $(ws)/$(APP_NAME)/src/lscript.ld ]; then mv $(ws)/$(APP_NAME)/src/lscript.ld .; fi
	if [ -e src.tar ]; then rm -f -d -r $(ws)/$(APP_NAME)/src; tar xvf src.tar; rm -f src.tar; fi
	if [ -e lscript.ld ]; then mv lscript.ld $(ws)/$(APP_NAME)/src/lscript.ld; fi

	echo "#!/bin/sh\n" >$(ws)/run
	echo "xsct -interactive ./boot.tcl\n" >>$(ws)/run

	echo "#!/bin/sh\n" >$(ws)/config
	echo "xsct -interactive ./config.tcl\n" >>$(ws)/config

	echo '\nconnect -url tcp:127.0.0.1:3121\n' > tmp
	echo 'targets 1\n' >>tmp
	echo 'fpga $(plat_name)/export/$(plat_name)/hw/$(plat_name).bit\n' >> tmp
	echo 'targets 3\n' >> tmp
	echo 'dow $(APP_NAME)/$(build)/$(APP_NAME).elf\n' >> tmp
	echo 'con\n' >> tmp
	echo 'exit\n' >> tmp
	mv tmp $(ws)/boot.tcl

	echo '\nsetws .\n' > tmp
	echo 'app config -name $(APP_NAME) build-config $(build)\n' >>tmp
	echo 'app build $(APP_NAME)\n' >>tmp
	echo 'exit\n' >> tmp
	mv tmp $(ws)/config.tcl

	echo '{' > tmp.json
	echo '    "version": "2.0.0",' >> tmp.json
	echo '    "tasks": [' >> tmp.json
	echo '        { "label": "Release", "type": "shell", "command": "make", "group": "build",' >> tmp.json
	echo '          "options": { "cwd": "$(APP_NAME)/Release" },' >> tmp.json
	echo '        },' >> tmp.json
	echo '        { "label": "Clean", "type": "shell", "command": "make clean", "group": "build",' >> tmp.json
	echo '          "options": { "cwd": "$(APP_NAME)/Release" },' >> tmp.json
	echo '        },' >>tmp.json
	echo '        { "label": "Run", "type": "shell", "command": "source run", "group": "build",' >> tmp.json
	echo '        },' >> tmp.json
	echo '        { "label": "Config", "type": "shell", "command": "source config", "group": "build",' >> tmp.json
	echo '        }' >> tmp.json
	echo '    ]' >> tmp.json
	echo '}' >>tmp.json
	mkdir $(ws)/.vscode

	echo '{' >tmp.json
	echo '    "configurations": [' >>tmp.json
	echo '        {' >>tmp.json
	echo '            "name": "Linux",' >>tmp.json
	echo '            "includePath": [' >> tmp.json
	echo '                "$${workspaceFolder}/**",' >> tmp.json
	echo '                "$${workspaceFolder}/$(plat_name)/$(APP_NAME)_0/standalone_$(APP_NAME)_0/bsp/$(APP_NAME)_0/include"' >> tmp.json
	echo '            ],' >> tmp.json
	echo '            "defines": [],' >> tmp.json
	echo '            "compilerPath": "~/Tools/Xilinx/Vitis/2021.1/gnu/microblaze/lin/bin/mb-gcc",' >>tmp.json
	echo '            "cStandard": "gnu17",' >> tmp.json
	echo '            "cppStandard": "gnu++17",' >> tmp.json
	echo '            "intelliSenseMode": "linux-gcc-x64"' >> tmp.json
	echo '        }' >> tmp.json
	echo '    ],' >> tmp.json
	echo '    "version": 4' >> tmp.json
	echo '}' >> tmp.json
	mv tmp.json $(ws)/.vscode/c_cpp_properties.json
clean:
	rm -f -d -r $(ws)
	rm -f -d -r .Xil
	rm tmp*
