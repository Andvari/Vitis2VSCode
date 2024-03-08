
#core=ps7_cortexa9

#target=ARM Cortex-A9 MPCore
target=MicroBlaze
#family=APU
family=xc7k325t
#family=xc7z010
core=microblaze
APP_NAME=$(basename $(notdir $(wildcard ../hw/*.xpr)))
build=Release
plat_name=design_1_wrapper
top_module=top
os=standalone
lang=C++
empty=
is_space=
ifeq ($(lang), C++)
	is_space=$(empty) $(empty)
endif
app_template=Empty Application$(is_space)($(lang))
N=0

init:
	@echo $(APP_NAME)
	if [ -d "$(APP_NAME)/src" ]; then tar cf src.tar "$(APP_NAME)/src"; fi
	rm -f -d -r ".metadata"
	rm -f -d -r ".Xil"
	rm -f -d -r ".vscode";
	rm -f -d -r "$(plat_name)"
	rm -f -d -r "$(APP_NAME)"
	rm -f config
	rm -f config.tcl
	rm -f boot.tcl
	rm -f run
	xsct -eval "setws .; \
	platform create -name $(plat_name) -hw ../hw/$(top_module).xsa; \
	domain create -name $(os)_$(core)_$(N) -os $(os) -proc $(core)_$(N); \
	app create -name $(APP_NAME) -platform $(plat_name) -domain $(os)_$(core)_$(N) -lang $(lang) -sysproj $(APP_NAME)_system -template {$(app_template)}; \
	platform active $(plat_name); \
	platform generate; \
	app config -name $(APP_NAME) build-config $(build); "
#	app build -all; "

	rm -f -d -r .Xil
	rm -f -d -r $(APP_NAME)_system
	rm -f .analytics
	rm -f IDE.log

	if [ -e $(APP_NAME)/src/lscript.ld ]; then mv $(APP_NAME)/src/lscript.ld .; fi
	if [ -e src.tar ]; then rm -f -d -r $(APP_NAME)/src; tar xvf src.tar; rm -f src.tar; fi
	if [ -e lscript.ld ]; then mv lscript.ld $(APP_NAME)/src/lscript.ld; fi

	echo "#!/bin/sh\n" > run
	echo "xsct -interactive ./boot.tcl\n" >> run

	echo "#!/bin/sh\n" > config
	echo "xsct -interactive ./config.tcl\n" >> config
	echo "rm -f -d -r .Xil" >> config
	echo "rm -f .analytics" >> config
	echo "rm -f IDE.log" >> config

	echo '\nconnect -url tcp:127.0.0.1:3121\n' > boot.tcl
	echo 'targets -set -filter {name =~ "$(family)"}\n' >> boot.tcl
	echo 'fpga $(APP_NAME)/_ide/bitstream/$(top_module).bit\n' >> boot.tcl
	echo 'targets -set -filter {name =~ "$(target)*#0"}\n' >> boot.tcl
	echo 'dow $(APP_NAME)/$(build)/$(APP_NAME).elf\n' >> boot.tcl
	echo 'con\n' >> boot.tcl
	echo 'exit\n' >> boot.tcl

	echo '\nsetws .\n' > config.tcl
	echo 'app config -name $(APP_NAME) build-config $(build)\n' >> config.tcl
	echo 'app build $(APP_NAME)\n' >> config.tcl
	echo 'exit\n' >> config.tcl

	mkdir .vscode
	echo '{' > .vscode/tasks.json
	echo '    "version": "2.0.0",' >> .vscode/tasks.json
	echo '    "tasks": [' >> .vscode/tasks.json
	echo '        { "label": "Release", "type": "shell", "command": "make", "group": "build",' >> .vscode/tasks.json
	echo '          "options": { "cwd": "$(APP_NAME)/Release" },' >> .vscode/tasks.json
	echo '        },' >> .vscode/tasks.json
	echo '        { "label": "Clean", "type": "shell", "command": "make clean", "group": "build",' >> .vscode/tasks.json
	echo '          "options": { "cwd": "$(APP_NAME)/Release" },' >> .vscode/tasks.json
	echo '        },' >> .vscode/tasks.json
	echo '        { "label": "Run", "type": "shell", "command": "source run", "group": "build",' >> .vscode/tasks.json
	echo '        },' >> .vscode/tasks.json
	echo '        { "label": "Config", "type": "shell", "command": "source config", "group": "build",' >> .vscode/tasks.json
	echo '        }' >> .vscode/tasks.json
	echo '    ]' >> .vscode/tasks.json
	echo '}' >> .vscode/tasks.json

	echo '{' > .vscode/c_cpp_properties.json
	echo '    "configurations": [' >> .vscode/c_cpp_properties.json
	echo '        {' >> .vscode/c_cpp_properties.json
	echo '            "name": "Linux",' >> .vscode/c_cpp_properties.json
	echo '            "includePath": [' >> .vscode/c_cpp_properties.json
	echo '                "$${workspaceFolder}/**",' >> .vscode/c_cpp_properties.json
	echo '                "$${workspaceFolder}/$(plat_name)/$(core)_$(N)/$(os)_$(core)_$(N)/bsp/$(core)_$(N)/include"' >> .vscode/c_cpp_properties.json
	echo '            ],' >> .vscode/c_cpp_properties.json
	echo '            "defines": [],' >> .vscode/c_cpp_properties.json
	echo '            "compilerPath": "~/Tools/Xilinx/Vitis/2021.1/gnu/microblaze/lin/bin/mb-gcc",' >> .vscode/c_cpp_properties.json
	echo '            "cStandard": "gnu17",' >> .vscode/c_cpp_properties.json
	echo '            "cppStandard": "gnu++17",' >> .vscode/c_cpp_properties.json
	echo '            "intelliSenseMode": "linux-gcc-x64"' >> .vscode/c_cpp_properties.json
	echo '        }' >> .vscode/c_cpp_properties.json
	echo '    ],' >> .vscode/c_cpp_properties.json
	echo '    "version": 4' >> .vscode/c_cpp_properties.json
	echo '}' >> .vscode/c_cpp_properties.json
clean:
	rm -f -d -r $(plat_name)
	rm -f -d -r $(APP_NAME)_system
	rm -f -d -r $(APP_NAME)
	rm -f -d -r .Xil
	rm -f -d -r .metadata
	rm -f -d -r .vscode
	rm -f .analytics
	rm -f boot.tcl
	rm -f config
	rm -f config.tcl
	rm -f IDE.log
	rm -f run
	rm -f tmp*
