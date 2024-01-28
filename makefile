
APP_NAME=zynq-with-led-mio-10
build=Release
ws=proj
plat_name=design_1_wrapper
xsa=/home/nemo/workspace/FPGA/Zynq/$(APP_NAME)/hw/design_1_wrapper.xsa
domain_name_apu=standalone_ps7_cortexa9_0
sys_name=$(APP_NAME)_system

init:
	if [ -d "$(ws)/$(APP_NAME)/src" ]; then tar cf src.tar "$(ws)/$(APP_NAME)/src"; fi
	if [ -d "$(ws)" ]; then rm -f -d -r $(ws); fi
	if [ -d ".Xil" ]; then rm -f -d -r ".Xil"; fi
	xsct -eval "setws $(ws); \
	platform create -name $(plat_name) -hw $(xsa); \
	domain create -name $(domain_name_apu) -os standalone -proc ps7_cortexa9_0; \
	app create -name $(APP_NAME) -platform $(plat_name) -domain $(domain_name_apu) -sysproj $(sys_name) -template {Hello World}; \
	platform active $(plat_name); \
	platform generate; \
        app config -name $(APP_NAME) build-config $(build); \
	app build -all; "

	rm -f -d -r .Xil
	rm -f -d -r $(ws)/$(sys_name)

	if [ -e src.tar ]; then rm -f -d -r $(ws)/$(APP_NAME)/src; tar xvf src.tar; rm -f src.tar; fi

	echo "#!/bin/sh\n" >$(ws)/run
	echo "xsct -interactive ./boot.tcl\n" >>$(ws)/run


	cp ./boot.tcl tmp

	echo "\nfpga "$(plat_name)"/export/"$(plat_name)"/hw/"$(plat_name)".bit\n" >> tmp
	echo "dow "$(APP_NAME)"/Release/"$(APP_NAME)".elf\n" >> tmp
	echo "con\n" >> tmp
	echo "exit\n" >> tmp
	mv tmp $(ws)/boot.tcl

	echo "{" > tmp.json
	echo "    \"version\": \"2.0.0\"," >> tmp.json
	echo "    \"tasks\": [" >> tmp.json
	echo "        { \"label\": \"Release\", \"type\": \"shell\", \"command\": \"make\", \"group\": \"build\"," >> tmp.json
	echo "          \"options\": { \"cwd\": \"$(APP_NAME)/Release\" }," >> tmp.json
	echo "        }," >> tmp.json
	echo "        { \"label\": \"Clean\", \"type\": \"shell\", \"command\": \"make clean\", \"group\": \"build\"," >> tmp.json
	echo "          \"options\": { \"cwd\": \"$(APP_NAME)/Release\" }," >> tmp.json
	echo "        }," >>tmp.json
	echo "        { \"label\": \"Run\", \"type\": \"shell\", \"command\": \"source run\", \"group\": \"build\"," >> tmp.json
	echo "        }" >> tmp.json
	echo "    ]" >> tmp.json
	echo "}" >>tmp.json
	mkdir $(ws)/.vscode
	mv tmp.json $(ws)/.vscode/tasks.json

clean:
	rm -f -d -r $(ws)
	rm -f -d -r .Xil
	rm tmp*
