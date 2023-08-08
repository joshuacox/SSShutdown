PREFIX:=/usr/local
PREFIX_BIN:=${PREFIX}/bin

install: install_all clean

INSTALLS = RRReboot MorningUpdate mmmirrorUpdater sssuspend SSShutdown FFForceUpdateAndShutdown UUUpdateAndShutdown UpdateOnly hibernate hybrid PowerSave Low Mid Performance
install_all:
	@echo "Warning you will need the correct permission to put files in ${PREFIX}, or use sudo make install"
	$(foreach var,$(INSTALLS),./installer $(var);)
	sudo mkdir -p ${PREFIX}/SSShutdown/lib
	sudo install -v -m 0755 -o ${USER} -g ${USER} lib/uuutil.bash ${PREFIX}/SSShutdown/lib/uuutil.bash

clean:
	@rm -Rfv build_tmp

vanity:
	curl -i https://git.io -F "url=https://raw.githubusercontent.com/joshuacox/SSShutdown/master/bootstrap" -F "code=ssshutdown"

hooks:
	sudo mkdir -p /etc/ssshutdown/hooks
	sudo cp -i hooks.example/in.example /etc/ssshutdown/hooks/in
	sudo cp -i hooks.example/out.example /etc/ssshutdown/hooks/out
